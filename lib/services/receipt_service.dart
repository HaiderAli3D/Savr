import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../openai/openai_config.dart';
import '../data/models.dart';
import 'receipt_exceptions.dart';

class ReceiptService {
  Future<SavingsReport> analyzeReceipt(String imageBase64, UserPreferences prefs) async {
    // Check if Firebase Function is configured
    if (!OpenAIConfig.isConfigured) {
      throw ApiNotConfiguredException();
    }

    try {
      // Call Firebase Function instead of OpenAI directly
      final response = await http.post(
        OpenAIConfig.analyzeReceiptUri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'imageBase64': imageBase64,
          'preferences': {
            'sulfateFree': prefs.sulfateFree,
            'organicOnly': prefs.organicOnly,
            'noBrandSwaps': prefs.noBrandSwaps,
            'vegetarian': prefs.vegetarian,
            'glutenFree': prefs.glutenFree,
            'budgetFocus': prefs.budgetFocus,
          },
        }),
      );

      // Handle non-200 status codes
      if (response.statusCode != 200) {
        debugPrint('Firebase Function Error (${response.statusCode}): ${response.body}');
        throw ApiException(response.statusCode, 'Function request failed', response.body);
      }

      // Parse the response - Firebase Function returns the JSON directly
      try {
        final jsonResult = jsonDecode(utf8.decode(response.bodyBytes));
        return _parseReport(jsonResult);
      } catch (e) {
        debugPrint('Error parsing function response: $e');
        throw ParsingException('Failed to parse function response', e);
      }
    } on SocketException catch (e) {
      debugPrint('Network error: $e');
      throw NetworkException('Network error. Please check your internet connection.', e);
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw NetworkException('HTTP error occurred', e);
    } on FormatException catch (e) {
      debugPrint('Format error: $e');
      throw ParsingException('Invalid response format from function', e);
    } on ApiNotConfiguredException {
      rethrow;
    } on ApiException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ParsingException {
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error analyzing receipt: $e');
      throw ParsingException('An unexpected error occurred while analyzing the receipt', e);
    }
  }

  SavingsReport _parseReport(Map<String, dynamic> json) {
    final subs = (json['substitutions'] as List).map((s) {
      return ComparisonItem(
        original: BasketItem(
          id: DateTime.now().toString(),
          name: s['original']['name'],
          rawName: s['original']['name'],
          price: (s['original']['price'] as num).toDouble(),
          quantity: s['original']['quantity'],
          category: s['original']['category'],
        ),
        alternative: BasketItem(
          id: DateTime.now().toString(),
          name: s['alternative']['name'],
          rawName: s['alternative']['name'],
          price: (s['alternative']['price'] as num).toDouble(),
          quantity: s['alternative']['quantity'],
          category: s['alternative']['category'],
        ),
        reason: s['reason'],
        savings: (s['savings'] as num).toDouble(),
        tags: List<String>.from(s['tags'] ?? []),
      );
    }).toList();

    return SavingsReport(
      id: UniqueKey().toString(),
      date: DateTime.now(),
      substitutions: subs,
      totalOriginalPrice: (json['totalOriginal'] as num).toDouble(),
      totalSavings: (json['totalSavings'] as num).toDouble(),
      percentageSaved: (json['percentageSaved'] as num).toDouble(),
    );
  }

}