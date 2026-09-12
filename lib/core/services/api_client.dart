import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// Reusable HTTP client that injects Firebase ID tokens and handles errors.
class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({
    String? baseUrl,
    http.Client? httpClient,
  })  : baseUrl = baseUrl ?? AppConstants.defaultApiBaseUrl,
        _httpClient = httpClient ?? http.Client();

  /// Build headers including the Firebase ID token for authenticated requests.
  Future<Map<String, String>> _buildHeaders([Map<String, String>? customHeaders]) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken();
        if (idToken != null) {
          headers['Authorization'] = 'Bearer $idToken';
        }
      }
    } catch (_) {
      // If token retrieval fails or running outside Firebase, continue with headers
    }

    return headers;
  }

  /// Send a GET request.
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    return _sendRequest(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      final reqHeaders = await _buildHeaders(headers);
      return await _httpClient.get(uri, headers: reqHeaders).timeout(const Duration(seconds: 15));
    });
  }

  /// Send a POST request.
  Future<dynamic> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    return _sendRequest(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      final reqHeaders = await _buildHeaders(headers);
      final jsonBody = body != null ? jsonEncode(body) : null;
      return await _httpClient.post(uri, headers: reqHeaders, body: jsonBody).timeout(const Duration(seconds: 15));
    });
  }

  Future<dynamic> _sendRequest(Future<http.Response> Function() requestFn) async {
    try {
      final response = await requestFn();
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('Unable to reach EcoLoop API server. Please ensure the backend is running.');
    } on TimeoutException {
      throw const NetworkException('Connection to EcoLoop API timed out.');
    } on HttpException {
      throw const NetworkException('HTTP protocol error while connecting to server.');
    } catch (e) {
      if (e is ApiException || e is NetworkException || e is AuthTokenException) {
        rethrow;
      }
      throw NetworkException('Unexpected connection error: ${e.toString()}');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final bodyString = response.body;

    dynamic parsedBody;
    try {
      parsedBody = bodyString.isNotEmpty ? jsonDecode(bodyString) : null;
    } catch (_) {
      parsedBody = bodyString;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return parsedBody;
    }

    if (statusCode == 401 || statusCode == 403) {
      final detail = parsedBody is Map ? parsedBody['detail'] : 'Unauthorized';
      throw AuthTokenException(detail?.toString() ?? 'Invalid or expired authentication session');
    }

    final detail = parsedBody is Map ? parsedBody['detail'] : 'Server error';
    throw ApiException(
      statusCode: statusCode,
      message: detail?.toString() ?? 'Request failed with status $statusCode',
      body: parsedBody,
    );
  }
}

/// Network communication failure (e.g. offline, connection refused).
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => message;
}

/// API server response error (4xx / 5xx).
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic body;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.body,
  });

  @override
  String toString() => '[$statusCode] $message';
}

/// Authentication / Token validation failure.
class AuthTokenException implements Exception {
  final String message;
  const AuthTokenException(this.message);

  @override
  String toString() => message;
}
