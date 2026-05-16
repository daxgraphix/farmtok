import '../models/weather.dart';
import '../services/weather_service.dart';

abstract class WeatherRepository {
  Future<WeatherData> getCurrentWeather(double lat, double lon);
  Future<List<ForecastDay>> get7DayForecast(double lat, double lon);
  Future<Map<String, dynamic>> getWeatherAlerts(double lat, double lon);
}

class WeatherRepositoryImpl implements WeatherRepository {

  @override
  Future<WeatherData> getCurrentWeather(double lat, double lon) async {
    try {
      return await WeatherService.getCurrentWeather(lat, lon);
    } catch (e) {
      throw WeatherException('Failed to fetch current weather: $e');
    }
  }

  @override
  Future<List<ForecastDay>> get7DayForecast(double lat, double lon) async {
    try {
      return await WeatherService.get7DayForecast(lat, lon);
    } catch (e) {
      throw WeatherException('Failed to fetch weather forecast: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getWeatherAlerts(double lat, double lon) async {
    try {
      return await WeatherService.getWeatherAlerts(lat, lon);
    } catch (e) {
      throw WeatherException('Failed to fetch weather alerts: $e');
    }
  }
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => message;
}