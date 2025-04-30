import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _errorMessage = '';
  String? _token;
  String? _role;
  String? _phoneNumber;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading; 
  String get errorMessage => _errorMessage;
  String? get token => _token;
  String? get role => _role;
  String? get phoneNumber => _phoneNumber;

  // Define the base URL for the API (Heroku or localhost)
  String getBaseUrl() {
    if (Platform.isAndroid) {
      return 'https://salty-citadel-42862-262ec2972a46.herokuapp.com';
    } else if (Platform.isIOS) {
      return 'https://salty-citadel-42862-262ec2972a46.herokuapp.com';
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'https://salty-citadel-42862-262ec2972a46.herokuapp.com';
    }
    return 'https://salty-citadel-42862-262ec2972a46.herokuapp.com';
  }

  // Load the login state from SharedPreferences
  Future<void> loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _token = prefs.getString('token');
    _role = prefs.getString('role');
    _phoneNumber = prefs.getString('phoneNumber');
    notifyListeners();
  }

  // Save login state to SharedPreferences
  Future<void> _saveLoginState(
      bool isLoggedIn, String token, String role, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setString('phoneNumber', phoneNumber);
    
    _isLoggedIn = isLoggedIn;
    _token = token;
    _role = role;
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  // Login method using phone number and password
 Future<bool> login(String phoneNumber, String password) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('${getBaseUrl()}/api/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone_number': phoneNumber,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        await _saveLoginState(
          true,
          responseData['token'],
          responseData['role'],
          phoneNumber,
        );
        
  // ✅ Log phone number here
  debugPrint('📱 Phone number saved: $_phoneNumber');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = responseData['message'] ?? 'Invalid phone number or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'Something went wrong. Please try again later.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Reset password method
Future<bool> resetPassword(String phoneNumber, String newPassword) async {
  _isLoading = true;
  _errorMessage = '';
  notifyListeners();

  final url = Uri.parse('${getBaseUrl()}/api/users/reset-password');
  try {
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'phoneOrEmail': phoneNumber,
        'newPassword': newPassword,
      },
    );

    final responseData = json.decode(response.body);
    
    if (response.statusCode == 200) {
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = responseData['message'] ?? 'Failed to reset password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  } catch (error) {
    _errorMessage = 'Something went wrong. Please try again later.';
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
    // Logout method
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _token = null;
    _role = null;
    _phoneNumber = null;
    notifyListeners();
  }
}