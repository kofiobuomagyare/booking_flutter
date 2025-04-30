import 'package:app_develop/Screens/booking.dart';
import 'package:app_develop/Screens/home.dart';
import 'package:app_develop/Screens/splash_screen.dart';
import 'package:app_develop/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'Screens/login.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const NsaanoApp(),
    ),
  );
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
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Nsaano',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Poppins',
              textTheme: Theme.of(context).textTheme.apply(
                    bodyColor: Colors.black,
                    displayColor: Colors.black,
                  ),
              useMaterial3: true,
            ),
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginPage(),
              '/home': (context) => const NsaanoHomePage(
                    token: '',
                  ),
              '/booking': (context) => const BookingScreen(
                    token: '', providerId: '',
                  ), // Keep map screen route
            },
          ),
        );
      },
    );
  }
}
