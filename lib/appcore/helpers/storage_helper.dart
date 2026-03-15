// lib/appcore/helpers/storage_helper.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class StorageHelper {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Keys
  static const String _userKey = 'user';
  static const String _appStageKey = 'app_stage';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _languageKey = 'language';
  static const String _countryKey = 'country';

  /// Generic read/write
  static Future<void> write(String key, String value) async {
    print('writinggggggggggggggggggggggggggggggggggggggggggggg');
    print(value);
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// User Management
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user));
    debugPrint('✅ User saved to storage');
  }

  static Future<void> setUser(Map<String, dynamic> user) async {
    await saveUser(user);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final jsonStr = await _storage.read(key: _userKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('⚠️ Error reading user: $e');
      return null;
    }
  }

  static Future<void> updateUserField(String key, dynamic value) async {
    final user = await getUser() ?? {};
    user[key] = value;
    await setUser(user);
  }

  static Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
    debugPrint('🗑️ User cleared from storage');
  }

  /// App Stage
  static Future<void> setAppStage(String stage) async {
    await _storage.write(key: _appStageKey, value: stage);
  }

  static Future<String?> getAppStage() async {
    return await _storage.read(key: _appStageKey);
  }

  /// FCM Token
  static Future<void> setFCMToken(String token) async {
        print('tokennnnnnnnnnnnnnnnnnnnnnnn set');
    print(token);
    await _storage.write(key: _fcmTokenKey, value: token);
  }

  static Future<String?> getFCMToken() async {

    return await _storage.read(key: _fcmTokenKey);
  }

  static Future<void> clearFCMToken() async {
    await _storage.delete(key: _fcmTokenKey);
  }

  /// Language
  static Future<void> setLanguage(String language) async {
    await _storage.write(key: _languageKey, value: language);
  }

  static Future<String?> getLanguage() async {
    return await _storage.read(key: _languageKey);
  }

  /// Country
  static Future<void> setCountry(String country) async {
    await _storage.write(key: _countryKey, value: country);
  }

  static Future<String?> getCountry() async {
    return await _storage.read(key: _countryKey) ?? 'Ghana';
  }

  /// Clear all
  static Future<void> clearAll() async {
    await _storage.deleteAll();
    debugPrint('🗑️ All storage cleared');
  }
}