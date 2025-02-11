import 'package:app_develop/Screens/service_provider_home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_develop/Screens/splash_screen.dart';
import 'package:app_develop/Screens/login.dart';
import 'package:app_develop/Screens/home.dart'; // Ensure this has NsaanoHomePage

void main() {
  runApp(const NsaanoApp());
}

class NsaanoApp extends StatefulWidget {
  const NsaanoApp({super.key});

  @override
  State<NsaanoApp> createState() => _NsaanoAppState();
}

class _NsaanoAppState extends State<NsaanoApp> {
  Widget _homeScreen = const SplashScreen(); // Default to splash screen

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? role = prefs.getString('role');

    // If a token exists, go to home; otherwise, show login page
    if (token != null && token.isNotEmpty) {
      setState(() {
        _homeScreen = role == 'Service Seeker'
            ? NsaanoHomePage(token: token)
            : ServiceProviderHome(token: token);
      });
    } else {
      setState(() {
        _homeScreen = const LoginPage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _homeScreen,
    );
  }
}
