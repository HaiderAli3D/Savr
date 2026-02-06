import 'package:flutter/foundation.dart';

class OpenAIConfig {
  // Firebase Function URL - Update this after deploying your function
  // Format: https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/analyzeReceipt
  static const String _functionUrl = String.fromEnvironment(
    'FIREBASE_FUNCTION_URL',
    defaultValue: 'https://us-central1-savr-2c7a4.cloudfunctions.net/analyzeReceipt',
  );

  static String get functionUrl => _functionUrl;

  /// Returns the Firebase Function endpoint URI
  static Uri get analyzeReceiptUri => Uri.parse(_functionUrl);

  static bool get isConfigured => _functionUrl.isNotEmpty;
}