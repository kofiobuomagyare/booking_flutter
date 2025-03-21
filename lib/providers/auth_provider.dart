import 'package:flutter/foundation.dart';
import '../models/auth_response.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthResponse? _authResponse;
  bool _isLoading = false;
  String? _error;

  AuthResponse? get authResponse => _authResponse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authResponse?.token != null;
  String? get userRole => _authResponse?.role;

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
} 