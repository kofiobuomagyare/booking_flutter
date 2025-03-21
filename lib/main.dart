import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/service_provider_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/service_provider_auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/service_provider_home.dart';
import 'screens/service_provider/login_screen.dart';
import 'screens/service_provider/register_screen.dart';
import 'screens/service_provider/dashboard_screen.dart';

void main() {
  runApp(const NsaanoAppStateful());
}

class NsaanoAppStateful extends StatefulWidget {
  const NsaanoAppStateful({super.key});

  @override
  State<NsaanoAppStateful> createState() => _NsaanoAppState();
}

class _NsaanoAppState extends State<NsaanoAppStateful> {
  Widget _homeScreen = const SplashScreen();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? role = prefs.getString('role');

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
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ServiceProviderProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => DashboardProvider()),
            ChangeNotifierProvider(create: (_) => ServiceProviderAuthProvider()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Nsaano',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => _homeScreen,
              '/login': (context) => const LoginPage(),
              '/service-provider-login': (context) => const ServiceProviderLoginScreen(),
              '/service-provider-register': (context) => const ServiceProviderRegisterScreen(),
              '/service-provider-dashboard': (context) => const ServiceProviderDashboard(),
              '/home': (context) => NsaanoHomePage(token: ''),
              '/service-provider-home': (context) => ServiceProviderHome(token: ''),
            },
          ),
        );
      },
    );
  }
}
