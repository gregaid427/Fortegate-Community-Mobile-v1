// lib/appcore/service/token_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class TokenService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  /// Save token securely
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      debugPrint('🔐 Token saved securely');
    } catch (e) {
      debugPrint('❌ Error saving token: $e');
    }
  }

  /// Get saved token
  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        debugPrint('🔑 Token retrieved');
      }
      return token;
    } catch (e) {
      debugPrint('❌ Error retrieving token: $e');
      return null;
    }
  }

  /// Delete token (logout)
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      debugPrint('🗑️ Token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting token: $e');
    }
  }

  /// Check if token exists
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}