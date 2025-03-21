import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_provider.dart';

class ServiceProviderAuthProvider with ChangeNotifier {
  ServiceProvider? _currentProvider;
  String? _token;
  bool _isLoading = false;

  ServiceProvider? get currentProvider => _currentProvider;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('YOUR_API_BASE_URL/api/service-providers/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _currentProvider = ServiceProvider.fromJson(data['provider']);
        
        // Save token and provider data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('provider_token', _token!);
        await prefs.setString('provider_data', json.encode(data['provider']));
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String serviceType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('YOUR_API_BASE_URL/api/service-providers/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'serviceType': serviceType,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _token = data['token'];
        _currentProvider = ServiceProvider.fromJson(data['provider']);
        
        // Save token and provider data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('provider_token', _token!);
        await prefs.setString('provider_data', json.encode(data['provider']));
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentProvider = null;
    
    // Clear stored data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('provider_token');
    await prefs.remove('provider_data');
    
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('provider_token');
    
    if (_token != null) {
      final providerData = prefs.getString('provider_data');
      if (providerData != null) {
        _currentProvider = ServiceProvider.fromJson(json.decode(providerData));
      }
    }
    
    notifyListeners();
  }

  Future<void> updateAvailability(bool isAvailable) async {
    if (_currentProvider == null) return;

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/service-providers/${_currentProvider!.id}/availability'),
        headers: await _getHeaders(),
        body: json.encode({'isAvailable': isAvailable}),
      );

      if (response.statusCode == 200) {
        _currentProvider = _currentProvider!.copyWith(isAvailable: isAvailable);
        notifyListeners();
      } else {
        throw Exception('Failed to update availability');
      }
    } catch (e) {
      throw Exception('Error updating availability: $e');
    }
  }
} 