import 'dart:convert';
import 'package:budget_buddy/utils/constants.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final String baseUrl = AppConstants.baseUrl;

  static Future<http.Response> request({
    required String endpoint,
    required String method,
    Map<String, dynamic>? data,
    Map<String, String>? customHeaders,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      ...?customHeaders,
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(url, headers: headers);
      case 'POST':
        return await http.post(
          url,
          headers: headers,
          body: json.encode(data),
        );
      case 'PUT':
        return await http.put(
          url,
          headers: headers,
          body: json.encode(data),
        );
      case 'DELETE':
        return await http.delete(url, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }
}

class AuthService {
  // Login method using ApiService
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data // This should contain token and user with _id
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed: $e'
      };
    }
  }

  // Register method using ApiService
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await ApiService.request(
        endpoint: 'auth/register',
        method: 'POST',
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Registration failed',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection failed: $e'};
    }
  }

  // Optional: Add token to headers for authenticated requests
  static Future<http.Response> authenticatedRequest({
    required String endpoint,
    required String method,
    required String token,
    Map<String, dynamic>? data,
    Map<String, String>? customHeaders,
  }) async {
    return await ApiService.request(
      endpoint: endpoint,
      method: method,
      data: data,
      customHeaders: {
        'Authorization': 'Bearer $token',
        ...?customHeaders,
      },
    );
  }

  // Optional: Logout method (if your backend has logout endpoint)
  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await authenticatedRequest(
        endpoint: 'auth/logout',
        method: 'POST',
        token: token,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Logged out successfully'};
      } else {
        return {'success': false, 'error': 'Logout failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Logout failed: $e'};
    }
  }

  // Optional: Forgot password method
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await ApiService.request(
        endpoint: 'auth/forgot-password',
        method: 'POST',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password reset email sent'};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Password reset failed'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection failed: $e'};
    }
  }
}