import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather.dart';
import '../models/crop_scan.dart';

class OfflineCacheService {
  static const String _weatherCacheKey = 'cached_weather_data';
  static const String _weatherCacheTimeKey = 'weather_cache_time';
  static const String _aiResponsesKey = 'cached_ai_responses';
  static const String _cropScansKey = 'cached_crop_scans';
  static const String _userDataKey = 'cached_user_data';

  static const Duration _weatherCacheDuration = Duration(hours: 6);
  static const Duration _aiCacheDuration = Duration(days: 7);

  // Weather Caching
  static Future<void> cacheWeatherData(WeatherData weather) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weatherCacheKey, jsonEncode({
      'temperature': weather.temperature,
      'humidity': weather.humidity,
      'windSpeed': weather.windSpeed,
      'timestamp': DateTime.now().toIso8601String(),
    }));
    await prefs.setString(_weatherCacheTimeKey, DateTime.now().toIso8601String());
  }

  static Future<WeatherData?> getCachedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_weatherCacheKey);
    final cacheTime = prefs.getString(_weatherCacheTimeKey);

    if (cachedData == null || cacheTime == null) return null;

    final cachedTime = DateTime.parse(cacheTime);
    if (DateTime.now().difference(cachedTime) > _weatherCacheDuration) {
      return null; // Cache expired
    }

    try {
      final data = jsonDecode(cachedData);
      return WeatherData(
        temperature: data['temperature']?.toDouble() ?? 0.0,
        humidity: data['humidity']?.toDouble() ?? 0.0,
        windSpeed: data['windSpeed']?.toDouble() ?? 0.0,
        uvIndex: 0,
        rainfallProbability: 0.0,
        forecast: [],
        timestamp: DateTime.parse(data['timestamp']),
      );
    } catch (e) {
      return null;
    }
  }

  // AI Response Caching
  static Future<void> cacheAIResponse(String question, String response) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedResponses = prefs.getString(_aiResponsesKey);
    Map<String, dynamic> responses = {};

    if (cachedResponses != null) {
      try {
        responses = jsonDecode(cachedResponses);
      } catch (e) {
        responses = {};
      }
    }

    responses[question.toLowerCase().trim()] = {
      'response': response,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Keep only last 50 responses
    if (responses.length > 50) {
      final sortedEntries = responses.entries.toList()
        ..sort((a, b) => DateTime.parse(b.value['timestamp'])
            .compareTo(DateTime.parse(a.value['timestamp'])));

      responses = Map.fromEntries(sortedEntries.take(50));
    }

    await prefs.setString(_aiResponsesKey, jsonEncode(responses));
  }

  static Future<String?> getCachedAIResponse(String question) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedResponses = prefs.getString(_aiResponsesKey);

    if (cachedResponses == null) return null;

    try {
      final responses = jsonDecode(cachedResponses);
      final normalizedQuestion = question.toLowerCase().trim();

      // Check for exact match
      if (responses.containsKey(normalizedQuestion)) {
        final responseData = responses[normalizedQuestion];
        final timestamp = DateTime.parse(responseData['timestamp']);

        if (DateTime.now().difference(timestamp) < _aiCacheDuration) {
          return responseData['response'];
        }
      }

      // Check for similar questions
      for (final entry in responses.entries) {
        if (_questionsAreSimilar(normalizedQuestion, entry.key)) {
          final responseData = entry.value;
          final timestamp = DateTime.parse(responseData['timestamp']);

          if (DateTime.now().difference(timestamp) < _aiCacheDuration) {
            return responseData['response'];
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static bool _questionsAreSimilar(String q1, String q2) {
    final words1 = q1.split(' ').where((w) => w.length > 3).toSet();
    final words2 = q2.split(' ').where((w) => w.length > 3).toSet();

    final intersection = words1.intersection(words2);
    final union = words1.union(words2);

    return union.isNotEmpty && (intersection.length / union.length) > 0.6;
  }

  // Crop Scans Caching
  static Future<void> cacheCropScan(CropScan scan) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedScans = prefs.getString(_cropScansKey);
    List<dynamic> scans = [];

    if (cachedScans != null) {
      try {
        scans = jsonDecode(cachedScans);
      } catch (e) {
        scans = [];
      }
    }

    scans.insert(0, scan.toJson());

    // Keep only last 20 scans
    if (scans.length > 20) {
      scans = scans.take(20).toList();
    }

    await prefs.setString(_cropScansKey, jsonEncode(scans));
  }

  static Future<List<CropScan>> getCachedCropScans() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedScans = prefs.getString(_cropScansKey);

    if (cachedScans == null) return [];

    try {
      final scansData = jsonDecode(cachedScans) as List;
      return scansData.map((data) => CropScan.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  // User Data Caching
  static Future<void> cacheUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_userDataKey);

    if (cachedData == null) return null;

    try {
      return jsonDecode(cachedData);
    } catch (e) {
      return null;
    }
  }

  // Cache Management
  static Future<void> clearExpiredCache() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear expired weather cache
    final weatherCacheTime = prefs.getString(_weatherCacheTimeKey);
    if (weatherCacheTime != null) {
      final cachedTime = DateTime.parse(weatherCacheTime);
      if (DateTime.now().difference(cachedTime) > _weatherCacheDuration) {
        await prefs.remove(_weatherCacheKey);
        await prefs.remove(_weatherCacheTimeKey);
      }
    }

    // Clear expired AI responses
    final cachedResponses = prefs.getString(_aiResponsesKey);
    if (cachedResponses != null) {
      try {
        final responses = jsonDecode(cachedResponses);
        final now = DateTime.now();
        final validResponses = {};

        for (final entry in responses.entries) {
          final timestamp = DateTime.parse(entry.value['timestamp']);
          if (now.difference(timestamp) < _aiCacheDuration) {
            validResponses[entry.key] = entry.value;
          }
        }

        await prefs.setString(_aiResponsesKey, jsonEncode(validResponses));
      } catch (e) {
        await prefs.remove(_aiResponsesKey);
      }
    }
  }

  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_weatherCacheKey);
    await prefs.remove(_weatherCacheTimeKey);
    await prefs.remove(_aiResponsesKey);
    await prefs.remove(_cropScansKey);
    await prefs.remove(_userDataKey);
  }

  static Future<Map<String, dynamic>> getCacheStats() async {
    final prefs = await SharedPreferences.getInstance();

    final weatherCached = prefs.getString(_weatherCacheKey) != null;
    final aiResponsesCount = prefs.getString(_aiResponsesKey) != null
        ? (jsonDecode(prefs.getString(_aiResponsesKey)!)).length
        : 0;
    final cropScansCount = prefs.getString(_cropScansKey) != null
        ? (jsonDecode(prefs.getString(_cropScansKey)!)).length
        : 0;

    return {
      'weather_cached': weatherCached,
      'ai_responses_count': aiResponsesCount,
      'crop_scans_count': cropScansCount,
      'cache_size_mb': await _getCacheSize(),
    };
  }

  static Future<double> _getCacheSize() async {
    // Approximate cache size calculation
    final prefs = await SharedPreferences.getInstance();
    double size = 0;

    final keys = [
      _weatherCacheKey,
      _aiResponsesKey,
      _cropScansKey,
      _userDataKey,
    ];

    for (final key in keys) {
      final value = prefs.getString(key);
      if (value != null) {
        size += value.length;
      }
    }

    return size / (1024 * 1024); // Convert to MB
  }
}