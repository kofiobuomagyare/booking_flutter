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
  runApp(const NsaanoApp());
}

class NsaanoApp extends StatelessWidget {
  const NsaanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => ServiceProviderAuthProvider()),
            ChangeNotifierProvider(create: (_) => ServiceProviderProvider()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Nsaano',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginPage(),
              '/home': (context) => const HomeScreen(),
              '/provider-dashboard': (context) => const ServiceProviderDashboard(),
            },
          ),
        );
      },
    );
  }
}
