// ============================================================================
// FitPulse Mobile App — Weather Forecast Model Unit Tests
// Week 4: API Integration and Asynchronous Data Handling
// Verifies meteorological translations, WMO code parsing, and hydration rules
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:fitpulse_app/core/models/weather_forecast_model.dart';

void main() {
  group('WeatherForecast Model Tests', () {
    test('TC-MOD-006: Deserializes Open-Meteo current weather payload', () {
      final sampleJson = {
        'current': {
          'temperature_2m': 31.4,
          'apparent_temperature': 33.8,
          'relative_humidity_2m': 62,
          'wind_speed_10m': 14.2,
          'weather_code': 1,
        }
      };

      final forecast = WeatherForecast.fromJson(sampleJson, cityName: 'Hyderabad');

      expect(forecast.cityName, equals('Hyderabad'));
      expect(forecast.temperature, equals(31.4));
      expect(forecast.apparentTemperature, equals(33.8));
      expect(forecast.relativeHumidity, equals(62));
      expect(forecast.windSpeed, equals(14.2));
      expect(forecast.weatherCode, equals(1));
      expect(forecast.conditionText, contains('Partly Cloudy'));
    });

    test('TC-MOD-007: Evaluates heat advisory and hydration recommendation', () {
      final hotWeatherJson = {
        'current': {
          'temperature_2m': 38.0,
          'apparent_temperature': 41.5,
          'relative_humidity_2m': 40,
          'wind_speed_10m': 5.0,
          'weather_code': 0,
        }
      };

      final forecast = WeatherForecast.fromJson(hotWeatherJson);
      expect(forecast.trainingSafetyAdvisory, contains('Extreme Heat Alert'));
      expect(forecast.suggestedExtraHydrationMl, equals(800));
    });

    test('TC-MOD-008: Evaluates precipitation condition advisory', () {
      final rainyWeatherJson = {
        'current': {
          'temperature_2m': 22.0,
          'apparent_temperature': 22.0,
          'relative_humidity_2m': 90,
          'wind_speed_10m': 18.0,
          'weather_code': 63, // Moderate Rain
        }
      };

      final forecast = WeatherForecast.fromJson(rainyWeatherJson);
      expect(forecast.conditionText, contains('Rain'));
      expect(forecast.trainingSafetyAdvisory, contains('Precipitation Alert'));
    });
  });
}

