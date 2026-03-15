// lib/appcore/api/respondent_api.dart

import 'package:flutter/foundation.dart';
import 'api_service.dart';

class RespondentApi {
  final ApiService _api;

  RespondentApi(this._api);

  /// Sign up new community member
  Future<Map<String, dynamic>> signup({
    required String phone,
    required String name,
    required String email,
    String? fcmToken,
  }) async {
    debugPrint('📝 Signing up user: $email');
    
    return await _api.post(
      '/respondents/communitymember',
      data: {
        'phone': phone,
        'name': name,
        'email': email,
        'token': fcmToken,
      },
    );
  }

  /// Send OTP for verification
  Future<Map<String, dynamic>> sendOTP({
    required String phoneNumber,
    required String rawnumber,
    String? fcmToken,
  }) async {
    debugPrint('📨 Sending OTP to: $phoneNumber');
    
    return await _api.post(
      '/respondents/send/community-otp',
      data: {
        'phoneNumber': phoneNumber,
        'rawnumber': rawnumber,
        'token': fcmToken,
      },
    );
  }

  /// Resend OTP
  Future<Map<String, dynamic>> resendOTP({
    required String userId,
    required int type,
    String? fcmToken,
  }) async {
    debugPrint('🔄 Resending OTP for user: $userId');
    
    return await _api.post(
      '/respondents/resendotp',
      data: {
        'userId': userId,
        'type': type,
        'token': fcmToken,
      },
    );
  }

  /// Verify OTP and complete login
  Future<Map<String, dynamic>> verifyOTP({
    required String userId,
    required String otp,
  }) async {
    debugPrint('🔐 Verifying OTP for user: $userId');
    
    return await _api.post(
      '/respondents/verify-otp',
      data: {
        'userId': userId,
        'otp': otp,
      },
    );
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
  }) async {
    debugPrint('📝 Updating profile for user: $userId');
    
    return await _api.patch(
      '/respondents/$userId/communitymember',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
      },
    );
  }

  /// Submit LSM score
  Future<Map<String, dynamic>> submitLSMScore({
    required String? userId,
    required dynamic? score,
  }) async {
    debugPrint('📊 Submitting LSM score for user: $userId');
    
    return await _api.post(
      '/respondents/community-lsmscore',
      data: {
        'id': userId,
        'score': score,
      },
    );
  }

  /// Submit onboarding questionnaire answers
  Future<Map<String, dynamic>> submitOnboardingAnswers({
    required String? userId,
    required dynamic? answers,
  }) async {
    debugPrint('📝 Submitting onboarding answers for user: $userId');
    
    return await _api.post(
      '/respondents/community-onboardanswers',
      data: {
        'id': userId,
        'answer': answers,
      },
    );
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getStats(String userId) async {
    debugPrint('📊 Fetching stats for user: $userId');
    
    return await _api.get('/respondents/collectstats/+$userId');
  }

  /// Update FCM token
  Future<Map<String, dynamic>> updateFCMToken({
    required String? userId,
    required String? fcmToken,
  }) async {
    debugPrint('🔔 Updating FCM token for user: $userId');
    
    return await _api.post(
      '/respondents/fcmstoretoken/$userId',
      data: {
        'fcm_token': fcmToken,
      },
    );
  }
}