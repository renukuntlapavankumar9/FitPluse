// ============================================================================
// FitPulse Mobile App — Food API Service Unit & Integration Tests
// Week 4: API Integration and Asynchronous Data Handling
// Validates: 200 OK parsing, HTTP 500/404 handling, SocketException, Timeout,
// and offline cache fallback mechanisms.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:fitpulse_app/core/services/food_api_service.dart';
import 'package:fitpulse_app/core/services/api_exception.dart';

/// Lightweight mock HTTP client leveraging http.BaseClient
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
  group('FoodApiService Tests', () {
    test('TC-API-001: Asynchronously returns parsed FoodItems on HTTP 200 OK', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.url.path, contains('/cgi/search.pl'));
        expect(request.url.queryParameters['search_terms'], equals('oats'));
        
        final mockJson = {
          'count': 1,
          'products': [
            {
              'code': '101',
              'product_name': 'Rolled Oats 500g',
              'brands': 'Quaker',
              'nutriments': {
                'energy-kcal_100g': 370.0,
                'proteins_100g': 12.0,
                'carbohydrates_100g': 60.0,
                'fat_100g': 7.0,
              },
              'nutriscore_grade': 'a',
            }
          ]
        };
        return http.Response(json.encode(mockJson), 200, headers: {'content-type': 'application/json'});
      });

      final service = FoodApiService(client: mockClient);
      final results = await service.searchFood('oats');

      expect(results.length, equals(1));
      expect(results.first.name, equals('Rolled Oats 500g'));
      expect(results.first.brand, equals('Quaker'));
      expect(results.first.caloriesPer100g, equals(370.0));
      expect(results.first.proteinPer100g, equals(12.0));
    });

    test('TC-API-002: Bypasses HTTP network call when query is empty or whitespace', () async {
      bool networkInvoked = false;
      final mockClient = MockHttpClient((request) async {
        networkInvoked = true;
        return http.Response('{}', 200);
      });

      final service = FoodApiService(client: mockClient);
      final results = await service.searchFood('   ');

      expect(results, isEmpty);
      expect(networkInvoked, isFalse);
    });

    test('TC-API-003: Throws ServerException when API responds with HTTP 500 Internal Error', () async {
      final mockClient = MockHttpClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = FoodApiService(client: mockClient);

      expect(
        () => service.searchFood('chicken'),
        throwsA(isA<ServerException>().having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('TC-API-004: Throws ServerException when API responds with HTTP 404 Not Found', () async {
      final mockClient = MockHttpClient((request) async {
        return http.Response('Not Found', 404);
      });

      final service = FoodApiService(client: mockClient);

      expect(
        () => service.searchFood('eggs'),
        throwsA(isA<ServerException>().having((e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('TC-API-005: Throws ParsingException when response payload contains invalid non-JSON', () async {
      final mockClient = MockHttpClient((request) async {
        return http.Response('<html><body>502 Bad Gateway HTML</body></html>', 200);
      });

      final service = FoodApiService(client: mockClient);

      expect(
        () => service.searchFood('protein'),
        throwsA(isA<ParsingException>()),
      );
    });

    test('TC-API-006: Throws NetworkException when client experiences connection failure', () async {
      final mockClient = MockHttpClient((request) async {
        throw const SocketException('Failed host lookup: world.openfoodfacts.org');
      });

      final service = FoodApiService(client: mockClient);

      expect(
        () => service.searchFood('banana'),
        throwsA(isA<NetworkException>().having((e) => e.message, 'message', contains('No active internet connection'))),
      );
    });

    test('TC-API-007: Throws ApiTimeoutException when HTTP request exceeds timeout duration', () async {
      final mockClient = MockHttpClient((request) async {
        throw TimeoutException('Connection timed out');
      });

      final service = FoodApiService(client: mockClient);

      expect(
        () => service.searchFood('almonds'),
        throwsA(isA<ApiTimeoutException>().having((e) => e.message, 'message', contains('timed out'))),
      );
    });

    test('TC-API-008: Offline fallback delivers verified nutritional items without network', () {
      final service = FoodApiService();
      final offlineFoods = service.getOfflineFallbackFoods();

      expect(offlineFoods, isNotEmpty);
      expect(offlineFoods.length, greaterThanOrEqualTo(6));
      expect(offlineFoods.any((f) => f.name.contains('Oats')), isTrue);
      expect(offlineFoods.any((f) => f.name.contains('Chicken')), isTrue);
    });
  });
}

