// lib/appcore/utils/encryption_utils.dart

import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

class EncryptionUtils {
  // ⚠️ MUST MATCH BACKEND - use same 32-char key from .env
  static const String _encryptionKey = 'X7k2Pz9Qm3L8sR1T4v6W0yZaBcDeFgHj';

  /// Encrypt data before sending to API
  static String encryptData(Map<String, dynamic> data) {
    try {
      final key = encrypt.Key.fromUtf8(_encryptionKey);
      final iv = encrypt.IV.fromSecureRandom(16); // Random IV
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
      );

      final jsonString = jsonEncode(data);
      final encrypted = encrypter.encrypt(jsonString, iv: iv);

      // Concatenate: IV (base64) + ":" + ciphertext (base64)
      final combined = '${iv.base64}:${encrypted.base64}';
      debugPrint('🔒 Encrypted (IV+cipher): $combined');
      return combined;
    } catch (e) {
      debugPrint('❌ Encryption error: $e');
      rethrow;
    }
  }

  /// Decrypt data received from API
  static Map<String, dynamic> decryptData(String encryptedData) {
    try {
      // Split IV and ciphertext
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        throw FormatException('Invalid encrypted data format');
      }

      final ivBase64 = parts[0];
      final cipherBase64 = parts[1];

      // Decode IV from base64
      final key = encrypt.Key.fromUtf8(_encryptionKey);
      final iv = encrypt.IV.fromBase64(ivBase64);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
      );

      // Decrypt using the extracted IV
      final encrypted = encrypt.Encrypted.fromBase64(cipherBase64);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      final jsonData = jsonDecode(decrypted);
      print(jsonData);

      debugPrint('🔓 Data decrypted successfully');
      return jsonData as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Decryption error: $e');
      debugPrint('❌ Encrypted data: $encryptedData');
      rethrow;
    }
  }
}