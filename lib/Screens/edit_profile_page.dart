import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:app_develop/services/auth_service.dart';
import 'package:app_develop/Screens/login.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final String token;

  const EditProfilePage({
    Key? key,
    required this.profileData,
    required this.token,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for input fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _ageController;
  
  String _selectedGender = '';
  String? _profilePicture;
  bool _isLoading = false;
  bool _pictureChanged = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data
    _firstNameController = TextEditingController(text: widget.profileData['first_name'] ?? '');
    _lastNameController = TextEditingController(text: widget.profileData['last_name'] ?? '');
    _emailController = TextEditingController(text: widget.profileData['email'] ?? '');
    _addressController = TextEditingController(text: widget.profileData['address'] ?? '');
    _ageController = TextEditingController(text: widget.profileData['age']?.toString() ?? '');
    _selectedGender = widget.profileData['gender'] ?? 'Male';
    _profilePicture = widget.profileData['profile_picture'];
  }

  @override
  void dispose() {
    // Clean up controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedImage == null) return;
      
      // Read file as bytes and convert to base64
      final bytes = await File(pickedImage.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      
      setState(() {
        _profilePicture = base64Image;
        _pictureChanged = true;
      });
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Create update data payload
      final Map<String, dynamic> updateData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'gender': _selectedGender,
      };
      
      // Only add age if it's not empty
      if (_ageController.text.isNotEmpty) {
        updateData['age'] = int.parse(_ageController.text);
      }
      
      // Only add profile picture if it was changed
      if (_pictureChanged && _profilePicture != null) {
        updateData['profile_picture'] = _profilePicture;
      }
      
      // Use the AuthService method to update profile
      final result = await authService.updateProfile(updateData);
      
      if (result['success']) {
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate successful update
        }
      } else {
        // Check if authentication expired
        if (result['message'] == 'Authentication expired') {
          _redirectToLogin();
        } else {
          throw Exception(result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Update failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _redirectToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    Widget imageWidget;
    
    if (_profilePicture != null && _profilePicture!.isNotEmpty) {
      try {
        // Clean the base64 string
        String cleanedBase64 = _cleanBase64String(_profilePicture!);
        imageWidget = CircleAvatar(
          radius: 60,
          backgroundImage: MemoryImage(base64Decode(cleanedBase64)),
        );
      } catch (e) {
        debugPrint('Error decoding profile picture: $e');
        imageWidget = _buildDefaultProfileIcon();
      }
    } else {
      imageWidget = _buildDefaultProfileIcon();
    }
    
    return Stack(
      children: [
        imageWidget,
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF5E5CE6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultProfileIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF5E5CE6).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        CupertinoIcons.person_fill,
        size: 60,
        color: Color(0xFF5E5CE6),
      ),
    );
  }

  String _cleanBase64String(String input) {
    // Remove any whitespace, newlines, or other non-base64 characters
    String cleaned = input.trim()
      .replaceAll('\n', '')
      .replaceAll('\r', '')
      .replaceAll(' ', '');
    
    // Ensure padding is correct (must be multiple of 4)
    while (cleaned.length % 4 != 0) {
      cleaned += '=';
    }
    
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF5E5CE6),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5E5CE6)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5E5CE6)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture with Edit Button
                    _buildProfilePicture(),
                    
                    const SizedBox(height: 30),
                    
                    // Form Fields
                    TextFormField(
                      controller: _firstNameController,
                      decoration: _inputDecoration('First Name', CupertinoIcons.person),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _lastNameController,
                      decoration: _inputDecoration('Last Name', CupertinoIcons.person),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration('Email', CupertinoIcons.mail),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _ageController,
                      decoration: _inputDecoration('Age', CupertinoIcons.calendar),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          try {
                            int age = int.parse(value);
                            if (age <= 0 || age > 120) {
                              return 'Please enter a valid age';
                            }
                          } catch (e) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Gender Selection
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.person, color: Colors.grey.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: const Text('Select Gender'),
                                value: _selectedGender,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedGender = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _addressController,
                      decoration: _inputDecoration('Address', CupertinoIcons.location),
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E5CE6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5E5CE6)),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}