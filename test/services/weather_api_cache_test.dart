// ============================================================================
// FitPulse Mobile App — Weather API In-Memory Performance Cache Test Suite
// Week 5: Comprehensive Testing and App Optimization
// Verifies coordinate caching, hit tracking, and forecast reuse
// ============================================================================

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:fitpulse_app/core/services/weather_api_service.dart';

class MockWeatherHttpClientWithCounter extends http.BaseClient {
  int callCount = 0;
  final String responseBody;
  final int statusCode;

  MockWeatherHttpClientWithCounter({
    required this.responseBody,
    this.statusCode = 200,
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    callCount++;
    return http.StreamedResponse(
      Stream.value(utf8.encode(responseBody)),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

void main() {
  group('WeatherApiService In-Memory Cache Optimization Tests', () {
    const mockWeatherJson = '''
    {
      "latitude": 17.385,
      "longitude": 78.4867,
      "current": {
        "time": "2026-10-10T06:00",
        "temperature_2m": 26.5,
        "relative_humidity_2m": 62,
        "apparent_temperature": 28.0,
        "weather_code": 1,
        "wind_speed_10m": 11.2
      }
    }
    ''';

    test('TC-OPT-006: Serves subsequent weather lookups for identical coordinates from cache', () async {
      final mockClient = MockWeatherHttpClientWithCounter(responseBody: mockWeatherJson);
      final api = WeatherApiService(client: mockClient);

      final first = await api.fetchOutdoorTrainingConditions(latitude: 17.385, longitude: 78.4867);
      expect(first.temperature, 26.5);
      expect(mockClient.callCount, 1);

      final second = await api.fetchOutdoorTrainingConditions(latitude: 17.385, longitude: 78.4867);
      expect(second.temperature, 26.5);
      expect(mockClient.callCount, 1); // Served directly from memory!
      expect(api.cacheStats['cacheHits'], 1);
    });

    test('TC-OPT-007: Differentiates distinct coordinate locations and fetches independently', () async {
      final mockClient = MockWeatherHttpClientWithCounter(responseBody: mockWeatherJson);
      final api = WeatherApiService(client: mockClient);

      await api.fetchOutdoorTrainingConditions(latitude: 17.385, longitude: 78.4867, cityName: 'Hyderabad');
      await api.fetchOutdoorTrainingConditions(latitude: 12.971, longitude: 77.594, cityName: 'Bengaluru');

      expect(mockClient.callCount, 2);
      expect(api.cacheStats['cachedEntries'], 2);
    });

    test('TC-OPT-008: bypassCache parameter forces live network request', () async {
      final mockClient = MockWeatherHttpClientWithCounter(responseBody: mockWeatherJson);
      final api = WeatherApiService(client: mockClient);

      await api.fetchOutdoorTrainingConditions(latitude: 17.385, longitude: 78.4867);
      expect(mockClient.callCount, 1);

      await api.fetchOutdoorTrainingConditions(latitude: 17.385, longitude: 78.4867, bypassCache: true);
      expect(mockClient.callCount, 2);
    });

    test('TC-OPT-009: Expired weather cache queries fresh meteorological reading', () async {
      final mockClient = MockWeatherHttpClientWithCounter(responseBody: mockWeatherJson);
      final api = WeatherApiService(
        client: mockClient,
        cacheTtl: const Duration(milliseconds: 15),
      );

      await api.fetchOutdoorTrainingConditions();
      expect(mockClient.callCount, 1);

      await Future.delayed(const Duration(milliseconds: 30));

      await api.fetchOutdoorTrainingConditions();
      expect(mockClient.callCount, 2);
    });
  });
}
