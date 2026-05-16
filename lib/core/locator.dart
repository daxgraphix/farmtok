import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../services/local_cache_service.dart';
import '../services/notification_service.dart';
import '../services/weather_service.dart';
import '../repositories/weather_repository.dart';
import '../blocs/weather/weather_bloc.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Register services
  try {
    locator.registerLazySingleton(() => LocalCacheService());
    locator.registerLazySingleton(() => NotificationService);
    locator.registerLazySingleton(() => WeatherService);

    // Register repositories
    locator.registerLazySingleton<WeatherRepository>(
      () => WeatherRepositoryImpl(),
    );

    // Register blocs
    locator.registerFactory(
      () => WeatherBloc(locator<WeatherRepository>()),
    );

    debugPrint('All services registered successfully');
  } catch (e) {
    debugPrint('Error registering services: $e');
  }
}