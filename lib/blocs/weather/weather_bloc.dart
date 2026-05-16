import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/weather_repository.dart';
import '../../services/notification_service.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc(this.weatherRepository) : super(WeatherInitial()) {
    on<LoadWeather>(_onLoadWeather);
    on<LoadWeatherAlerts>(_onLoadWeatherAlerts);
  }

  Future<void> _onLoadWeather(LoadWeather event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      final weather = await weatherRepository.getCurrentWeather(event.lat, event.lon);
      final forecast = await weatherRepository.get7DayForecast(event.lat, event.lon);
      emit(WeatherLoaded(weather, forecast));

      // Check for weather alerts and send notifications
      if (weather.highFungalRisk) {
        await NotificationService.showNotification(
          title: 'High Fungal Risk Alert',
          body: 'Current weather conditions increase fungal disease risk. Consider protective measures.',
        );
      }
      if (!weather.isSafeForSpraying) {
        await NotificationService.showNotification(
          title: 'Spraying Conditions Not Optimal',
          body: 'Wind or humidity levels may affect spraying effectiveness.',
        );
      }
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> _onLoadWeatherAlerts(LoadWeatherAlerts event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      final alerts = await weatherRepository.getWeatherAlerts(event.lat, event.lon);
      emit(WeatherAlertsLoaded(alerts));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }
}