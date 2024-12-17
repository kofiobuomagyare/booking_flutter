import 'package:app_develop/Screens/home.dart';
import 'package:flutter/material.dart';
// Import the home.dart file

void main() {
  runApp(const NsaanoApp());
}

class NsaanoApp extends StatelessWidget {
  const NsaanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NsaanoHomePage(), // Reference the class from home.dart
    );
  }
}
