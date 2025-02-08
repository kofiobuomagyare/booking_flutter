import 'package:app_develop/Screens/splash_screen.dart';  // Add this import
import 'package:flutter/material.dart';

void main() {
  runApp(const NsaanoApp());
}

class NsaanoApp extends StatelessWidget {
  const NsaanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),  // Changed this line to show SplashScreen first
    );
  }
}