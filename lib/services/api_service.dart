import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_provider.dart';
import '../models/auth_response.dart';
import '../models/dashboard_data.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api'; // Update with your actual backend URL
  String? _authToken;

  // Set auth token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Get headers with auth token
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // User Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Service Provider Authentication
  Future<AuthResponse> loginServiceProvider(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/service-provider/login'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        if (authResponse.token != null) {
          setAuthToken(authResponse.token!);
        }
        return authResponse;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<AuthResponse> registerServiceProvider(Map<String, dynamic> providerData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/service-provider/register'),
        headers: _headers,
        body: json.encode(providerData),
      );

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        if (authResponse.token != null) {
          setAuthToken(authResponse.token!);
        }
        return authResponse;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Service Provider Operations
  Future<List<ServiceProvider>> getServiceProviders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/service-providers/search?q=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ServiceProvider.fromJson(json)).toList();
      } else {
        throw Exception('Search failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  // Profile Operations
  Future<Map<String, dynamic>> getUserProfile(String email) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profile/$email'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<void> logout() async {
    try {
      await http.post(Uri.parse('$baseUrl/logout'));
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // Dashboard Operations
  Future<DashboardData> getDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/service-provider/dashboard'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return DashboardData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load dashboard data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }

  Future<void> updateServiceProviderProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/service-provider/profile'),
        headers: _headers,
        body: json.encode(profileData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
} 