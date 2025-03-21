import 'package:flutter/foundation.dart';
import '../models/auth_response.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthResponse? _authResponse;
  bool _isLoading = false;
  String? _error;
  String? _token;

  AuthResponse? get authResponse => _authResponse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authResponse?.token != null;
  String? get userRole => _authResponse?.role;
  String? get token => _token;

  Future<void> loginServiceProvider(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _authResponse = await _apiService.loginServiceProvider(email, password);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerServiceProvider(Map<String, dynamic> providerData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _authResponse = await _apiService.registerServiceProvider(providerData);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
      _authResponse = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        _token = data['token'];
        notifyListeners();
      } else {
        _error = data['message'] ?? 'Registration failed';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    } else if (Platform.isIOS) {
      return 'http://localhost:8080';
    }
    return 'http://your-production-api-url.com';
  }
} 