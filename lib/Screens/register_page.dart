import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _age = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  String _gender = "Female";
  String _role = "Service Provider";
  File? _selectedImage;
  bool _isLoading = false;
  

  int _selectedGenderIndex = 0;
  int _selectedRoleIndex = 0;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _showPicker(BuildContext context, bool isGender) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: CupertinoColors.systemBackground,
          child: Column(
            children: [
              Container(
                height: 40,
                color: CupertinoColors.systemGrey5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Done'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: isGender ? _selectedGenderIndex : _selectedRoleIndex,
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      if (isGender) {
                        _selectedGenderIndex = index;
                        _gender = index == 0 ? 'Female' : 'Male';
                      } else {
                        _selectedRoleIndex = index;
                        _role = index == 0 ? 'Service Provider' : 'Service Seeker';
                      }
                    });
                  },
                  children: isGender
                      ? const [
                          Text('Female'),
                          Text('Male'),
                        ]
                      : const [
                          Text('Service Provider'),
                          Text('Service Seeker'),
                        ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> registerUser() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    String? base64Image;
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    // Print the request body for debugging
    final requestBody = {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'phone_number': _phoneNumberController.text,
      'address': _addressController.text,
      'gender': _gender,
      'bio': _bioController.text,
      'role': _role,
      'profile_picture': base64Image,
      'age': _age.text,
    };
    if (kDebugMode) {
      print('Request Body: ${json.encode(requestBody)}');
    }

    final response = await http.post(
      Uri.parse('${getBaseUrl()}/api/register'),
      headers: {'Content-Type': 'application/json',},
      body: json.encode(requestBody),
    );

    if (!mounted) return;

    // Print response details for debugging
    if (kDebugMode) {
      print('Response Status Code: ${response.statusCode}');
    }
    if (kDebugMode) {
      print('Response Headers: ${response.headers}');
    }
    if (kDebugMode) {
      print('Response Body: ${response.body}');
    }

    // Check if response body is empty
    if (response.body.isEmpty) {
      throw Exception('Server returned an empty response');
    }

    // Try to parse the response body
    Map<String, dynamic>? responseData;
    try {
      responseData = json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to parse server response: ${response.body}');
    }

    if (response.statusCode == 201) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Success'),
          content: const Text('Registration successful!'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      );
    } else {
      final errorMessage = responseData?['message'] ?? 'Unknown error occurred';
      throw Exception('Registration failed: $errorMessage');
    }
  } catch (e) {
    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text('Registration failed: ${e.toString()}\n\nPlease check the debug console for more details.'),
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
        middle: Text('Create Account'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      shape: BoxShape.circle,
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null
                        ? const Icon(
                            CupertinoIcons.camera,
                            size: 40,
                            color: CupertinoColors.systemGrey,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(_firstNameController, 'First Name'),
                _buildTextField(_lastNameController, 'Last Name'),
                _buildTextField(_age, 'Age', keyboardType: TextInputType.number),
                _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
                _buildTextField(_passwordController, 'Password', isPassword: true),
                _buildTextField(_phoneNumberController, 'Phone Number', keyboardType: TextInputType.phone),
                _buildTextField(_addressController, 'Address'),
                _buildTextField(_bioController, 'Bio', maxLines: 3),
                
                const SizedBox(height: 16),
                
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(12),
                    onPressed: () => _showPicker(context, true),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gender: $_gender',
                          style: const TextStyle(color: CupertinoColors.black),
                        ),
                        const Icon(CupertinoIcons.chevron_down, size: 20),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(12),
                    onPressed: () => _showPicker(context, false),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Role: $_role',
                          style: const TextStyle(color: CupertinoColors.black),
                        ),
                        const Icon(CupertinoIcons.chevron_down, size: 20),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                CupertinoButton.filled(
                  onPressed: _isLoading ? null : registerUser,
                  child: _isLoading
                      ? const CupertinoActivityIndicator()
                      : const Text('Create Account'),
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
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormField<String>(
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoTextField(
                controller: controller,
                placeholder: placeholder,
                obscureText: isPassword,
                keyboardType: keyboardType,
                maxLines: maxLines,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: (value) {
                  state.didChange(value);
                },
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(color: CupertinoColors.systemRed),
                  ),
                ),
            ],
          );
        },
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter $placeholder';
          }
          if (placeholder == 'Email' &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
            return 'Please enter a valid email';
          }
          if (placeholder == 'Password' && (value?.length ?? 0) < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _age.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}