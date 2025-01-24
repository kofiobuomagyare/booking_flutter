import 'dart:convert';
import 'package:app_develop/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:app_develop/Screens/login.dart' as screens; // Add a prefix

class ProfilePage extends StatelessWidget {
  final ProfileService profileService = ProfileService();
  final String token; // Add a variable to hold the token

  // Modify the constructor to accept the token
  ProfilePage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: profileService.getUserProfile(1), // Pass the user ID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          // If there is an error or no data, navigate to the LoginPage
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const screens.LoginPage()), // Use the prefix
            );
          });
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          var profileData = snapshot.data!;
          String name = profileData['name'];
          String email = profileData['email'];
          String picture = profileData['picture'];

          // If the picture is a base64 string, decode it and display it as an image
          Image profilePicture = Image.memory(
            base64Decode(picture), // Decode the Base64 string to image bytes
          );

          return Column(
            children: [
              profilePicture,
              Text('Name: $name'),
              Text('Email: $email'),
            ],
          );
        } else {
          return const Center(child: Text('No data available.'));
        }
      },
    );
  }
}
