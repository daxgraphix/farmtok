import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'English';

  static final Map<String, Map<String, String>> _localizedStrings = {
    'English': {
      'welcome': 'Welcome to FarmTok',
      'scan_crop': 'Scan Crop',
      'ask_ai': 'Ask AI',
      'weather': 'Weather',
      'analytics': 'Analytics',
      'profile': 'Profile',
      'healthy_plant': 'Healthy Plant',
      'disease_detected': 'Disease Detected',
      'treatment': 'Treatment',
      'prevention': 'Prevention',
      'loading': 'Loading...',
      'error': 'Error occurred',
      'retry': 'Retry',
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'settings': 'Settings',
      'language': 'Language',
      'units': 'Units',
      'notifications': 'Notifications',
      'about': 'About',
      'logout': 'Logout',
      'crop_scan': 'Crop Scan',
      'ai_assistant': 'AI Assistant',
      'weather_intelligence': 'Weather Intelligence',
      'farming_tips': 'Farming Tips',
      'recent_activity': 'Recent Activity',
      'quick_actions': 'Quick Actions',
      'good_morning': 'Good morning',
      'good_afternoon': 'Good afternoon',
      'good_evening': 'Good evening',
    },
    'Swahili': {
      'welcome': 'Karibu FarmTok',
      'scan_crop': 'Chambua Mazao',
      'ask_ai': 'Uliza AI',
      'weather': 'Hali ya Hewa',
      'analytics': 'Uchambuzi',
      'profile': 'Wasifu',
      'healthy_plant': 'Mimea Yenye Afya',
      'disease_detected': 'Ugonjwa Umebainika',
      'treatment': 'Matibabu',
      'prevention': 'Kinga',
      'loading': 'Inapakia...',
      'error': 'Hitilafu imetokea',
      'retry': 'Jaribu tena',
      'save': 'Hifadhi',
      'cancel': 'Ghairi',
      'confirm': 'Thibitisha',
      'settings': 'Mipangilio',
      'language': 'Lugha',
      'units': 'Vipimo',
      'notifications': 'Taarifa',
      'about': 'Kuhusu',
      'logout': 'Toka',
      'crop_scan': 'Uchunguzi wa Mazao',
      'ai_assistant': 'Msaidizi wa AI',
      'weather_intelligence': 'Ujuzi wa Hali ya Hewa',
      'farming_tips': 'Vidokezo vya Kilimo',
      'recent_activity': 'Shughuli za Hivi Karibuni',
      'quick_actions': 'Vitendo vya Haraka',
      'good_morning': 'Habari za asubuhi',
      'good_afternoon': 'Habari za mchana',
      'good_evening': 'Habari za jioni',
    },
  };

  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  static String translate(String key, {String? language}) {
    final currentLang = language ?? _defaultLanguage;
    final translations = _localizedStrings[currentLang] ?? _localizedStrings[_defaultLanguage]!;

    return translations[key] ?? key;
  }

  static List<String> getSupportedLanguages() {
    return _localizedStrings.keys.toList();
  }

  static bool isLanguageSupported(String language) {
    return _localizedStrings.containsKey(language);
  }

  // Helper method to get localized text with fallback
  static String getText(String key, BuildContext context) {
    // In a real implementation, this would use the current locale
    // For now, we'll use the stored preference
    return translate(key);
  }
}

// Extension for easy localization
extension LocalizationExtension on String {
  String tr({String? language}) {
    return LocalizationService.translate(this, language: language);
  }
}

// Localized Text Widget
class LocalizedText extends StatelessWidget {
  final String textKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const LocalizedText(
    this.textKey, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: LocalizationService.getCurrentLanguage(),
      builder: (context, snapshot) {
        final language = snapshot.data ?? 'English';
        final text = LocalizationService.translate(textKey, language: language);

        return Text(
          text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}