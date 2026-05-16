import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingKey = 'has_completed_onboarding';
  static const String _firstLaunchKey = 'first_launch_date';
  static const String _userPreferencesKey = 'user_preferences';

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? true;
  }

  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, false);
    await prefs.setString(_firstLaunchKey, DateTime.now().toIso8601String());
  }

  static Future<Map<String, dynamic>> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsString = prefs.getString(_userPreferencesKey);
    if (prefsString == null) {
      return {
        'language': 'English',
        'units': 'Metric',
        'notifications_enabled': true,
        'location': null,
        'crop_types': <String>[],
      };
    }
    // Parse JSON string to map
    return {};
  }

  static Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    // Save as JSON string
    await prefs.setString(_userPreferencesKey, preferences.toString());
  }
}