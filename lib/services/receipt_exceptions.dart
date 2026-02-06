/// Custom exceptions for receipt analysis operations

/// Thrown when OpenAI API credentials are not configured
class ApiNotConfiguredException implements Exception {
  final String message;
  
  ApiNotConfiguredException([
    this.message = 'OpenAI API is not configured. Please set OPENAI_PROXY_API_KEY and OPENAI_PROXY_ENDPOINT environment variables.'
  ]);
  
  @override
  String toString() => message;
}

/// Thrown when network connectivity issues occur
class NetworkException implements Exception {
  final String message;
  final dynamic originalError;
  
  NetworkException([
    this.message = 'Network error. Please check your internet connection and try again.',
    this.originalError
  ]);
  
  @override
  String toString() => message;
}

/// Thrown when OpenAI API returns an error response
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? responseBody;
  
  ApiException(this.statusCode, [this.message = 'API request failed', this.responseBody]);
  
  @override
  String toString() {
    switch (statusCode) {
      case 401:
        return 'Authentication failed. Please verify your API key is correct.';
      case 429:
        return 'Rate limit exceeded. Please try again in a few moments.';
      case 500:
      case 502:
      case 503:
        return 'OpenAI service error. Please try again later.';
      case 400:
        return 'Invalid request. The image may be corrupted or too large.';
      default:
        return 'API error ($statusCode): $message';
    }
  }
}

/// Thrown when the AI response cannot be parsed
class ParsingException implements Exception {
  final String message;
  final dynamic originalError;
  
  ParsingException([
    this.message = 'Failed to process receipt. The image may be unclear or the receipt format is not recognized.',
    this.originalError
  ]);
  
  @override
  String toString() => message;
}