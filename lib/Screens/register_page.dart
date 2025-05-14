// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  String? _selectedAge;
  String? _selectedGender;
  XFile? _profilePicture;
  bool _isLoading = false;
  bool _obscurePassword = true;
  int? _androidSdkVersion;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        _androidSdkVersion = androidInfo.version.sdkInt;
        print("Android SDK Version: $_androidSdkVersion");
      }
    } catch (e) {
      print("Error getting device info: $e");
    }
  }

  Future<bool> _requestCameraPermissions() async {
    try {
      // First try to request camera permissions
      PermissionStatus cameraStatus = await Permission.camera.request();
      print("Camera permission status: $cameraStatus");

      if (!cameraStatus.isGranted) {
        return false;
      }

      // Camera permission is granted, now handle storage/photos
      if (Platform.isAndroid) {
        if (_androidSdkVersion == null) {
          // Fallback if we couldn't determine SDK version
          await Permission.storage.request();
          return await Permission.storage.isGranted;
        }

        if (_androidSdkVersion! >= 33) {
          // Android 13+
          // For Android 13+, request media permissions
          await Permission.photos.request();
          return await Permission.photos.isGranted;
        } else {
          // For Android 12 and below
          await Permission.storage.request();
          return await Permission.storage.isGranted;
        }
      } else if (Platform.isIOS) {
        await Permission.photos.request();
        return await Permission.photos.isGranted;
      }

      return false;
    } catch (e) {
      print("Error requesting permissions: $e");
      return false;
    }
  }

  Future<void> pickImage() async {
    try {
      print("Starting image picker...");

      // For Android, try to pick image directly first
      final picker = ImagePicker();

      if (Platform.isAndroid) {
        print("Attempting to pick image directly on Android");
        try {
          final XFile? pickedFile = await showDialog<XFile?>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Pick an Image'),
              content: const Text('Choose image source'),
              actions: [
                TextButton(
                  onPressed: () async {
                    try {
                      final file =
                          await picker.pickImage(source: ImageSource.gallery);
                      Navigator.pop(context, file);
                    } catch (e) {
                      print("Gallery error: $e");
                      Navigator.pop(context, null);
                      // If direct picking fails, we'll handle permissions below
                    }
                  },
                  child: const Text('Gallery'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      final file =
                          await picker.pickImage(source: ImageSource.camera);
                      Navigator.pop(context, file);
                    } catch (e) {
                      print("Camera error: $e");
                      Navigator.pop(context, null);
                      // If direct picking fails, we'll handle permissions below
                    }
                  },
                  child: const Text('Camera'),
                ),
              ],
            ),
          );

          if (pickedFile != null) {
            setState(() {
              _profilePicture = pickedFile;
            });
            return; // Success! Exit the function
          }
        } catch (e) {
          print("Direct image picking failed: $e");
          // Continue to permission handling
        }
      }

      // If direct picking didn't work, handle permissions explicitly
      bool permissionsGranted = await _requestCameraPermissions();

      if (permissionsGranted) {
        print("Permissions granted, showing image source dialog");

        final XFile? pickedFile = await showDialog<XFile?>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pick an Image'),
            content: const Text('Choose image source'),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    final file =
                        await picker.pickImage(source: ImageSource.gallery);
                    Navigator.pop(context, file);
                  } catch (e) {
                    print("Gallery error after permissions: $e");
                    Navigator.pop(context, null);
                  }
                },
                child: const Text('Gallery'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final file =
                        await picker.pickImage(source: ImageSource.camera);
                    Navigator.pop(context, file);
                  } catch (e) {
                    print("Camera error after permissions: $e");
                    Navigator.pop(context, null);
                  }
                },
                child: const Text('Camera'),
              ),
            ],
          ),
        );

        if (pickedFile != null) {
          setState(() {
            _profilePicture = pickedFile;
          });
        } else {
          print("No image selected");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No image selected')));
          }
        }
      } else {
        print("Permissions not granted");
        if (mounted) {
          // Open app settings directly since permissions are already showing as granted in system
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                  'The app needs camera and storage permissions to access images. '
                  'Please open app settings and grant the required permissions.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print("Error in pickImage: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error selecting image: ${e.toString()}')));
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled')));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permissions are permanently denied')));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        String address =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        setState(() {
          _addressController.text = address;
        });
      }
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: ${e.toString()}')));
    }
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final nameParts = _nameController.text.split(" ");
      final firstName = nameParts[0];
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";
      String? base64ProfileImage;
      if (_profilePicture != null) {
        final bytes = await File(_profilePicture!.path).readAsBytes();
        base64ProfileImage = base64Encode(bytes);
      }

      final url = getRegisterUrl();
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'first_name': firstName,
          'last_name': lastName,
          'email': _emailController.text,
          'password': _passwordController.text,
          'phone_number': _phoneController.text,
          'age': int.tryParse(_selectedAge ?? '0'),
          'gender': _selectedGender,
          'profile_picture': base64ProfileImage ?? '',
          'role': 'User',
          'address': _addressController.text,
          'bio': _bioController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['message'] == 'User registered successfully') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Registration successful! Please log in.')));
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(_mapServerMessageToFriendlyMessage(
                  responseData['message']))));
        }
      } else {
        print("Server error: ${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Oops! Something went wrong. Please try again later.')));
      }
    } catch (e) {
      print("Registration error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to connect: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _mapServerMessageToFriendlyMessage(String? message) {
    if (message == null) {
      return 'Unknown error occurred.';
    }

    switch (message) {
      case 'Email already in use':
        return 'That email is already registered. Try logging in instead.';
      case 'Phone number already in use':
        return 'That phone number is already linked to another account.';
      case 'Missing required fields':
        return 'Please fill out all the required fields.';
      case 'Invalid email format':
        return 'Please enter a valid email address.';
      default:
        print('Unrecognized server message: $message');
        return 'Something unexpected happened. Please try again.';
    }
  }

  String getBaseUrl() {
    if (Platform.isAndroid || Platform.isIOS) {
      return 'https://salty-citadel-42862-262ec2972a46.herokuapp.com';
    } else {
      return 'http://localhost:8080';
    }
  }

  String getRegisterUrl() {
    return '${getBaseUrl()}/api/register';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: isDarkMode ? Colors.black : Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Picture Selection
              GestureDetector(
                onTap: pickImage,
                child: _profilePicture == null
                    ? CircleAvatar(
                        radius: 60,
                        backgroundColor:
                            isDarkMode ? Colors.grey[700] : Colors.grey[300],
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 40,
                        ),
                      )
                    : CircleAvatar(
                        radius: 60,
                        backgroundImage: FileImage(File(_profilePicture!.path)),
                      ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Email'),
              ),

              SizedBox(height: 16.h),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) => value != null && value.length < 6
                    ? 'Minimum 6 characters'
                    : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter phone number'
                    : null,
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: _selectedAge,
                items: List.generate(83, (index) => (index + 18).toString())
                    .map(
                        (age) => DropdownMenuItem(value: age, child: Text(age)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedAge = value),
                decoration: const InputDecoration(labelText: 'Age'),
              ),

              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: ['Male', 'Female', 'Other']
                    .map((gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                decoration: const InputDecoration(labelText: 'Gender'),
              ),

              SizedBox(height: 16.h),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your address'
                    : null,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _getCurrentLocation,
                    child: const Text('Get Current Location'),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: register,
                      child: const Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
