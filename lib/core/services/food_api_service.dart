// ============================================================================
// FitPulse Mobile App — Food & Nutrition Public REST API Service
// Week 4: API Integration and Asynchronous Data Handling
// Endpoint: Open Food Facts Public Database (No authentication required)
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/food_item_model.dart';
import 'api_exception.dart';

class FoodApiService {
  final http.Client _client;
  static const String _primaryBaseUrl = 'https://world.openfoodfacts.net';
  static const String _backupBaseUrl = 'https://world.openfoodfacts.org';
  static const Duration _defaultTimeout = Duration(seconds: 8);

  FoodApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Asynchronously searches Open Food Facts database by query string.
  /// 
  /// - [query]: Search terms (e.g., 'oats', 'chicken breast', 'protein bar')
  /// - [pageSize]: Number of items to retrieve (default: 12)
  /// 
  /// Returns a Future list of parsed [FoodItem] domain models.
  /// Throws typed [ApiException] subclasses on network, timeout, or parsing faults.
  Future<List<FoodItem>> searchFood(String query, {int pageSize = 12}) async {
    final sanitizedQuery = query.trim();
    if (sanitizedQuery.isEmpty) {
      return [];
    }

    // Try primary high-availability CDN endpoint first, fallback to backup
    for (final baseUrl in [_primaryBaseUrl, _backupBaseUrl]) {
      final uri = Uri.parse(
        '$baseUrl/cgi/search.pl?search_terms=${Uri.encodeComponent(sanitizedQuery)}&search_simple=1&action=process&json=1&page_size=$pageSize',
      );

      try {
        final response = await _client
            .get(
              uri,
              headers: {
                'User-Agent': 'FitPulseApp-Flutter-Week4-Submission/1.0 (https://github.com/renukuntlapavankumar9/FitPluse)',
                'Accept': 'application/json',
              },
            )
            .timeout(_defaultTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse;
        try {
          jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        } catch (e) {
          throw ParsingException('Received invalid or non-JSON data from food database.', originalError: e);
        }

        final productsJson = jsonResponse['products'] as List<dynamic>? ?? [];
        
        // Parse and filter out records without meaningful names
        final List<FoodItem> items = [];
        for (final p in productsJson) {
          if (p is Map<String, dynamic>) {
            final item = FoodItem.fromJson(p);
            if (item.name != 'Unnamed Fitness Food' || item.caloriesPer100g > 0) {
              items.add(item);
            }
          }
        }
        return items;
        } else if (response.statusCode >= 500) {
          if (baseUrl == _backupBaseUrl) {
            throw ServerException(
              'Open Food Facts server is currently experiencing issues (${response.statusCode}).',
              statusCode: response.statusCode,
            );
          }
        } else {
          if (baseUrl == _backupBaseUrl) {
            throw ServerException(
              'Failed to retrieve food items. Server returned HTTP ${response.statusCode}.',
              statusCode: response.statusCode,
            );
          }
        }
      } on SocketException catch (e) {
        if (baseUrl == _backupBaseUrl) {
          throw NetworkException(
            'No active internet connection. Please verify your WiFi or mobile network.',
            originalError: e,
          );
        }
      } on http.ClientException catch (e) {
        if (baseUrl == _backupBaseUrl) {
          throw NetworkException(
            'Network communication error occurred while contacting food database.',
            originalError: e,
          );
        }
      } on TimeoutException catch (e) {
        if (baseUrl == _backupBaseUrl) {
          throw ApiTimeoutException(
            'Food database connection timed out after ${_defaultTimeout.inSeconds} seconds.',
            originalError: e,
          );
        }
      } on ApiException {
        if (baseUrl == _backupBaseUrl) rethrow;
      } catch (e) {
        if (baseUrl == _backupBaseUrl) {
          throw ApiException(
            'Unexpected error during asynchronous food data retrieval: $e',
            originalError: e,
          );
        }
      }
    }
    return getOfflineFallbackFoods();
  }

  /// Curated offline fallback nutrition database
  /// Enables complete functionality even without internet connectivity
  List<FoodItem> getOfflineFallbackFoods() {
    return const [
      FoodItem(
        id: 'mock-01',
        name: 'Whole Rolled Oats',
        brand: 'Quaker Fitness',
        caloriesPer100g: 389.0,
        proteinPer100g: 16.9,
        carbsPer100g: 66.3,
        fatPer100g: 6.9,
        fiberPer100g: 10.6,
        nutriScore: 'a',
      ),
      FoodItem(
        id: 'mock-02',
        name: 'Boneless Chicken Breast',
        brand: 'Fresh Farm Meat',
        caloriesPer100g: 165.0,
        proteinPer100g: 31.0,
        carbsPer100g: 0.0,
        fatPer100g: 3.6,
        fiberPer100g: 0.0,
        nutriScore: 'a',
      ),
      FoodItem(
        id: 'mock-03',
        name: 'Whey Protein Isolate 90%',
        brand: 'Optimum Nutrition Gold',
        caloriesPer100g: 375.0,
        proteinPer100g: 82.5,
        carbsPer100g: 4.5,
        fatPer100g: 1.5,
        fiberPer100g: 0.0,
        nutriScore: 'a',
      ),
      FoodItem(
        id: 'mock-04',
        name: 'Greek Strained Yogurt (0% Fat)',
        brand: 'Chobani Pure',
        caloriesPer100g: 59.0,
        proteinPer100g: 10.2,
        carbsPer100g: 3.6,
        fatPer100g: 0.4,
        fiberPer100g: 0.0,
        nutriScore: 'a',
      ),
      FoodItem(
        id: 'mock-05',
        name: 'Fresh Cavendish Banana',
        brand: 'Organic Produce',
        caloriesPer100g: 89.0,
        proteinPer100g: 1.1,
        carbsPer100g: 22.8,
        fatPer100g: 0.3,
        fiberPer100g: 2.6,
        nutriScore: 'a',
      ),
      FoodItem(
        id: 'mock-06',
        name: 'Raw California Almonds',
        brand: 'Natural Harvest',
        caloriesPer100g: 579.0,
        proteinPer100g: 21.2,
        carbsPer100g: 21.6,
        fatPer100g: 49.9,
        fiberPer100g: 12.5,
        nutriScore: 'b',
      ),
      FoodItem(
        id: 'mock-07',
        name: 'Whole Brown Eggs (Boiled)',
        brand: 'Pasture Raised Eggs',
        caloriesPer100g: 155.0,
        proteinPer100g: 13.0,
        carbsPer100g: 1.1,
        fatPer100g: 11.0,
        fiberPer100g: 0.0,
        nutriScore: 'a',
      ),
      FoodItem(
        id: 'mock-08',
        name: 'Steamed Jasmine White Rice',
        brand: 'Asian Kitchen',
        caloriesPer100g: 130.0,
        proteinPer100g: 2.7,
        carbsPer100g: 28.2,
        fatPer100g: 0.3,
        fiberPer100g: 0.4,
        nutriScore: 'b',
      ),
    ];
  }
}

