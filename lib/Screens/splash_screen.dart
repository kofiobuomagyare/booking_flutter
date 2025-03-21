// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:app_develop/Screens/login.dart';
import 'package:app_develop/Screens/register_page.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    _startNavigationTimer();
  }

  void _startNavigationTimer() {
    _navigationTimer = Timer(const Duration(seconds: 3), _navigateToAuth);
  }

  void _navigateToAuth() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... existing code ...
  }
} 