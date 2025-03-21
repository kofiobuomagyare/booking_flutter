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
        Uri.parse('$baseUrl/service-providers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ServiceProvider.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get service providers');
      }
    } catch (e) {
      throw Exception('Error getting service providers: $e');
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

  Future<List<ServiceProvider>> searchServiceProviders(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/service-providers/search?q=$query'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ServiceProvider.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search service providers');
      }
    } catch (e) {
      throw Exception('Error searching service providers: $e');
    }
  }

  Future<ServiceProvider> getServiceProviderById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/service-providers/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServiceProvider.fromJson(data);
      } else {
        throw Exception('Failed to get service provider');
      }
    } catch (e) {
      throw Exception('Error getting service provider: $e');
    }
  }

  Future<List<ServiceProvider>> getNearbyProviders(double latitude, double longitude, double radius) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/service-providers/nearby?lat=$latitude&lng=$longitude&radius=$radius'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ServiceProvider.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get nearby providers');
      }
    } catch (e) {
      throw Exception('Error getting nearby providers: $e');
    }
  }

  Future<void> bookAppointment({
    required String providerId,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/appointments'),
        headers: _headers,
        body: json.encode({
          'providerId': providerId,
          'date': date.toIso8601String(),
          'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to book appointment');
      }
    } catch (e) {
      throw Exception('Error booking appointment: $e');
    }
  }
} 