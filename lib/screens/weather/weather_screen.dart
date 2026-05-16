import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/weather.dart';
import '../../core/locator.dart';
import '../../blocs/weather/weather_bloc.dart';
import '../../blocs/weather/weather_event.dart';
import '../../blocs/weather/weather_state.dart';
import '../../widgets/loading_overlay.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return BlocProvider(
        create: (_) => locator<WeatherBloc>()
          ..add(LoadWeather(-6.7924, 39.2083)), // Dar es Salaam
        child: const WeatherView(),
      );
    } catch (e) {
      debugPrint('Error creating WeatherBloc: $e');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Weather Intelligence'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Weather service unavailable',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Please check your connection and try again',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class WeatherView extends StatelessWidget {
  const WeatherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Intelligence'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is WeatherLoading,
            loadingMessage: 'Loading weather data...',
            child: _buildContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WeatherState state) {
    if (state is WeatherLoaded) {
      return _buildWeatherContent(context, state.weatherData, state.forecast);
    } else if (state is WeatherError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<WeatherBloc>().add(LoadWeather(-6.7924, 39.2083));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return const Center(child: Text('Welcome to Weather Intelligence'));
  }

  Widget _buildWeatherContent(BuildContext context, WeatherData weatherData, List<ForecastDay> forecast) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current weather card
          _buildCurrentWeatherCard(context, weatherData),
          const SizedBox(height: 24),
          // Forecast
          const Text(
            '7-Day Forecast',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...forecast.map((day) => _buildForecastCard(day)),
          const SizedBox(height: 24),
          // Smart recommendations
          _buildRecommendations(context, weatherData),
        ],
      ),
    );
  }

  Widget _buildCurrentWeatherCard(BuildContext context, WeatherData weatherData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Conditions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${weatherData.temperature.toStringAsFixed(1)}°C',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherMetric('Humidity', '${weatherData.humidity.toStringAsFixed(0)}%', Icons.opacity),
                _buildWeatherMetric('Wind', '${weatherData.windSpeed.toStringAsFixed(1)} km/h', Icons.air),
                _buildWeatherMetric('UV Index', weatherData.uvIndex.toString(), Icons.wb_sunny),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildForecastCard(ForecastDay day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.wb_cloudy),
        title: Text('${day.date.day}/${day.date.month}'),
        subtitle: Text('${day.minTemp.toStringAsFixed(0)}° - ${day.maxTemp.toStringAsFixed(0)}°'),
        trailing: Text('${day.rainfallProbability.toStringAsFixed(0)}% rain'),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, WeatherData weatherData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Smart Farming Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecommendation(
              'Safe for Spraying',
              weatherData.isSafeForSpraying,
              weatherData.isSafeForSpraying ? Icons.check_circle : Icons.warning,
              weatherData.isSafeForSpraying ? Colors.green : Colors.orange,
            ),
            _buildRecommendation(
              'High Fungal Risk',
              weatherData.highFungalRisk,
              weatherData.highFungalRisk ? Icons.warning : Icons.check_circle,
              weatherData.highFungalRisk ? Colors.red : Colors.green,
            ),
            _buildRecommendation(
              'Delay Spraying',
              weatherData.shouldDelaySpraying,
              weatherData.shouldDelaySpraying ? Icons.cloud : Icons.wb_sunny,
              weatherData.shouldDelaySpraying ? Colors.blue : Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendation(String title, bool condition, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$title: ${condition ? 'Yes' : 'No'}',
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}