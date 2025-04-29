import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:app_develop/services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Check if passwords match
    if (_newPasswordController.text != _confirmPasswordController.text) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('Passwords do not match'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.resetPassword(
      _phoneNumberController.text,
      _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Success'),
          content: const Text('Password reset successfully'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Return to login page
              },
            ),
          ],
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Reset Password'),
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
                                _newPasswordController,
                                'New Password',
                                isPassword: true,
                              ),
                              _buildTextField(
                                _confirmPasswordController,
                                'Confirm Password',
                                isPassword: true,
                                isConfirmPassword: true,
                              ),
                              const SizedBox(height: 24),
                              Consumer<AuthService>(
                                builder: (context, authService, child) {
                                  return CupertinoButton.filled(
                                    onPressed: authService.isLoading ? null : _resetPassword,
                                    child: authService.isLoading
                                        ? const CupertinoActivityIndicator()
                                        : const Text('Reset Password'),
                                  );
                                },
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
    bool isConfirmPassword = false,
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
          obscureText: isPassword ? (isConfirmPassword ? _obscureConfirmPassword : _obscurePassword) : false,
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
                      if (isConfirmPassword) {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      } else {
                        _obscurePassword = !_obscurePassword;
                      }
                    });
                  },
                  child: Icon(
                    isConfirmPassword
                        ? (_obscureConfirmPassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye)
                        : (_obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye),
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
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}