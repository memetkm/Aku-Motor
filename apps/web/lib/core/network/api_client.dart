import 'dart:convert';
import 'dart:io' show HttpClient, HttpClientResponse, HttpHeaders;

class ApiResponse {
  const ApiResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException ($statusCode): $message';
}

abstract interface class ApiClient {
  Future<ApiResponse> get(String path);
  Future<ApiResponse> post(String path, {Map<String, dynamic>? body});
  Future<ApiResponse> put(String path, {Map<String, dynamic>? body});
  Future<ApiResponse> delete(String path);
}

class StandardApiClient implements ApiClient {
  StandardApiClient({
    String? baseUrl,
    HttpClient? httpClient,
  })  : baseUrl = baseUrl ?? 'http://localhost:3000/api',
        _client = httpClient ?? HttpClient();

  final String baseUrl;
  final HttpClient _client;

  @override
  Future<ApiResponse> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _client.getUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    final response = await request.close();
    final body = await _readResponseBody(response);
    return ApiResponse(statusCode: response.statusCode, body: body);
  }

  @override
  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _client.postUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    if (body != null) {
      request.write(jsonEncode(body));
    }
    final response = await request.close();
    final responseBody = await _readResponseBody(response);
    return ApiResponse(statusCode: response.statusCode, body: responseBody);
  }

  @override
  Future<ApiResponse> put(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _client.putUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    if (body != null) {
      request.write(jsonEncode(body));
    }
    final response = await request.close();
    final responseBody = await _readResponseBody(response);
    return ApiResponse(statusCode: response.statusCode, body: responseBody);
  }

  @override
  Future<ApiResponse> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _client.deleteUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    final response = await request.close();
    final body = await _readResponseBody(response);
    return ApiResponse(statusCode: response.statusCode, body: body);
  }

  Future<String> _readResponseBody(HttpClientResponse response) async {
    return response.transform(utf8.decoder).join();
  }
}

