import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_develop/services/profile_service.dart';
import 'package:app_develop/Screens/login.dart' as screens;
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final String token;

  const ProfilePage({super.key, required this.token});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService profileService = ProfileService();
  // ignore: unused_field
  late Future<Map<String, dynamic>> _profileFuture;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? userId;

  @override
  void initState() {
    super.initState();
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
      body: userId == null
          ? _buildLoginForm() // Show login form if userId is not available
          : FutureBuilder<Map<String, dynamic>>(
              future: profileService.getUserProfile(userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Error loading profile'),
                        ElevatedButton(
                          onPressed: _refreshProfile,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('No profile data available.'));
                }

                var profileData = snapshot.data!;
                return _buildProfileContent(profileData);
              },
            ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loginUser,
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

Future<void> _loginUser() async {
  final String phone = phoneController.text.trim();
  final String password = passwordController.text.trim();

  if (phone.isEmpty || password.isEmpty) {
    _showError('Please enter both phone number and password');
    return;
  }

  try {
    final response = await http.get(
      Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/users/login?phoneNumber=$phone&password=$password'),
      headers: {'Content-Type': 'application/json'},
    );

    print('Login response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        userId = data['user_id']; // still saving it if needed
        _profileFuture = Future.value(data); // direct profile loading
      });
    } else {
      _showError('Login failed: Invalid credentials');
    }
  } catch (e) {
    print("Login error: $e");
    _showError('An error occurred during login');
  }
}

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

 Widget _buildProfileContent(Map<String, dynamic> profileData) {
  final String firstName = profileData['first_name'] ?? 'N/A';
  final String lastName = profileData['last_name'] ?? 'N/A';
  final String email = profileData['email'] ?? 'N/A';
  final String phone = profileData['phone_number'] ?? 'N/A';
  final String gender = profileData['gender'] ?? 'N/A';
  final String age = profileData['age']?.toString() ?? 'N/A';
  final String address = profileData['address'] ?? 'N/A';
  final String picture = profileData['profile_picture'] ?? '';

  return SingleChildScrollView(
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
            child: Icon(Icons.person, size: 50),
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
  );
}
  void _refreshProfile() {
    if (userId != null) {
      setState(() {
        _profileFuture = profileService.getUserProfile(userId!);
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');

    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (context) => const screens.LoginPage()),
      (route) => false,
    );
  }
}
