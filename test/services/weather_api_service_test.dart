// ============================================================================
// FitPulse Mobile App — Weather API Service Unit Tests
// Week 4: API Integration and Asynchronous Data Handling
// Validates: Open-Meteo REST API retrieval, status code validation, and error recovery
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:fitpulse_app/core/services/weather_api_service.dart';
import 'package:fitpulse_app/core/services/api_exception.dart';

class MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) handler;

  MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
    );
  }
}

void main() {
  group('WeatherApiService Tests', () {
    test('TC-API-009: Retrieves and parses weather forecast on HTTP 200 OK', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.url.host, equals('api.open-meteo.com'));
        final mockJson = {
          'current': {
            'temperature_2m': 27.5,
            'apparent_temperature': 29.0,
            'relative_humidity_2m': 55,
            'wind_speed_10m': 10.5,
            'weather_code': 0,
          }
        };
        return http.Response(json.encode(mockJson), 200, headers: {'content-type': 'application/json'});
      });

      final service = WeatherApiService(client: mockClient);
      final forecast = await service.fetchOutdoorTrainingConditions(cityName: 'Hyderabad');

      expect(forecast.cityName, equals('Hyderabad'));
      expect(forecast.temperature, equals(27.5));
      expect(forecast.apparentTemperature, equals(29.0));
      expect(forecast.relativeHumidity, equals(55));
      expect(forecast.windSpeed, equals(10.5));
      expect(forecast.weatherCode, equals(0));
      expect(forecast.conditionText, contains('Clear Sky'));
    });

    test('TC-API-010: Handles HTTP 503 Service Unavailable gracefully with ServerException', () async {
      final mockClient = MockHttpClient((request) async {
        return http.Response('Service Unavailable', 503);
      });

      final service = WeatherApiService(client: mockClient);

      expect(
        () => service.fetchOutdoorTrainingConditions(),
        throwsA(isA<ServerException>().having((e) => e.statusCode, 'statusCode', 503)),
      );
    });

    test('TC-API-011: Handles connection timeout with ApiTimeoutException', () async {
      final mockClient = MockHttpClient((request) async {
        throw TimeoutException('Request timed out');
      });

      final service = WeatherApiService(client: mockClient);

      expect(
        () => service.fetchOutdoorTrainingConditions(),
        throwsA(isA<ApiTimeoutException>()),
      );
    });

    test('TC-API-012: Handles SocketException network loss with NetworkException', () async {
      final mockClient = MockHttpClient((request) async {
        throw const SocketException('No route to host');
      });

      final service = WeatherApiService(client: mockClient);

      expect(
        () => service.fetchOutdoorTrainingConditions(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('TC-API-013: Fallback weather returns reliable training conditions', () {
      final service = WeatherApiService();
      final fallback = service.getOfflineFallbackWeather(cityName: 'Mumbai');

      expect(fallback.cityName, equals('Mumbai'));
      expect(fallback.temperature, equals(28.5));
      expect(fallback.trainingSafetyAdvisory, isNotEmpty);
    });
  });
}

