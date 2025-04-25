import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:app_develop/Screens/service_provider_home.dart';
import 'package:app_develop/Screens/home.dart';
import 'package:app_develop/Screens/register_page.dart';
import 'package:app_develop/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.loadLoginState();
    if (authService.isLoggedIn) {
      _navigateBasedOnRole(authService.token!, authService.role!);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(
      _phoneNumberController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      _navigateBasedOnRole(authService.token!, authService.role!);
      // 👇 Log it from here
  debugPrint('📱 Logged in user: ${authService.phoneNumber}');
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(authService.errorMessage),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void _navigateBasedOnRole(String token, String role) {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) {
          if (role == 'Service Seeker') {
            return NsaanoHomePage(token: token);
          } else if (role == 'Service Provider') {
            return ServiceProviderHome(token: token);
          } else {
            return NsaanoHomePage(token: token);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Login'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(color: CupertinoColors.black.withOpacity(0.3)),
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
                              Consumer<AuthService>(
                                builder: (context, authService, child) {
                                  return CupertinoButton.filled(
                                    onPressed: authService.isLoading ? null : _login,
                                    child: authService.isLoading
                                        ? const CupertinoActivityIndicator()
                                        : const Text('Login'),
                                  );
                                },
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
          color: CupertinoColors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          obscureText: isPassword ? _obscurePassword : false,
          keyboardType: keyboardType,
          padding: const EdgeInsets.all(12),
          placeholderStyle: const TextStyle(
            color: CupertinoColors.darkBackgroundGray,
            fontWeight: FontWeight.w500,
          ),
          suffix: isPassword
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  child: Icon(
                    _obscurePassword
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye,
                    size: 20,
                    color: CupertinoColors.activeBlue,
                  ),
                )
              : null,
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