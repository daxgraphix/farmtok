import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<WeatherData> getCurrentWeather(double lat, double lon) async {
    final apiKey = dotenv.env['OPENWEATHERMAP_API_KEY'];
    if (apiKey == null) throw Exception('OPENWEATHERMAP_API_KEY not found');

    final url = '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherData.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  static Future<List<ForecastDay>> get7DayForecast(double lat, double lon) async {
    final apiKey = dotenv.env['OPENWEATHERMAP_API_KEY'];
    if (apiKey == null) throw Exception('OPENWEATHERMAP_API_KEY not found');

    final url = '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final forecasts = data['list'] as List;

      // Group by day and take first forecast for each day
      Map<String, dynamic> dailyForecasts = {};
      for (var forecast in forecasts) {
        final date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
        final dateKey = '${date.year}-${date.month}-${date.day}';

        if (!dailyForecasts.containsKey(dateKey)) {
          dailyForecasts[dateKey] = {
            'date': date,
            'minTemp': forecast['main']['temp_min'],
            'maxTemp': forecast['main']['temp_max'],
            'condition': forecast['weather'][0]['main'],
            'rainProb': (forecast['pop'] ?? 0) * 100,
          };
        } else {
          // Update min/max temps
          dailyForecasts[dateKey]['minTemp'] =
              (dailyForecasts[dateKey]['minTemp'] as double)
                  .clamp(0, forecast['main']['temp_min']);
          dailyForecasts[dateKey]['maxTemp'] =
              (dailyForecasts[dateKey]['maxTemp'] as double)
                  .clamp(forecast['main']['temp_max'], double.infinity);
        }
      }

      return dailyForecasts.values.map((f) => ForecastDay(
        date: f['date'],
        minTemp: f['minTemp'],
        maxTemp: f['maxTemp'],
        condition: f['condition'],
        rainfallProbability: f['rainProb'],
      )).toList();
    } else {
      throw Exception('Failed to load forecast data');
    }
  }

  static Future<Map<String, dynamic>> getWeatherAlerts(double lat, double lon) async {
    // Get current weather and forecast to generate smart alerts
    try {
      final current = await getCurrentWeather(lat, lon);
      final forecast = await get7DayForecast(lat, lon);

      return {
        'safe_for_spraying': current.isSafeForSpraying,
        'high_fungal_risk': current.highFungalRisk,
        'should_delay_spraying': current.shouldDelaySpraying,
        'current': current,
        'forecast': forecast,
      };
    } catch (e) {
      return {
        'safe_for_spraying': true,
        'high_fungal_risk': false,
        'should_delay_spraying': false,
        'error': e.toString(),
      };
    }
  }
}