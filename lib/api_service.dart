import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL of your backend API
  static const String baseUrl = "http://localhost:8080/api";

  // User registration function
  Future<Map<String, dynamic>> registerUser(
      String name, String email, String password, String phoneNumber, String location) async {
    final url = Uri.parse('$baseUrl/users/register');
    
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'location': location,
          'role': 'USER', // Default role
        }));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register user');
    }
  }

  // User login function
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/users/login');
    
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to log in');
    }
  }

  // Fetch user details function
  Future<Map<String, dynamic>> getUserDetails(int userId) async {
    final url = Uri.parse('$baseUrl/users/$userId');
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user details');
    }
  }

  // Service Provider registration function
  Future<Map<String, dynamic>> registerServiceProvider(
      String name, String email, String password, String phoneNumber, String location,
      String companyName, String businessNumber, String priceList) async {
    final url = Uri.parse('$baseUrl/service-providers/register');
    
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'location': location,
          'companyName': companyName,
          'businessNumber': businessNumber,
          'priceList': priceList,
          'role': 'SERVICE_PROVIDER',
        }));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register service provider');
    }
  }

  // Service Provider login function
  Future<Map<String, dynamic>> loginServiceProvider(String email, String password) async {
    final url = Uri.parse('$baseUrl/service-providers/login');
    
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to log in');
    }
  }
}
