import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_develop/services/profile_service.dart';
import 'package:app_develop/services/auth_service.dart';
import 'package:app_develop/Screens/login.dart' as screens;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  // Remove the required token parameter since we're using AuthService
  const ProfilePage({super.key, required String token});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService profileService = ProfileService();
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? profileData;
  
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to ensure context is ready before accessing Provider
    Future.microtask(() => _loadUserProfile());
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Get the AuthService instance
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Check if there's a saved phone number
      final phoneNumber = authService.phoneNumber;
      if (phoneNumber == null) {
        // Redirect to login if no phone number is saved
        _redirectToLogin();
        return;
      }

      // Get user profile directly using the phone number
      final data = await _fetchProfileByPhone(phoneNumber);
      
      // Update the state with the profile data if widget is still mounted
      if (mounted) {
        setState(() {
          profileData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load profile: $e';
          isLoading = false;
        });
        _showError('Error loading profile. Please try again.');
      }
    }
  }

  Future<Map<String, dynamic>> _fetchProfileByPhone(String phoneNumber) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final baseUrl = authService.getBaseUrl();
    final token = authService.token;
    
    if (token == null) {
      _redirectToLogin();
      throw Exception('Authentication token is missing');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/profile?phoneNumber=$phoneNumber'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired or invalid, redirect to login
      _redirectToLogin();
      throw Exception('Authentication error');
    } else {
      throw Exception('Failed to load profile. Status: ${response.statusCode}');
    }
  }

  void _redirectToLogin() {
    // Only navigate if the widget is still mounted
    if (mounted) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const screens.LoginPage()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : profileData == null
                  ? const Center(child: Text('No profile data found'))
                  : _buildProfileContent(profileData!),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> data) {
    final String firstName = data['first_name'] ?? 'N/A';
    final String lastName = data['last_name'] ?? 'N/A';
    final String email = data['email'] ?? 'N/A';
    final String phone = data['phone_number'] ?? 'N/A';
    final String gender = data['gender'] ?? 'N/A';
    final String age = data['age']?.toString() ?? 'N/A';
    final String address = data['address'] ?? 'N/A';
    final String picture = data['profile_picture'] ?? '';

    return RefreshIndicator(
      onRefresh: () async {
        await _loadUserProfile();
        return;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (picture.isNotEmpty)
              CircleAvatar(
                radius: 50,
                backgroundImage: MemoryImage(base64Decode(picture)),
              )
            else
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            const SizedBox(height: 20),
            Text(
              "$firstName $lastName",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Email: $email"),
            Text("Phone: $phone"),
            Text("Age: $age"),
            Text("Gender: $gender"),
            Text("Address: $address"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (context) => const screens.LoginPage()),
      (route) => false,
    );
  }
}