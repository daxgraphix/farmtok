import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceService {
  static const String _cacheSizeKey = 'max_cache_size_mb';

  // Image optimization
  static Future<Uint8List> optimizeImage(Uint8List imageBytes, {int? quality}) async {
    // In a real implementation, you would use flutter_image_compress
    // For now, return the original bytes
    return imageBytes;
  }

  // Memory management
  static Future<void> clearImageCache() async {
    // Clear Flutter's image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  static Future<int> getCacheSize() async {
    // Return approximate cache size in MB
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cacheSizeKey) ?? 100;
  }

  // Animation optimization
  static Duration getAnimationDuration(Duration defaultDuration) {
    // This would be called with context to check for reduced motion
    return defaultDuration;
  }

  // Lazy loading helper
  static Widget buildLazyWidget(Widget Function() builder) {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 100), builder),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data as Widget;
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Database optimization
  static Future<void> optimizeDatabase() async {
    // Implement database optimization logic
    // This would include vacuum operations, index rebuilding, etc.
  }
}

class AccessibilityService {
  static const String _highContrastKey = 'high_contrast_mode';
  static const String _largeTextKey = 'large_text_mode';
  static const String _voiceInputKey = 'voice_input_enabled';
  static const String _hapticFeedbackKey = 'haptic_feedback_enabled';

  static Future<bool> isHighContrastEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_highContrastKey) ?? false;
  }

  static Future<bool> isLargeTextEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_largeTextKey) ?? false;
  }

  static Future<bool> isVoiceInputEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_voiceInputKey) ?? true;
  }

  static Future<bool> isHapticFeedbackEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticFeedbackKey) ?? true;
  }

  static Future<void> setAccessibilityPreferences({
    bool? highContrast,
    bool? largeText,
    bool? voiceInput,
    bool? hapticFeedback,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (highContrast != null) {
      await prefs.setBool(_highContrastKey, highContrast);
    }
    if (largeText != null) {
      await prefs.setBool(_largeTextKey, largeText);
    }
    if (voiceInput != null) {
      await prefs.setBool(_voiceInputKey, voiceInput);
    }
    if (hapticFeedback != null) {
      await prefs.setBool(_hapticFeedbackKey, hapticFeedback);
    }
  }

  // Get text scale factor based on accessibility settings
  static double getTextScaleFactor(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // This would check accessibility settings and return appropriate scale
    return mediaQuery.textScaler.scale(1.0);
  }

  // Haptic feedback helper
  static Future<void> triggerHapticFeedback(HapticFeedbackType type) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_hapticFeedbackKey) ?? true;

    if (!enabled) return;

    switch (type) {
      case HapticFeedbackType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        await HapticFeedback.selectionClick();
        break;
    }
  }
}

enum HapticFeedbackType { light, medium, heavy, selection }

class AccessibilityWrapper extends StatelessWidget {
  final Widget child;

  const AccessibilityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AccessibilityService.isLargeTextEnabled(),
      builder: (context, snapshot) {
        final isLargeText = snapshot.data ?? false;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(isLargeText ? 1.3 : 1.0),
          ),
          child: child,
        );
      },
    );
  }
}