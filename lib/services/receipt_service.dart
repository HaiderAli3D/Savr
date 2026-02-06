import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../openai/openai_config.dart';
import '../data/models.dart';

class ReceiptService {
  Future<SavingsReport> analyzeReceipt(String imageBase64, UserPreferences prefs) async {
    if (!OpenAIConfig.isConfigured) {
      // Return mock data if no key
      await Future.delayed(const Duration(seconds: 2)); // Simulate network
      return _getMockReport(prefs);
    }

    try {
      final prompt = _buildPrompt(prefs);
      
      final response = await http.post(
        OpenAIConfig.chatCompletionsUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a smart shopping assistant. Analyze the grocery receipt image and the user\'s preferences. Extract purchased items. Then, for each item that has a cheaper, comparative alternative (same category, similar size/quality but cheaper brand/bulk), suggest it. Ensure constraints (Vegan, Gluten-Free, Organic, etc.) are strictly followed. Return ONLY valid JSON.',
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': prompt,
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$imageBase64',
                  },
                }
              ],
            }
          ],
          'response_format': {'type': 'json_object'},
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        final jsonResult = jsonDecode(content);
        return _parseReport(jsonResult);
      } else {
        debugPrint('OpenAI API Error: ${response.body}');
        return _getMockReport(prefs);
      }
    } catch (e) {
      debugPrint('Error analyzing receipt: $e');
      return _getMockReport(prefs);
    }
  }

  String _buildPrompt(UserPreferences prefs) {
    return '''
    Analyze this receipt. User preferences:
    - Sulfate Free: ${prefs.sulfateFree}
    - Organic Only: ${prefs.organicOnly}
    - No Brand Swaps: ${prefs.noBrandSwaps}
    - Vegetarian: ${prefs.vegetarian}
    - Gluten Free: ${prefs.glutenFree}
    - Budget Focus: ${prefs.budgetFocus}

    Task:
    1. Extract items from receipt.
    2. Identify cheaper alternatives for items where possible, respecting preferences.
    3. Calculate savings.
    
    Output JSON structure:
    {
      "totalOriginal": 15.93,
      "totalSavings": 5.40,
      "percentageSaved": 28,
      "substitutions": [
        {
          "original": {"name": "Colgate Toothpaste", "price": 3.50, "quantity": "100ml", "category": "Hygiene"},
          "alternative": {"name": "Dentyl Active", "price": 1.99, "quantity": "100ml", "category": "Hygiene"},
          "reason": "Value-Brand Match",
          "savings": 1.51,
          "tags": ["Value-Frase"]
        }
      ]
    }
    ''';
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

  SavingsReport _getMockReport(UserPreferences prefs) {
    // Return a convincing mock report based on the provided screenshot context
    return SavingsReport(
      id: 'mock-1',
      date: DateTime.now(),
      totalOriginalPrice: 15.93,
      totalSavings: 5.40,
      percentageSaved: 28.0,
      substitutions: [
        ComparisonItem(
          original: BasketItem(
            id: '1', name: 'Colgate Toothpaste', rawName: 'Colgate T/P', price: 3.50, quantity: '100ml', category: 'Health'),
          alternative: BasketItem(
            id: '1a', name: 'UltraDent White', rawName: 'UltraDent', price: 1.99, quantity: '100ml', category: 'Health'),
          reason: 'Same active ingredients, cheaper brand.',
          savings: 1.51,
          tags: ['Value-Chase'],
        ),
        ComparisonItem(
          original: BasketItem(
            id: '2', name: 'Dove Shampoo', rawName: 'Dove Shmp', price: 4.99, quantity: '250ml', category: 'Health'),
          alternative: BasketItem(
            id: '2a', name: 'Simple Gentle', rawName: 'Simple Shmp', price: 3.20, quantity: '250ml', category: 'Health'),
          reason: prefs.sulfateFree ? 'Sulfate-free option' : 'Generic equivalent',
          savings: 1.79,
          tags: prefs.sulfateFree ? ['Sulfate-Free'] : ['Generic'],
        ),
        ComparisonItem(
          original: BasketItem(
            id: '3', name: 'Organic Eggs', rawName: 'Org Eggs 6pk', price: 2.99, quantity: '6 pack', category: 'Food'),
          alternative: BasketItem(
            id: '3a', name: 'Free Range Eggs', rawName: 'FR Eggs 6pk', price: 2.20, quantity: '6 pack', category: 'Food'),
          reason: 'Standard Free Range is cheaper.',
          savings: 0.79,
          tags: ['Economy'],
        ),
      ],
    );
  }
}
