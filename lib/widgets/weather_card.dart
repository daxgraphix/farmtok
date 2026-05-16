import 'package:flutter/material.dart';
import '../../models/weather.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  WeatherData? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    // TODO: Integrate with weather service
    // For now, show mock data
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _weatherData = WeatherData(
        temperature: 28.5,
        humidity: 65.0,
        windSpeed: 12.0,
        uvIndex: 7,
        rainfallProbability: 15.0,
        forecast: [],
        timestamp: DateTime.now(),
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weather Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadWeather,
                  color: const Color(0xFF2E7D32),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_weatherData != null)
              Row(
                children: [
                  // Weather icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.wb_sunny,
                      size: 32,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Weather details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_weatherData!.temperature.toStringAsFixed(1)}°C',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        Text(
                          'Sunny with light winds',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Additional info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildWeatherInfo('Humidity', '${_weatherData!.humidity.toStringAsFixed(0)}%'),
                      const SizedBox(height: 4),
                      _buildWeatherInfo('Wind', '${_weatherData!.windSpeed.toStringAsFixed(1)} km/h'),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 16),
            // Safety indicators
            Row(
              children: [
                _buildSafetyIndicator(
                  'Safe for spraying',
                  _weatherData?.isSafeForSpraying ?? true,
                  Icons.check_circle,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildSafetyIndicator(
                  'Low fungal risk',
                  !(_weatherData?.highFungalRisk ?? false),
                  Icons.warning,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyIndicator(String text, bool isSafe, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isSafe ? Colors.green : color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isSafe ? Colors.green : color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}