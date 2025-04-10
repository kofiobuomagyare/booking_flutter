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
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        await Permission.photos.request();
        await Permission.camera.request();
      } else {
        await Permission.storage.request();
        await Permission.camera.request();
      }
    } else {
      await Permission.photos.request();
      await Permission.camera.request();
    }
  }

  Future<void> pickImage() async {
    final cameraStatus = await Permission.camera.status;
    final photosStatus = await Permission.photos.status;
    final storageStatus = await Permission.storage.status;

    if ((Platform.isAndroid && await _isAndroid13OrAbove())
        ? (cameraStatus.isGranted && photosStatus.isGranted)
        : (cameraStatus.isGranted && storageStatus.isGranted)) {
      final picker = ImagePicker();
      final pickedFile = await showDialog<XFile?>(context: context, builder: (context) => AlertDialog(
        title: const Text('Pick an Image'),
        actions: [
          TextButton(
            onPressed: () async {
              final file = await picker.pickImage(source: ImageSource.gallery);
              Navigator.pop(context, file);
            },
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () async {
              final file = await picker.pickImage(source: ImageSource.camera);
              Navigator.pop(context, file);
            },
            child: const Text('Camera'),
          ),
        ],
      ));

      if (pickedFile != null) {
        setState(() {
          _profilePicture = pickedFile;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No image selected')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera or storage/photos permission denied')));
    }
  }

  Future<bool> _isAndroid13OrAbove() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 33;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied')));
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      final Placemark place = placemarks.first;
      String address = "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      setState(() {
        _addressController.text = address;
      });
    }
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final url = getRegisterUrl();
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'first_name': _nameController.text.split(" ")[0],
          'last_name': _nameController.text.split(" ")[1],
          'email': _emailController.text,
          'password': _passwordController.text,
          'phone_number': _phoneController.text,
          'age': int.tryParse(_selectedAge ?? '0'),
          'gender': _selectedGender,
          'profile_picture': _profilePicture?.path ?? '',
          'role': 'User',
          'address': _addressController.text,
          'bio': _bioController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['message'] == 'User registered successfully') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful! Please log in.')));
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_mapServerMessageToFriendlyMessage(responseData['message']))));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Oops! Something went wrong. Please try again later.')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to connect. Check your internet and try again.')));
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
              _profilePicture == null
                  ? GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 60,
                      backgroundImage: FileImage(File(_profilePicture!.path)),
                    ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) => value != null && value.length < 6 ? 'Minimum 6 characters' : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Enter phone number' : null,
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: _selectedAge,
                onChanged: (value) => setState(() {
                  _selectedAge = value;
                }),
                items: List.generate(100, (index) {
                  return DropdownMenuItem(
                    value: (index + 1).toString(),
                    child: Text((index + 1).toString()),
                  );
                }),
                decoration: InputDecoration(
                  labelText: 'Age',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (value) => setState(() {
                  _selectedGender = value;
                }),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                decoration: InputDecoration(
                  labelText: 'Gender',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter your address' : null,
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
