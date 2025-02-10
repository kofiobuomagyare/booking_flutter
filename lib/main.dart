import 'package:flutter/material.dart';
import 'package:app_develop/Screens/splash_screen.dart'; // Import the splash screen

void main() {
  runApp(const NsaanoApp());
}

class NsaanoApp extends StatelessWidget {
  const NsaanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Start with the splash screen
    );
  }
}