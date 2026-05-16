import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

// Services
import 'services/local_cache_service.dart';
import 'services/onboarding_service.dart';
import 'services/app_analytics_service.dart';
import 'services/crash_reporting_service.dart';
import 'services/offline_cache_service.dart';
import 'services/performance_accessibility_service.dart';
import 'services/enhanced_notification_service.dart';

// Core
import 'core/locator.dart';

// Screens
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    debugPrint('Starting FarmTok initialization...');

    // Load environment variables
    try {
      await dotenv.load();
      debugPrint('Environment variables loaded');
    } catch (e) {
      debugPrint('Could not load .env file: $e');
    }

    // Initialize all services
    await _initializeAllServices();

    // Check if first launch
    final isFirstLaunch = await OnboardingService.isFirstLaunch();

    runApp(FarmTokApp(isFirstLaunch: isFirstLaunch));
    debugPrint('App started successfully');

  } catch (e, stackTrace) {
    debugPrint('Error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');

    // Run error recovery app
    runApp(_buildErrorRecoveryApp(e.toString()));
  }
}

Future<void> _initializeAllServices() async {
  debugPrint('Initializing services...');

  // Initialize crash reporting first (for error capture)
  await CrashReportingService.initialize();
  debugPrint('Crash reporting initialized');

  // Initialize analytics
  await AppAnalyticsService.initialize();
  debugPrint('Analytics initialized');

  // Initialize notifications
  await EnhancedNotificationService.initialize();
  debugPrint('Notifications initialized');

  // Initialize local cache
  await LocalCacheService.initialize();
  debugPrint('Local cache initialized');

  // Initialize offline cache cleanup
  await OfflineCacheService.clearExpiredCache();
  debugPrint('Offline cache cleaned');

  // Initialize performance optimizations
  await PerformanceService.clearImageCache();
  debugPrint('Performance optimizations applied');

  // Setup dependency injection
  setupLocator();
  debugPrint('Dependency injection setup completed');

  // Track app launch
  await AppAnalyticsService.trackEvent('app_launch', {
    'timestamp': DateTime.now().toIso8601String(),
  });
}

Widget _buildErrorRecoveryApp(String error) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'FarmTok Initialization Failed',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  main();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class FarmTokApp extends StatelessWidget {
  final bool isFirstLaunch;

  const FarmTokApp({super.key, this.isFirstLaunch = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmTok',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2E7D32),
          secondary: Color(0xFF4CAF50),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: isFirstLaunch
          ? const OnboardingScreen()
          : const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}