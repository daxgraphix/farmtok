import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppAnalyticsService {
  static const String _analyticsEnabledKey = 'analytics_enabled';
  static const String _sessionIdKey = 'current_session_id';
  static const String _eventsKey = 'analytics_events';
  static const String _userPropertiesKey = 'user_properties';

  static String? _currentSessionId;
  static final List<AnalyticsEvent> _pendingEvents = [];

  // Session Management
  static Future<void> startSession() async {
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionIdKey, _currentSessionId!);

    // Track session start
    await trackEvent('session_start', {
      'session_id': _currentSessionId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> endSession() async {
    if (_currentSessionId != null) {
      await trackEvent('session_end', {
        'session_id': _currentSessionId,
        'duration': DateTime.now().millisecondsSinceEpoch -
            int.parse(_currentSessionId!),
      });
    }

    _currentSessionId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionIdKey);

    // Flush pending events
    await _flushEvents();
  }

  // Event Tracking
  static Future<void> trackEvent(String eventName, [Map<String, dynamic>? parameters]) async {
    final prefs = await SharedPreferences.getInstance();
    final analyticsEnabled = prefs.getBool(_analyticsEnabledKey) ?? true;

    if (!analyticsEnabled) return;

    final event = AnalyticsEvent(
      name: eventName,
      parameters: parameters ?? {},
      timestamp: DateTime.now(),
      sessionId: _currentSessionId,
    );

    _pendingEvents.add(event);

    // Store event locally
    await _storeEventLocally(event);

    // Flush events if we have too many pending
    if (_pendingEvents.length >= 20) {
      await _flushEvents();
    }
  }

  static Future<void> _storeEventLocally(AnalyticsEvent event) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(_eventsKey);
    List<dynamic> events = [];

    if (eventsJson != null) {
      try {
        events = jsonDecode(eventsJson);
      } catch (e) {
        events = [];
      }
    }

    events.add(event.toJson());

    // Keep only last 1000 events
    if (events.length > 1000) {
      events = events.skip(events.length - 1000).toList();
    }

    await prefs.setString(_eventsKey, jsonEncode(events));
  }

  static Future<void> _flushEvents() async {
    if (_pendingEvents.isEmpty) return;

    try {
      // In a real implementation, you would send events to your analytics service
      // Clear pending events
      _pendingEvents.clear();

      // Update last flush time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_analytics_flush', DateTime.now().toIso8601String());
    } catch (e) {
      // Keep reports for next attempt
    }
  }

  // User Properties
  static Future<void> setUserProperty(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final propertiesJson = prefs.getString(_userPropertiesKey);
    Map<String, dynamic> properties = {};

    if (propertiesJson != null) {
      try {
        properties = jsonDecode(propertiesJson);
      } catch (e) {
        properties = {};
      }
    }

    properties[key] = value;
    await prefs.setString(_userPropertiesKey, jsonEncode(properties));
  }

  static Future<Map<String, dynamic>> getUserProperties() async {
    final prefs = await SharedPreferences.getInstance();
    final propertiesJson = prefs.getString(_userPropertiesKey);

    if (propertiesJson == null) return {};

    try {
      return jsonDecode(propertiesJson);
    } catch (e) {
      return {};
    }
  }

  // Common Event Trackers
  static Future<void> trackScreenView(String screenName) async {
    await trackEvent('screen_view', {
      'screen_name': screenName,
      'screen_class': screenName,
    });
  }

  static Future<void> trackUserAction(String action, [Map<String, dynamic>? parameters]) async {
    await trackEvent('user_action', {
      'action': action,
      ...?parameters,
    });
  }

  static Future<void> trackFeatureUsage(String feature) async {
    await trackEvent('feature_used', {
      'feature_name': feature,
    });
  }

  static Future<void> trackError(String errorType, String errorMessage, [StackTrace? stackTrace]) async {
    await trackEvent('app_error', {
      'error_type': errorType,
      'error_message': errorMessage,
      'stack_trace': stackTrace?.toString(),
    });
  }

  static Future<void> trackPerformanceMetric(String metricName, double value, {String? unit}) async {
    await trackEvent('performance_metric', {
      'metric_name': metricName,
      'value': value,
      'unit': unit,
    });
  }

  // Analytics Settings
  static Future<void> setAnalyticsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_analyticsEnabledKey, enabled);

    if (!enabled) {
      // Clear all analytics data when disabled
      await clearAnalyticsData();
    }
  }

  static Future<bool> isAnalyticsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_analyticsEnabledKey) ?? true;
  }

  static Future<void> clearAnalyticsData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eventsKey);
    await prefs.remove(_userPropertiesKey);
    await prefs.remove(_sessionIdKey);
    _pendingEvents.clear();
    _currentSessionId = null;
  }

  // Analytics Reports
  static Future<Map<String, dynamic>> getAnalyticsReport() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(_eventsKey);
    final propertiesJson = prefs.getString(_userPropertiesKey);

    List<dynamic> events = [];
    Map<String, dynamic> properties = {};

    if (eventsJson != null) {
      try {
        events = jsonDecode(eventsJson);
      } catch (e) {
        events = [];
      }
    }

    if (propertiesJson != null) {
      try {
        properties = jsonDecode(propertiesJson);
      } catch (e) {
        properties = {};
      }
    }

    // Generate summary statistics
    final eventCounts = <String, int>{};
    for (final event in events) {
      final eventName = event['name'] as String;
      eventCounts[eventName] = (eventCounts[eventName] ?? 0) + 1;
    }

    return {
      'total_events': events.length,
      'event_breakdown': eventCounts,
      'user_properties': properties,
      'session_count': events.where((e) => e['name'] == 'session_start').length,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // Initialize analytics
  static Future<void> initialize() async {
    final enabled = await isAnalyticsEnabled();
    if (!enabled) return;

    // Start new session
    await startSession();

    // Set default user properties
    await setUserProperty('app_version', '1.0.0');
    await setUserProperty('platform', 'android');

    // Flush any pending events from previous session
    await _flushEvents();
  }
}

class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  final String? sessionId;

  AnalyticsEvent({
    required this.name,
    required this.parameters,
    required this.timestamp,
    this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
      'session_id': sessionId,
    };
  }

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      name: json['name'],
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      timestamp: DateTime.parse(json['timestamp']),
      sessionId: json['session_id'],
    );
  }
}