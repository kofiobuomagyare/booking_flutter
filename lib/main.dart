import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/service_provider_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'screens/home_screen.dart';
import 'screens/service_provider_login_screen.dart';
import 'screens/service_provider_register_screen.dart';
import 'screens/service_provider_dashboard_screen.dart';

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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isAuthenticated) {
          return const ServiceProviderLoginScreen();
        }

        if (authProvider.userRole == 'SERVICE_PROVIDER') {
          return const ServiceProviderDashboardScreen();
        }

        return const HomeScreen();
      },
    );
  }
}
