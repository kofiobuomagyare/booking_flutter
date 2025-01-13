import 'package:flutter/material.dart';
import 'package:app_develop/services/profile_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterPageState createState() => _RegisterPageState();
}

const String baseUrl = 'http://172.20.10.9:8080'; // Define your base URL here

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  String _gender = "Female"; // Default value
  String _role = "Service Provider"; // Default value

  final ProfileService profileService = ProfileService();

  Future<bool> registerUser({
  required String firstName,
  required String lastName,
  required String email,
  required String password,
  required String phoneNumber,
  required String location,
  required String gender,
  required String bio,
  required String role,
}) async {
  final url = Uri.parse('$baseUrl/register');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'location': location,
      'gender': gender,
      'bio': bio,
      'role': role,
      'profilePicture': '', // Placeholder for now
    }),
  );

  if (response.statusCode == 201) {
    return true;
  } else {
    throw Exception('Registration failed: ${response.body}');
  }
}

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        bool success = await registerUser(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phoneNumber: _phoneNumberController.text,
          location: _locationController.text,
          gender: _gender,
          bio: _bioController.text,
          role: _role,
        );
        if (success) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful')),
          );
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your first name' : null,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your last name' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your email' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) =>
                      (value != null && value.length < 6) ? 'Password must be at least 6 characters' : null,
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your phone number' : null,
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your location' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _gender,
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                    DropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  onChanged: (value) => setState(() => _gender = value ?? "Female"),
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                DropdownButtonFormField<String>(
                  value: _role,
                  items: const [
                    DropdownMenuItem(
                        value: "Service Provider", child: Text("Service Provider")),
                    DropdownMenuItem(
                        value: "Service Seeker", child: Text("Service Seeker")),
                  ],
                  onChanged: (value) => setState(() => _role = value ?? "Service Provider"),
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(labelText: 'Bio'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a brief bio' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
