import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider_auth_provider.dart';
import 'providers/service_provider_provider.dart';
import 'Screens/login_page.dart';
import 'Screens/home_screen.dart';
import 'Screens/map_screen.dart';
import 'Screens/service_provider_login_screen.dart';
import 'Screens/service_provider_dashboard.dart';

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
              '/map': (context) => MapScreen(token: context.read<AuthProvider>().token ?? ''),
              '/service-provider-login': (context) => const ServiceProviderLoginScreen(),
              '/service-provider-dashboard': (context) => const ServiceProviderDashboard(),
            },
          ),
        );
      },
    );
  }
}
