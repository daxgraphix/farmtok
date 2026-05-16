abstract class WeatherEvent {}

class LoadWeather extends WeatherEvent {
  final double lat;
  final double lon;

  LoadWeather(this.lat, this.lon);
}

class LoadWeatherAlerts extends WeatherEvent {
  final double lat;
  final double lon;

  LoadWeatherAlerts(this.lat, this.lon);
}