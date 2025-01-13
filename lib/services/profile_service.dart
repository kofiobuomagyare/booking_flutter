import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ProfileService {
  final String baseUrl = "http://172.20.10.9:8080"; // Your Spring Boot server address

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final String _gender = '';
  final String _role = '';

  // Method to login user
  Future<String?> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['token']; // Assuming the response contains a token
    } else {
      throw Exception('Login failed');
    }
  }

  // Method to register a user
Future<void> _register(BuildContext context, bool mounted) async {
  final firstName = _firstNameController.text.trim();
  final lastName = _lastNameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final phoneNumber = _phoneNumberController.text.trim();
  final location = _locationController.text.trim();
  final gender = _gender; // Dropdown value is already a String
  final bio = _bioController.text.trim();
  final role = _role; // Dropdown value is already a String

  if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty || phoneNumber.isEmpty || location.isEmpty || gender.isEmpty || bio.isEmpty || role.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all fields')),
    );
    return;
  }

  final profileService = ProfileService();
  if (!mounted) return;
  try {
    final success = await profileService.registerUser(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      location: location,
      gender: gender,
      bio: bio,
      role: role,
    );

    if (success) {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful')),
      );
      Navigator.pop(context); // Navigate back after success
    } else {
      throw Exception('Registration failed');
    }
  } catch (error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  }
}


  // Method to register a user
  Future<bool> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String location,
    required String gender,
    required String bio,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'location': location,
        'gender': gender,
        'bio': bio,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // Method to get user profile
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final url = Uri.parse('$baseUrl/user/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // Return parsed profile data
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
