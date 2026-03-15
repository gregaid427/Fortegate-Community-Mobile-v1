// lib/appcore/api/api_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fortegatecommunity/appcore/config/appconfig.dart';
import '../service/network_service.dart';
import '../service/token_service.dart';
import '../utils/encryption_utils.dart';
import 'respondent_api.dart';
import 'survey_api.dart';
import 'meeting_api.dart';
import 'points_api.dart';

String _getBaseUrl() {
  String devApiUrl = 'http://10.0.2.2:5500';
  String? prodApiUrl = dotenv.env['BASE_URL'];

  String? envUrl = false ? devApiUrl : prodApiUrl;
  //final envUrl = AppConfig.apiUrl;
  //print(envUrl);
  return envUrl!;
}

class ApiService {
  ApiService._internal() {
    _dio = Dio(_baseOptions);
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_loggingInterceptor());
    _dio.interceptors.add(_encryptionInterceptor());
    _dio.interceptors.add(_errorInterceptor());
  }

  static final ApiService instance = ApiService._internal();

  late final Dio _dio;
  late final RespondentApi respondent = RespondentApi(this);
  late final SurveyApi survey = SurveyApi(this);
  late final MeetingApi meeting = MeetingApi(this);
  late final PointsApi points = PointsApi(this);

  String? _accessToken;

  /// Initialize token from secure storage
  Future<void> init() async {
    final token = await TokenService.getToken();
    if (token != null) {
      _accessToken = token;
      debugPrint('🔑 Token loaded from storage');
    }
  }

  BaseOptions get _baseOptions => BaseOptions(
    baseUrl: _getBaseUrl(),
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );

  /// Set token and save to secure storage
  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    await TokenService.saveToken(token);
    debugPrint('🔐 Access token set and saved');
  }

  /// Clear token from memory and storage
  Future<void> clearAccessToken() async {
    _accessToken = null;
    await TokenService.deleteToken();
    debugPrint('🔓 Access token cleared');
  }

  String? get accessToken => _accessToken;
  String get baseUrl => _dio.options.baseUrl;

  /// Auth Interceptor - Add JWT token
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_accessToken == null) {
          _accessToken = await TokenService.getToken();
        }
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },
    );
  }

  /// Encryption Interceptor
  Interceptor _encryptionInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        try {
          if (options.data is FormData || options.data == null) {
            return handler.next(options);
          }

          if (options.data is Map<String, dynamic>) {
            final encrypted = EncryptionUtils.encryptData(
              options.data as Map<String, dynamic>,
            );

            options.data = {'data': encrypted};

            debugPrint('🔒 Request encrypted');
          }

          handler.next(options);
        } catch (e) {
          debugPrint('❌ Request encryption error: $e');
          handler.next(options);
        }
      },
      onResponse: (response, handler) {
        try {
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            if (data.containsKey('data') && data['data'] is String) {
              response.data = EncryptionUtils.decryptData(
                data['data'] as String,
                
              );
               print(response);

               print('response');
              debugPrint('🔓 Response decrypted');
            }
          }

          handler.next(response);
        } catch (e) {
          debugPrint('❌ Response decryption error: $e');
          handler.next(response);
        }
      },
    );
  }

  /// Error Interceptor
  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (DioException e, handler) async {
        EasyLoading.dismiss();

        // Handle 401 - token expired
        if (e.response?.statusCode == 401) {
          debugPrint('🔓 Token expired - clearing session');
          await clearAccessToken();
        }

        handler.next(e);
      },
    );
  }

  /// Logging Interceptor
  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint(
          '📤 REQUEST [${options.method}] => ${options.baseUrl}${options.path}',
        );
        debugPrint('📤 Headers: ${options.headers}');
        debugPrint('📤 Body: ${options.data}');

        if (options.headers.containsKey('Authorization')) {
          debugPrint('📤 Token: ${options.headers['Authorization']}');
        }

        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
          '📥 RESPONSE [${response.statusCode}] => ${response.requestOptions.baseUrl}${response.requestOptions.path}',
        );
        debugPrint('📥 Response Body: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint(
          '❌ ERROR [${error.response?.statusCode}] => ${error.requestOptions.baseUrl}${error.requestOptions.path}',
        );
        debugPrint('❌ Message: ${error.message}');
        debugPrint('❌ Response: ${error.response?.data}');
        handler.next(error);
      },
    );
  }

  /// Ensure connection
  Future<bool> _ensureConnection() async {
    final connected = await NetworkService.hasConnection();
    if (!connected) {
      EasyLoading.dismiss();
      debugPrint('⚠️ No internet connection');
    }
    return connected;
  }

  Map<String, dynamic> _offlineError() => {
    "error": true,
    "message": "No internet connection. Please check and try again.",
  };

  /// HTTP Methods
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    if (!await _ensureConnection()) return _offlineError();
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      if (response.data is Map<String, dynamic>) return response.data;
      return {"error": true, "message": "Invalid server response format."};
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    required dynamic data,
  }) async {
    if (!await _ensureConnection()) return _offlineError();
    try {
      final response = await _dio.post(endpoint, data: data);
      if (response.data is Map<String, dynamic>) return response.data;
      return {"error": true, "message": "Invalid server response format."};
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    required dynamic data,
  }) async {
    if (!await _ensureConnection()) return _offlineError();
    try {
      final response = await _dio.patch(endpoint, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint, {dynamic data}) async {
    if (!await _ensureConnection()) return _offlineError();
    try {
      final response = await _dio.delete(endpoint, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// Error handler
  Map<String, dynamic> _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return {"error": true, "message": "Network timeout. Please try again."};
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return {
        "error": true,
        "message": "Server response delayed. Please try again.",
      };
    }
    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      String message = "Server error occurred.";
      if (data is Map<String, dynamic>)
        message = data['msg'] ?? data['message'] ?? message;

      switch (statusCode) {
        case 400:
          return {"error": true, "status": 400, "message": message};
        case 401:
          clearAccessToken();
          return {
            "error": true,
            "status": 401,
            "message": "Session expired. Please login again.",
          };
        case 403:
          return {"error": true, "status": 403, "message": "Access forbidden."};
        case 404:
          return {"error": true, "status": 404, "message": message};
        case 409:
          return {"error": true, "status": 409, "message": message};
        case 500:
          return {"error": true, "status": 500, "message": message};
        default:
          return {"error": true, "status": statusCode, "message": message};
      }
    }
    if (e.type == DioExceptionType.cancel) {
      return {"error": true, "message": "Request cancelled."};
    }
    return {
      "error": true,
      "message": "Unexpected error occurred. Please try again.",
    };
  }
}
