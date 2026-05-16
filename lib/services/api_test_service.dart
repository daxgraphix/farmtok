import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Services
import '../services/supabase_service.dart';
import '../services/local_cache_service.dart';
import '../services/weather_service.dart';
import '../services/ai_service.dart';
import '../models/crop_scan.dart';
import '../services/notification_service.dart';

class ApiTestService {
  static Future<Map<String, dynamic>> testAllServices() async {
    Map<String, dynamic> results = {
      'timestamp': DateTime.now().toIso8601String(),
      'tests': <String, Map<String, dynamic>>{},
    };

    // Test 1: Environment Variables
    results['tests']['environment'] = await _testEnvironmentVariables();

    // Test 2: Supabase Service
    results['tests']['supabase'] = await _testSupabaseService();

    // Test 3: Local Cache Service
    results['tests']['local_cache'] = await _testLocalCacheService();

    // Test 4: Weather Service
    results['tests']['weather'] = await _testWeatherService();

    // Test 5: AI Service
    results['tests']['ai'] = await _testAIService();

    // Test 6: Notification Service
    results['tests']['notifications'] = await _testNotificationService();

    // Calculate overall status
    bool allPassed = results['tests'].values.every((test) => test['status'] == 'passed');
    results['overall_status'] = allPassed ? 'passed' : 'failed';

    return results;
  }

  static Future<Map<String, dynamic>> _testEnvironmentVariables() async {
    try {
      debugPrint('Testing environment variables...');

      // Load environment variables
      await dotenv.load();

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];
      final groqKey = dotenv.env['GROQ_API_KEY'];
      final weatherKey = dotenv.env['OPENWEATHERMAP_API_KEY'];

      bool hasSupabase = supabaseUrl != null && supabaseKey != null;
      bool hasGroq = groqKey != null;
      bool hasWeather = weatherKey != null;

      return {
        'status': hasSupabase && hasGroq && hasWeather ? 'passed' : 'warning',
        'message': 'Environment variables loaded',
        'details': {
          'supabase_configured': hasSupabase,
          'groq_configured': hasGroq,
          'weather_configured': hasWeather,
        },
      };
    } catch (e) {
      return {
        'status': 'failed',
        'message': 'Failed to load environment variables',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testSupabaseService() async {
    try {
      debugPrint('Testing Supabase service...');

      // Test initialization
      await SupabaseService.initialize();

      // Test basic connectivity
      final client = SupabaseService.client;
      final connectionTest = await client.from('users').select('count').limit(1);

      return {
        'status': 'passed',
        'message': 'Supabase service working',
        'details': {
          'initialized': true,
          'connection_test': connectionTest.isNotEmpty,
        },
      };
    } catch (e) {
      return {
        'status': 'failed',
        'message': 'Supabase service failed',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testLocalCacheService() async {
    try {
      debugPrint('Testing local cache service...');

      // Test initialization
      await LocalCacheService.initialize();

      // Test basic operations
      final testScan = CropScan(
        id: 'test_scan_123',
        userId: 'test_user',
        imageUrl: 'test_image.jpg',
        diseaseName: 'healthy',
        confidence: 0.95,
        treatment: 'none',
        prevention: 'regular care',
        createdAt: DateTime.now(),
      );

      // Save test data
      await LocalCacheService.saveCropScan(testScan);

      // Retrieve and verify
      final cached = await LocalCacheService.getCachedScans();
      final found = cached.any((scan) => scan.id == 'test_scan_123');

      return {
        'status': found ? 'passed' : 'warning',
        'message': 'Local cache service working',
        'details': {
          'initialized': true,
          'save_operation': true,
          'retrieve_operation': found,
        },
      };
    } catch (e) {
      return {
        'status': 'failed',
        'message': 'Local cache service failed',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testWeatherService() async {
    try {
      debugPrint('Testing weather service...');

      // Test with sample coordinates (Nairobi, Kenya)
      const double lat = -1.2864;
      const double lon = 36.8172;

      // Test current weather
      final currentWeather = await WeatherService.getCurrentWeather(lat, lon);

      // Test forecast
      final forecast = await WeatherService.get7DayForecast(lat, lon);

      // Test alerts
      final alerts = await WeatherService.getWeatherAlerts(lat, lon);

      return {
        'status': 'passed',
        'message': 'Weather service working',
        'details': {
          'current_weather': true,
          'forecast_days': forecast.length,
          'alerts': alerts.isNotEmpty,
          'temperature': currentWeather.temperature,
          'humidity': currentWeather.humidity,
        },
      };
    } catch (e) {
      debugPrint('Weather service test failed: $e');
      return {
        'status': 'failed',
        'message': 'Weather service failed',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testAIService() async {
    try {
      debugPrint('Testing AI service with multiple providers...');

      final groqKey = dotenv.env['GROQ_API_KEY'];
      final openRouterKey = dotenv.env['OPENROUTER_API_KEY'];
      final hasGroq = groqKey != null && groqKey.isNotEmpty;
      final hasOpenRouter = openRouterKey != null && openRouterKey.isNotEmpty && openRouterKey != 'sk-or-v1-placeholder';

      // Test the main chatWithAI method
      const testMessage = 'Hello, I am testing the AI service for farming advice.';
      final response = await AIService.chatWithAI(testMessage, 'test_user');

      bool hasResponse = response.isNotEmpty && !response.contains('error') && !response.contains('failed');
      bool isFallback = response.contains('practical farming advice') || response.contains('consult local');

      return {
        'status': hasResponse ? 'passed' : 'warning',
        'message': hasResponse
            ? (isFallback ? 'AI service using intelligent fallback responses' : 'AI service working with live API')
            : 'AI service not responding',
        'details': {
          'groq_configured': hasGroq,
          'openrouter_configured': hasOpenRouter,
          'response_length': response.length,
          'is_fallback_response': isFallback,
          'current_provider': AIService.currentProvider,
          'sample_response': response.substring(0, min(100, response.length)),
        },
      };
    } catch (e) {
      return {
        'status': 'failed',
        'message': 'AI service completely failed',
        'error': e.toString(),
      };
    }
  }

  static int min(int a, int b) => a < b ? a : b;

  static Future<Map<String, dynamic>> _testNotificationService() async {
    try {
      debugPrint('Testing notification service...');

      // Test initialization
      await NotificationService.initialize();

      // Test basic functionality (without actual notifications)
      await NotificationService.cancelAllNotifications();

      return {
        'status': 'passed',
        'message': 'Notification service initialized',
        'details': {
          'initialized': true,
          'cancel_all_called': true,
        },
      };
    } catch (e) {
      return {
        'status': 'failed',
        'message': 'Notification service failed',
        'error': e.toString(),
      };
    }
  }

  // Helper method to display test results
  static void printTestResults(Map<String, dynamic> results) {
    debugPrint('\n=== API TEST RESULTS ===');
    debugPrint('Overall Status: ${results['overall_status']}');
    debugPrint('Timestamp: ${results['timestamp']}');

    results['tests'].forEach((service, result) {
      debugPrint('\n--- $service ---');
      debugPrint('Status: ${result['status']}');
      debugPrint('Message: ${result['message']}');
      if (result.containsKey('error')) {
        debugPrint('Error: ${result['error']}');
      }
      if (result.containsKey('details')) {
        result['details'].forEach((key, value) {
          debugPrint('  $key: $value');
        });
      }
    });
    debugPrint('\n=== END TEST RESULTS ===');
  }
}