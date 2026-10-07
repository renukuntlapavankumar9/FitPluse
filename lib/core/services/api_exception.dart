// ============================================================================
// FitPulse Mobile App — API Exception Hierarchy
// Week 4: API Integration and Asynchronous Data Handling
// Provides structured, user-friendly, and diagnostic error representations
// ============================================================================

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  const NetworkException(super.message, {super.originalError});
}

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException(super.message, {super.originalError});
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode, super.originalError});
}

class ParsingException extends ApiException {
  const ParsingException(super.message, {super.originalError});
}

