import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For CupertinoPageRoute
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_develop/services/profile_service.dart';
import 'package:app_develop/Screens/login.dart' as screens;

class ProfilePage extends StatefulWidget {
  final String token;

  const ProfilePage({super.key, required this.token});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService profileService = ProfileService();
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = profileService.getUserProfile(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.token.isEmpty) {
      _navigateToLogin(context);
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context), // Call logout function
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            if (snapshot.error.toString().contains('401')) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _navigateToLogin(context);
              });
              return const Center(child: CircularProgressIndicator());
            }
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

  Widget _buildProfileContent(Map<String, dynamic> profileData) {
    final String name = profileData['name'] ?? 'N/A';
    final String email = profileData['email'] ?? 'N/A';
    final String picture = profileData['picture'] ?? '';

    return SingleChildScrollView(
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
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            email,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _logout(context), // Logout button
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const screens.LoginPage()),
      );
    });
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = profileService.getUserProfile(widget.token);
    });
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');

    Navigator.pushAndRemoveUntil(
      // ignore: use_build_context_synchronously
      context,
      CupertinoPageRoute(builder: (context) => const screens.LoginPage()),
      (route) => false, // Remove all previous routes
    );
  }
}
