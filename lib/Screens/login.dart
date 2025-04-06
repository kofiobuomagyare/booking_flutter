import 'dart:convert';
import 'dart:io';
import 'package:app_develop/Screens/service_provider_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'register_page.dart';

String getBaseUrl() {
  if (Platform.isAndroid) {
  return 'https://salty-citadel-42862-262ec2972a46.herokuapp.com'; // Use Heroku URL for Android
} else if (Platform.isIOS) {
  return 'https://salty-citadel-42862-262ec2972a46.herokuapp.com'; // Use Heroku URL for iOS
} else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  return 'http://localhost:8080'; // Use localhost for local testing on PC
}
return 'https://salty-citadel-42862-262ec2972a46.herokuapp.com'; // Default for other cases
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone_number': _phoneNumberController.text,
          'password': _passwordController.text,
        }),
      );

      if (!mounted) return;

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        String token = responseData['token'];
        String role = responseData['role'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => role == 'Service Seeker'
                ? NsaanoHomePage(token: token)
                : ServiceProviderHome(token: token),
          ),
        );
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Login'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard when tapping outside
        child: Stack(
          children: [
            // Background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Translucent overlay
            Container(color: CupertinoColors.black.withValues(alpha: 0.3)),


            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTextField(
                                _phoneNumberController,
                                'Phone Number',
                                keyboardType: TextInputType.phone,
                              ),
                              _buildTextField(
                                _passwordController,
                                'Password',
                                isPassword: true,
                              ),
                              const SizedBox(height: 24),
                              CupertinoButton.filled(
                                onPressed: _isLoading ? null : loginUser,
                                child: _isLoading
                                    ? const CupertinoActivityIndicator()
                                    : const Text('Login'),
                              ),
                              const SizedBox(height: 16),
                              CupertinoButton(
                                child: const Text(
                                  "Don't have an account? Register",
                                  style: TextStyle(
                                    color: CupertinoColors.activeBlue,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => const RegisterPage(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String placeholder, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white.withValues(alpha: 153), // Translucent input
          borderRadius: BorderRadius.circular(8),
        ),
        child: CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          obscureText: isPassword,
          keyboardType: keyboardType,
          padding: const EdgeInsets.all(12),
          autofocus: true, // Ensure keyboard pops up when focused
          placeholderStyle: const TextStyle(
            color: CupertinoColors.darkBackgroundGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(const CupertinoApp(
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
  ));
}
