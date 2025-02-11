import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ServiceProviderHome extends StatefulWidget {
  const ServiceProviderHome({super.key, required String token});

  @override
  // ignore: library_private_types_in_public_api
  _ServiceProviderHomeState createState() => _ServiceProviderHomeState();
}

class _ServiceProviderHomeState extends State<ServiceProviderHome> {
  int _selectedIndex = 0;
  List<dynamic> _appointments = [];
  final String serviceProviderId = "nsaserv001"; // Replace with actual ID
  File? _image;
  final picker = ImagePicker();
  bool _isAtWork = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    final url = Uri.parse('http://http://10.0.2.2:8080/appointments/service-provider/$serviceProviderId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _appointments = json.decode(response.body);
      });
    } else {
      if (kDebugMode) {
        print('Failed to load appointments');
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    final url = Uri.parse('http://10.0.2.2:8080/service-provider/upload-image');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', _image!.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Image uploaded successfully");
      }
    } else {
      if (kDebugMode) {
        print("Image upload failed");
      }
    }
  }

  Widget _buildAppointmentsList() {
    return CupertinoScrollbar(
      child: ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          var appointment = _appointments[index];
          return ListTile(
            title: Text('User: ${appointment['user_id']}'),
            subtitle: Text('Status: ${appointment['status']}\nDate: ${appointment['appointmentDate']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  child: const Text("Accept"),
                  onPressed: () {},
                ),
                CupertinoButton(
                  child: const Text("Decline"),
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBusinessForm() {
    return Column(
      children: [
        CupertinoButton(
          onPressed: _pickImage,
          child: const Text("Pick Image"),
        ),
        _image == null ? const Text("No image selected") : Image.file(_image!),
        CupertinoButton(
          onPressed: _uploadImage,
          child: const Text("Upload Image"),
        ),
      ],
    );
  }

  Widget _buildStatusToggle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Status: ${_isAtWork ? "At Work" : "Closed"}"),
        CupertinoSwitch(
          value: _isAtWork,
          onChanged: (bool value) {
            setState(() {
              _isAtWork = value;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Service Provider Home"),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _selectedIndex == 0
                  ? _buildAppointmentsList()
                  : _selectedIndex == 1
                      ? _buildBusinessForm()
                      : _buildStatusToggle(),
            ),
            CupertinoTabBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.calendar), label: "Appointments"),
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.photo), label: "Business"),
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.check_mark), label: "Availability"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
