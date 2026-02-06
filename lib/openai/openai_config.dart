import 'package:flutter/foundation.dart';

class OpenAIConfig {
  static const String _apiKey = String.fromEnvironment('OPENAI_PROXY_API_KEY');
  static const String _baseUrl = String.fromEnvironment('OPENAI_PROXY_ENDPOINT');

  static String get apiKey => _apiKey;
  static String get baseUrl => _baseUrl; // e.g. https://api.openai.com/v1

  /// Returns the complete chat completions endpoint
  static Uri get chatCompletionsUri {
    // Ensure we don't double-slash or miss a slash if needed.
    // Spec says: Don't append 'v1/chat/completions' if it's already the endpoint. 
    // Usually the provided proxy endpoint IS the base or full path.
    // However, the AI spec says: "Don't append 'v1/chat/completions' to the endpoint URL. Use it directly."
    // So I assume _baseUrl is the full URL to call.
    return Uri.parse(_baseUrl);
  }

  static bool get isConfigured => _apiKey.isNotEmpty && _baseUrl.isNotEmpty;
}
