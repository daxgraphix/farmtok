import 'package:hive_flutter/hive_flutter.dart';
import '../models/crop_scan.dart';
import '../models/weather.dart';

class LocalCacheService {
  static const String _scansBox = 'crop_scans';
  static const String _weatherBox = 'weather_data';
  static const String _chatBox = 'chat_history';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters if needed
    // Hive.registerAdapter(CropScanAdapter());
  }

  static Future<void> saveCropScan(CropScan scan) async {
    final box = await Hive.openBox(_scansBox);
    await box.put(scan.id, scan.toJson());
  }

  static Future<List<CropScan>> getCachedScans() async {
    final box = await Hive.openBox(_scansBox);
    final scans = box.values.map((json) => CropScan.fromJson(json)).toList();
    scans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return scans;
  }

  static Future<void> saveWeatherData(WeatherData weather) async {
    final box = await Hive.openBox(_weatherBox);
    await box.put('current', weather);
  }

  static Future<WeatherData?> getCachedWeather() async {
    final box = await Hive.openBox(_weatherBox);
    return box.get('current');
  }

  static Future<void> saveChatMessage(String message, String response, String userId) async {
    final box = await Hive.openBox(_chatBox);
    final chatData = {
      'message': message,
      'response': response,
      'timestamp': DateTime.now().toIso8601String(),
      'user_id': userId,
    };
    await box.add(chatData);
  }

  static Future<List<Map<String, dynamic>>> getCachedChatHistory() async {
    final box = await Hive.openBox(_chatBox);
    final history = box.values.toList().cast<Map<String, dynamic>>();
    history.sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
    return history.take(50).toList(); // Last 50 messages
  }

  static Future<void> clearOldCache() async {
    // Clear cached data older than 7 days
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));

    final scanBox = await Hive.openBox(_scansBox);
    final scanKeysToDelete = scanBox.keys.where((key) {
      final scan = CropScan.fromJson(scanBox.get(key));
      return scan.createdAt.isBefore(cutoffDate);
    }).toList();
    await scanBox.deleteAll(scanKeysToDelete);

    final chatBox = await Hive.openBox(_chatBox);
    final chatKeysToDelete = chatBox.keys.where((key) {
      final chat = chatBox.get(key) as Map<String, dynamic>;
      final timestamp = DateTime.parse(chat['timestamp']);
      return timestamp.isBefore(cutoffDate);
    }).toList();
    await chatBox.deleteAll(chatKeysToDelete);
  }
}