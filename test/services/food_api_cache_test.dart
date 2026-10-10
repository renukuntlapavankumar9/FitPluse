// ============================================================================
// FitPulse Mobile App — Food API In-Memory Performance Cache Test Suite
// Week 5: Comprehensive Testing and App Optimization
// Verifies TTL expiration, hit count tracking, memory reuse, and latency savings
// ============================================================================

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:fitpulse_app/core/services/food_api_service.dart';

class MockHttpClientWithCounter extends http.BaseClient {
  int callCount = 0;
  final String responseBody;
  final int statusCode;

  MockHttpClientWithCounter({
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
  group('FoodApiService In-Memory Cache Optimization Tests', () {
    const mockJson = '''
    {
      "count": 1,
      "page": 1,
      "page_size": 1,
      "products": [
        {
          "_id": "cache-001",
          "product_name": "Organic Steel Cut Oats",
          "brands": "Bob's Red Mill",
          "nutriments": {
            "energy-kcal_100g": 379.0,
            "proteins_100g": 13.0,
            "carbohydrates_100g": 68.0,
            "fat_100g": 6.5,
            "fiber_100g": 10.0
          },
          "nutriscore_grade": "a"
        }
      ]
    }
    ''';

    test('TC-OPT-001: Returns cached food items on repeated queries without invoking HTTP client', () async {
      final mockClient = MockHttpClientWithCounter(responseBody: mockJson);
      final api = FoodApiService(client: mockClient);

      // First query triggers network
      final firstResult = await api.searchFood('oats');
      expect(firstResult.length, 1);
      expect(mockClient.callCount, 1);

      // Second query for identical terms should hit memory cache (<1ms)
      final secondResult = await api.searchFood('oats');
      expect(secondResult.length, 1);
      expect(secondResult.first.name, 'Organic Steel Cut Oats');
      expect(mockClient.callCount, 1); // No new network call!
    });

    test('TC-OPT-002: Accurately increments cache hits and tracks hit ratio', () async {
      final mockClient = MockHttpClientWithCounter(responseBody: mockJson);
      final api = FoodApiService(client: mockClient);

      await api.searchFood('oats'); // Miss (1)
      await api.searchFood('oats'); // Hit (1)
      await api.searchFood('oats'); // Hit (2)

      final stats = api.cacheStats;
      expect(stats['cachedEntries'], 1);
      expect(stats['cacheHits'], 2);
      expect(stats['cacheMisses'], 1);
      expect(stats['hitRatio'], closeTo(2 / 3, 0.01));
    });

    test('TC-OPT-003: Query normalization is case-insensitive and trims whitespace', () async {
      final mockClient = MockHttpClientWithCounter(responseBody: mockJson);
      final api = FoodApiService(client: mockClient);

      await api.searchFood('  OATS  ');
      await api.searchFood('oats');
      await api.searchFood('Oats');

      expect(mockClient.callCount, 1);
      expect(api.cacheStats['cacheHits'], 2);
    });

    test('TC-OPT-004: Respects TTL expiration and queries fresh data when cache expires', () async {
      final mockClient = MockHttpClientWithCounter(responseBody: mockJson);
      // Construct API with short 10ms TTL for testing
      final api = FoodApiService(
        client: mockClient,
        cacheTtl: const Duration(milliseconds: 10),
      );

      await api.searchFood('oats');
      expect(mockClient.callCount, 1);

      // Wait 25ms to exceed TTL
      await Future.delayed(const Duration(milliseconds: 25));

      await api.searchFood('oats');
      expect(mockClient.callCount, 2); // Evicted & refreshed!
    });

    test('TC-OPT-005: clearCache flushes memory entries and resets statistics', () async {
      final mockClient = MockHttpClientWithCounter(responseBody: mockJson);
      final api = FoodApiService(client: mockClient);

      await api.searchFood('oats');
      expect(api.cacheStats['cachedEntries'], 1);

      api.clearCache();
      expect(api.cacheStats['cachedEntries'], 0);
      expect(api.cacheStats['cacheHits'], 0);
      expect(api.cacheStats['cacheMisses'], 0);

      await api.searchFood('oats');
      expect(mockClient.callCount, 2);
    });
  });
}
