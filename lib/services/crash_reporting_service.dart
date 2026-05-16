import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class CrashReportingService {
  static const String _crashReportingEnabledKey = 'crash_reporting_enabled';
  static const String _crashesKey = 'reported_crashes';
  static const String _lastCrashKey = 'last_crash_time';

  static bool _isInitialized = false;
  static final List<CrashReport> _pendingReports = [];

  // Initialization
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final enabled = await isCrashReportingEnabled();
    if (!enabled) return;

    // Set up global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      reportCrash(
        error: details.exception,
        stackTrace: details.stack,
        context: details.context?.toString(),
        library: details.library,
      );
    };

    // Handle uncaught async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      reportCrash(
        error: error,
        stackTrace: stack,
        context: 'Uncaught async error',
      );
      return true;
    };

    _isInitialized = true;

    // Send any pending crash reports
    await _sendPendingReports();
  }

  // Settings Management
  static Future<bool> isCrashReportingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_crashReportingEnabledKey) ?? true;
  }

  static Future<void> setCrashReportingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_crashReportingEnabledKey, enabled);

    if (!enabled) {
      await clearCrashData();
    }
  }

  // Crash Reporting
  static Future<void> reportCrash({
    required dynamic error,
    StackTrace? stackTrace,
    String? context,
    String? library,
    Map<String, dynamic>? additionalData,
  }) async {
    final enabled = await isCrashReportingEnabled();
    if (!enabled) return;

    final crashReport = CrashReport(
      error: error.toString(),
      stackTrace: stackTrace?.toString(),
      context: context,
      library: library,
      timestamp: DateTime.now(),
      additionalData: additionalData ?? {},
      deviceInfo: await _getDeviceInfo(),
    );

    _pendingReports.add(crashReport);

    // Store crash locally
    await _storeCrashLocally(crashReport);

    // In debug mode, print the crash
    if (kDebugMode) {
      print('Crash reported'); // ignore: avoid_print
    }

    // Try to send immediately if we have internet
    await _sendPendingReports();
  }

  static Future<void> _storeCrashLocally(CrashReport crashReport) async {
    final prefs = await SharedPreferences.getInstance();
    final crashesJson = prefs.getString(_crashesKey);
    List<dynamic> crashes = [];

    if (crashesJson != null) {
      try {
        crashes = jsonDecode(crashesJson);
      } catch (e) {
        crashes = [];
      }
    }

    crashes.add(crashReport.toJson());

    // Keep only last 50 crashes
    if (crashes.length > 50) {
      crashes = crashes.skip(crashes.length - 50).toList();
    }

    await prefs.setString(_crashesKey, jsonEncode(crashes));
    await prefs.setString(_lastCrashKey, DateTime.now().toIso8601String());
  }

  static Future<void> _sendPendingReports() async {
    if (_pendingReports.isEmpty) return;

    try {
      // In a real implementation, you would send to your crash reporting service
      // For now, we'll simulate sending
      for (final report in _pendingReports) {
        await _sendCrashReport(report);
      }

      _pendingReports.clear();

      // Clear sent reports from local storage
      await _clearSentReports();
    } catch (e) {
      // Keep reports for next attempt
    }
  }

  static Future<void> _sendCrashReport(CrashReport report) async {
    // Simulate network request
    await Future.delayed(const Duration(milliseconds: 100));

    if (kDebugMode) {
      print('📤 Sending crash report: ${report.error}');
    }

    // In a real implementation:
    // await http.post(
    //   Uri.parse('https://your-crash-reporting-service.com/api/crashes'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(report.toJson()),
    // );
  }

  static Future<void> _clearSentReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_crashesKey);
  }

  // Device Information
  static Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': Platform.operatingSystem,
      'platform_version': Platform.operatingSystemVersion,
      'app_version': '1.0.0',
      'build_number': '1',
      'dart_version': Platform.version,
    };
  }

  // Crash Data Management
  static Future<List<CrashReport>> getCrashHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final crashesJson = prefs.getString(_crashesKey);

    if (crashesJson == null) return [];

    try {
      final crashesData = jsonDecode(crashesJson) as List;
      return crashesData.map((data) => CrashReport.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearCrashData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_crashesKey);
    await prefs.remove(_lastCrashKey);
    _pendingReports.clear();
  }

  static Future<DateTime?> getLastCrashTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCrash = prefs.getString(_lastCrashKey);

    if (lastCrash == null) return null;

    try {
      return DateTime.parse(lastCrash);
    } catch (e) {
      return null;
    }
  }

  // Non-fatal Error Reporting
  static Future<void> reportNonFatalError({
    required String error,
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    await reportCrash(
      error: 'Non-fatal: $error',
      context: context,
      additionalData: {
        ...?additionalData,
        'fatal': false,
      },
    );
  }

  // Performance Monitoring
  static Future<void> reportPerformanceIssue({
    required String metricName,
    required double value,
    required String unit,
    Map<String, dynamic>? context,
  }) async {
    await trackEvent('performance_issue', {
      'metric_name': metricName,
      'value': value,
      'unit': unit,
      'context': context,
    });
  }

  // Custom Event Tracking (for analytics integration)
  static Future<void> trackEvent(String eventName, Map<String, dynamic> parameters) async {
    // This would integrate with your analytics service
    if (kDebugMode) {
      print('📊 Analytics Event: $eventName - $parameters');
    }
  }

  // Utility Methods
  static Future<Map<String, dynamic>> getCrashReportStats() async {
    final crashes = await getCrashHistory();
    final lastCrash = await getLastCrashTime();

    final errorTypes = <String, int>{};
    for (final crash in crashes) {
      final errorType = crash.error.split(':').first;
      errorTypes[errorType] = (errorTypes[errorType] ?? 0) + 1;
    }

    return {
      'total_crashes': crashes.length,
      'error_breakdown': errorTypes,
      'last_crash': lastCrash?.toIso8601String(),
      'pending_reports': _pendingReports.length,
    };
  }
}

class CrashReport {
  final String error;
  final String? stackTrace;
  final String? context;
  final String? library;
  final DateTime timestamp;
  final Map<String, dynamic> additionalData;
  final Map<String, dynamic> deviceInfo;

  CrashReport({
    required this.error,
    this.stackTrace,
    this.context,
    this.library,
    required this.timestamp,
    required this.additionalData,
    required this.deviceInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'stack_trace': stackTrace,
      'context': context,
      'library': library,
      'timestamp': timestamp.toIso8601String(),
      'additional_data': additionalData,
      'device_info': deviceInfo,
    };
  }

  factory CrashReport.fromJson(Map<String, dynamic> json) {
    return CrashReport(
      error: json['error'],
      stackTrace: json['stack_trace'],
      context: json['context'],
      library: json['library'],
      timestamp: DateTime.parse(json['timestamp']),
      additionalData: Map<String, dynamic>.from(json['additional_data'] ?? {}),
      deviceInfo: Map<String, dynamic>.from(json['device_info'] ?? {}),
    );
  }
}