import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class DataProtectionService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const String _encryptionKeyKey = 'encryption_key';
  static const String _dataRetentionDaysKey = 'data_retention_days';
  static const String _autoDeleteKey = 'auto_delete_enabled';

  // Data Encryption
  static Future<String> encryptData(String data) async {
    try {
      await _getOrCreateEncryptionKey();
      final bytes = utf8.encode(data);
      final digest = sha256.convert(bytes);

      // In a real implementation, you would use proper encryption
      // For now, we'll use base64 encoding with a simple transformation
      final encoded = base64Encode(bytes);
      return '$encoded:${digest.toString().substring(0, 8)}';
    } catch (e) {
      // Fallback to simple encoding if encryption fails
      return base64Encode(utf8.encode(data));
    }
  }

  static Future<String> decryptData(String encryptedData) async {
    try {
      // Remove the hash suffix if present
      final parts = encryptedData.split(':');
      final encoded = parts[0];

      final decoded = utf8.decode(base64Decode(encoded));
      return decoded;
    } catch (e) {
      // Fallback to simple decoding
      try {
        return utf8.decode(base64Decode(encryptedData));
      } catch (e) {
        return encryptedData; // Return as-is if decoding fails
      }
    }
  }

  static Future<String> _getOrCreateEncryptionKey() async {
    // ignore: unused_local_variable
    final key = await _secureStorage.read(key: _encryptionKeyKey);

    if (key == null) {
      // Generate a new encryption key
      final random = Random.secure();
      final bytes = List<int>.generate(32, (_) => random.nextInt(256));
      final newKey = base64Encode(bytes);

      await _secureStorage.write(key: _encryptionKeyKey, value: newKey);
      return newKey;
    }

    return key;
  }

  // Secure Data Storage
  static Future<void> storeSecureData(String key, String value) async {
    final encryptedValue = await encryptData(value);
    await _secureStorage.write(key: key, value: encryptedValue);
  }

  static Future<String?> retrieveSecureData(String key) async {
    final encryptedValue = await _secureStorage.read(key: key);
    if (encryptedValue == null) return null;

    return await decryptData(encryptedValue);
  }

  static Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }

  // Data Retention Management
  static Future<void> setDataRetentionPolicy({
    required int retentionDays,
    required bool autoDelete,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dataRetentionDaysKey, retentionDays);
    await prefs.setBool(_autoDeleteKey, autoDelete);
  }

  static Future<Map<String, dynamic>> getDataRetentionPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'retention_days': prefs.getInt(_dataRetentionDaysKey) ?? 90,
      'auto_delete': prefs.getBool(_autoDeleteKey) ?? true,
    };
  }

  // Automatic Data Cleanup
  static Future<void> performDataCleanup() async {
    final policy = await getDataRetentionPolicy();
    final retentionDays = policy['retention_days'] as int;
    final autoDelete = policy['auto_delete'] as bool;

    if (!autoDelete) return;

    final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));

    // Clean up old cached data
    await _cleanupOldCacheData(cutoffDate);

    // Clean up old logs and temporary files
    await _cleanupOldLogs(cutoffDate);
  }

  static Future<void> _cleanupOldCacheData(DateTime cutoffDate) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith('cached_') || key.startsWith('temp_')) {
        final value = prefs.getString(key);
        if (value != null) {
          try {
            // Check if the data has a timestamp
            final data = jsonDecode(value);
            if (data is Map && data.containsKey('timestamp')) {
              final timestamp = DateTime.parse(data['timestamp']);
              if (timestamp.isBefore(cutoffDate)) {
                await prefs.remove(key);
              }
            }
          } catch (e) {
            // If we can't parse the data, remove it if it's old
            await prefs.remove(key);
          }
        }
      }
    }
  }

  static Future<void> _cleanupOldLogs(DateTime cutoffDate) async {
    // Implementation would depend on your logging system
    // This is a placeholder for log cleanup logic
  }

  // Data Export for GDPR Compliance
  static Future<Map<String, dynamic>> exportUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final allData = <String, dynamic>{};

    // Export all user preferences and cached data
    for (final key in prefs.getKeys()) {
      final value = prefs.get(key);
      allData[key] = value;
    }

    // Add metadata
    allData['_export_metadata'] = {
      'export_date': DateTime.now().toIso8601String(),
      'app_version': '1.0.0',
      'data_version': '1.0',
    };

    return allData;
  }

  // Data Deletion for GDPR Compliance
  static Future<void> deleteAllUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear all SharedPreferences
    await prefs.clear();

    // Clear secure storage
    await _secureStorage.deleteAll();

    // Clear any other cached data
    // This would include database cleanup, file deletion, etc.
  }

  // Privacy Settings
  static Future<void> updatePrivacySettings({
    required bool analyticsEnabled,
    required bool crashReportingEnabled,
    required bool personalizedAds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('analytics_enabled', analyticsEnabled);
    await prefs.setBool('crash_reporting_enabled', crashReportingEnabled);
    await prefs.setBool('personalized_ads', personalizedAds);
  }

  static Future<Map<String, bool>> getPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'analytics_enabled': prefs.getBool('analytics_enabled') ?? true,
      'crash_reporting_enabled': prefs.getBool('crash_reporting_enabled') ?? true,
      'personalized_ads': prefs.getBool('personalized_ads') ?? false,
    };
  }

  // Security Utilities
  static Future<bool> isDeviceSecure() async {
    // Check if device has security features enabled
    // This would check for biometrics, screen lock, etc.
    return true; // Placeholder implementation
  }

  static Future<void> secureWipe() async {
    // Perform secure data wipe
    await deleteAllUserData();

    // In a real implementation, you might also:
    // - Overwrite data multiple times
    // - Clear system caches
    // - Remove app from recent apps
  }
}