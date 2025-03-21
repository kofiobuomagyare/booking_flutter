import 'package:app_develop/Screens/service_provider_home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_develop/Screens/splash_screen.dart';
import 'package:app_develop/Screens/login.dart';
import 'package:app_develop/Screens/home.dart'; // Ensure this has NsaanoHomePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceProviderProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: 'Nsaano',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Changed to start with SplashScreen
    );
  }
}

class NsaanoAppStateful extends StatefulWidget {
  const NsaanoAppStateful({super.key});

  @override
  State<NsaanoAppStateful> createState() => _NsaanoAppState();
}

class _NsaanoAppState extends State<NsaanoAppStateful> {
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
