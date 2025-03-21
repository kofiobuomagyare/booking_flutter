import 'package:flutter/material.dart';
import '../models/service_provider.dart';
import '../services/api_service.dart';

class ServiceProviderProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<ServiceProvider> _providers = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceProvider> get providers => _providers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadServiceProviders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _providers = await _apiService.getServiceProviders();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProviders(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _providers = await _apiService.searchServiceProviders(query);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ServiceProvider?> getProviderById(String id) async {
    try {
      return await _apiService.getServiceProviderById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<ServiceProvider> getServiceProviderById(String id) async {
    return await _apiService.getServiceProviderById(id);
  }

  Future<void> bookAppointment({
    required String providerId,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    await _apiService.bookAppointment(
      providerId: providerId,
      date: date,
      time: time,
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 