import 'dart:convert';
import 'dart:io';
import 'package:app_develop/Screens/service_provider_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'home.dart'; // Ensure this file contains NsaanoHomePage and ServiceProviderHomePage
import 'register_page.dart';

// Add this constant at the top of your file
String getBaseUrl() {
  if (Platform.isAndroid) {
    // Android emulator needs 10.0.2.2
    return 'http://10.0.2.2:8080';
  } else if (Platform.isIOS) {
    // iOS simulator can use localhost
    return 'http://localhost:8080';
  }
  // Add your production API URL here
  return 'http://your-production-api-url.com';
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
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
        String role = responseData['role'];
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => role == 'Service Seeker'
                ? NsaanoHomePage(token: responseData['token'])
                : const ServiceProviderHome(),
          ),
        );
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_phoneNumberController, 'Phone Number',
                    keyboardType: TextInputType.phone),
                _buildTextField(_passwordController, 'Password',
                    isPassword: true),
                const SizedBox(height: 24),
                CupertinoButton.filled(
                  onPressed: _isLoading ? null : loginUser,
                  child: _isLoading
                      ? const CupertinoActivityIndicator()
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  child: const Text("Don't have an account? Register"),
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
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        obscureText: isPassword,
        keyboardType: keyboardType,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.systemGrey4),
          borderRadius: BorderRadius.circular(8),
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
