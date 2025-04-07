import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedAge;
  String? _selectedGender;
  XFile? _profilePicture;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();  // Check permissions when the page is initialized
  }

  Future<void> _checkPermissions() async {
    var cameraStatus = await Permission.camera.status;
    var storageStatus = await Permission.storage.status;

    // Check if permissions are granted
    if (!cameraStatus.isGranted || !storageStatus.isGranted) {
      // Request permissions if not already granted
      await Permission.camera.request();
      await Permission.storage.request();
    }
  }

  Future<void> _pickImage() async {
    // Ensure permissions are granted before picking an image
    var cameraPermission = await Permission.camera.request();
    var storagePermission = await Permission.storage.request();

    if (cameraPermission.isGranted && storagePermission.isGranted) {
      // Pick image from the camera
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _profilePicture = pickedFile;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected')),
        );
      }
    } else {
      // Handle permission denial
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera or storage permission denied')),
      );
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final url = getRegisterUrl(); // Get the registration API URL
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstName': _nameController.text.split(" ")[0],
          'lastName': _nameController.text.split(" ")[1],
          'email': _emailController.text,
          'password': _passwordController.text,
          'phoneNumber': _phoneController.text,
          'age': _selectedAge,
          'gender': _selectedGender,
          'profilePicture': _profilePicture?.path ?? '',
          'role': 'User',
        }),
      );

      if (response.statusCode == 200) {
        // Successfully registered
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Handle failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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

  String getRegisterUrl() {
    return '${getBaseUrl()}/api/register'; // Add the registration endpoint to the base URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: _selectedAge,
                hint: const Text('Select Age'),
                items: ['18', '19', '20', '21', '22', '23', '24', '25']
                    .map((age) => DropdownMenuItem(
                          value: age,
                          child: Text(age),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAge = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select your age';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: const Text('Select Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profilePicture == null
                      ? AssetImage('assets/images/default_avatar.jpg') as ImageProvider
                      : FileImage(File(_profilePicture!.path)),
                  child: _profilePicture == null
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
