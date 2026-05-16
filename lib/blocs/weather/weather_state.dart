import '../../models/weather.dart';

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final WeatherData weatherData;
  final List<ForecastDay> forecast;

  WeatherLoaded(this.weatherData, this.forecast);
}

class WeatherAlertsLoaded extends WeatherState {
  final Map<String, dynamic> alerts;

  WeatherAlertsLoaded(this.alerts);
}

class WeatherError extends WeatherState {
  final String message;

  WeatherError(this.message);
}