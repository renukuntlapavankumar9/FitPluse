// ============================================================================
// FitPulse Mobile App — Outdoor Training Weather REST API Service
// Week 4: API Integration and Asynchronous Data Handling
// Endpoint: Open-Meteo Global Meteorological Forecast (No API key required)
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/weather_forecast_model.dart';
import 'api_exception.dart';

class CityCoordinates {
  final String name;
  final double latitude;
  final double longitude;

  const CityCoordinates({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class WeatherApiService {
  final http.Client _client;
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const Duration _defaultTimeout = Duration(seconds: 8);

  // Pre-configured fitness training hubs
  static const List<CityCoordinates> popularCities = [
    CityCoordinates(name: 'Hyderabad', latitude: 17.3850, longitude: 78.4867),
    CityCoordinates(name: 'Bengaluru', latitude: 12.9716, longitude: 77.5946),
    CityCoordinates(name: 'Mumbai', latitude: 19.0760, longitude: 72.8777),
    CityCoordinates(name: 'New Delhi', latitude: 28.6139, longitude: 77.2090),
    CityCoordinates(name: 'London', latitude: 51.5074, longitude: -0.1278),
    CityCoordinates(name: 'New York', latitude: 40.7128, longitude: -74.0060),
    CityCoordinates(name: 'Tokyo', latitude: 35.6762, longitude: 139.6503),
  ];

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Asynchronously fetches outdoor meteorological conditions for athletic training.
  /// 
  /// - [latitude]: Geographical latitude coordinate
  /// - [longitude]: Geographical longitude coordinate
  /// - [cityName]: Display name of the city
  Future<WeatherForecast> fetchOutdoorTrainingConditions({
    double latitude = 17.3850,
    double longitude = 78.4867,
    String cityName = 'Hyderabad',
  }) async {
    final uri = Uri.parse(
      '$_baseUrl?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
    );

    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'User-Agent': 'FitPulseApp-Flutter-Weather-Module/1.0',
              'Accept': 'application/json',
            },
          )
          .timeout(_defaultTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse;
        try {
          jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        } catch (e) {
          throw ParsingException('Received invalid meteorological JSON data.', originalError: e);
        }

        return WeatherForecast.fromJson(jsonResponse, cityName: cityName);
      } else {
        throw ServerException(
          'Weather service returned HTTP error code ${response.statusCode}.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw NetworkException(
        'Unable to reach weather satellite server. Please check internet access.',
        originalError: e,
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        'Client network exception occurred during weather lookup.',
        originalError: e,
      );
    } on TimeoutException catch (e) {
      throw ApiTimeoutException(
        'Weather retrieval timed out after ${_defaultTimeout.inSeconds} seconds.',
        originalError: e,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Unexpected error fetching environmental training conditions: $e',
        originalError: e,
      );
    }
  }

  /// Offline default conditions when network is disconnected
  WeatherForecast getOfflineFallbackWeather({String cityName = 'Hyderabad'}) {
    return WeatherForecast(
      cityName: cityName,
      temperature: 28.5,
      apparentTemperature: 29.8,
      relativeHumidity: 58,
      windSpeed: 11.2,
      weatherCode: 1,
      timestamp: DateTime.now(),
    );
  }
}

