class WeatherData {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final int uvIndex;
  final double rainfallProbability;
  final List<ForecastDay> forecast;
  final DateTime timestamp;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.rainfallProbability,
    required this.forecast,
    required this.timestamp,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] ?? 0.0).toDouble(),
      humidity: (json['main']['humidity'] ?? 0.0).toDouble(),
      windSpeed: (json['wind']['speed'] ?? 0.0).toDouble(),
      uvIndex: json['uvi'] ?? 0,
      rainfallProbability: (json['rain']?['1h'] ?? 0.0).toDouble() * 100,
      forecast: [],
      timestamp: DateTime.now(),
    );
  }

  // Smart recommendations based on weather
  bool get isSafeForSpraying => windSpeed < 15 && humidity < 80 && rainfallProbability < 40;
  bool get highFungalRisk => humidity > 80;
  bool get shouldDelaySpraying => rainfallProbability > 40;
}

class ForecastDay {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String condition;
  final double rainfallProbability;

  ForecastDay({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    required this.rainfallProbability,
  });
}