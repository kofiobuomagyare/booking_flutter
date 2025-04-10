// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingScreen extends StatefulWidget {
  final String token;

  // Constructor that accepts the token
  const BookingScreen({Key? key, required this.token}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<dynamic> serviceProviders = [];
  String selectedServiceProviderId = '';
  String userId = '';
  DateTime selectedDate = DateTime.now();
  String phoneNumber = '';

  // Fetch all service providers
  Future<void> fetchServiceProviders() async {
    final response = await http.get(Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/all'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        serviceProviders = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load service providers');
    }
  }

  // Fetch user ID using the phone number
  // Fetch user ID using the phone number
Future<void> fetchUserId() async {
  final response = await http.get(
    Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/users/findUserIdByPhone?phone=$phoneNumber'),
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body); // Decode the JSON response
    setState(() {
      userId = data['user_id']; // Extract the 'user_id' from the response
    });
  } else {
    setState(() {
      userId = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not found')));
  }
}

  // Create an appointment
  Future<void> createAppointment() async {
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid phone number')));
      return;
    }

    final appointment = {
      'user_id': userId,
      'service_provider_id': selectedServiceProviderId,
      'appointmentDate': selectedDate.toIso8601String(),
      'status': 'Pending',
    };

    final response = await http.post(
      Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/appointments/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(appointment),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Appointment created successfully!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create appointment')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchServiceProviders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Service Provider:'),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedServiceProviderId.isNotEmpty ? selectedServiceProviderId : null,
              onChanged: (newValue) {
                setState(() {
                  selectedServiceProviderId = newValue!;
                });
              },
              items: serviceProviders.map<DropdownMenuItem<String>>((provider) {
                return DropdownMenuItem<String>(
                  value: provider['service_provider_id'],
                  child: Text(provider['businessName']),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text('Enter Your Phone Number:'),
            TextField(
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                setState(() {
                  phoneNumber = value;
                });
              },
              decoration: InputDecoration(hintText: 'Enter phone number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchUserId,
              child: Text('Fetch User ID'),
            ),
            SizedBox(height: 20),
            Text('Select Appointment Date:'),
            ListTile(
              title: Text("${selectedDate.toLocal()}".split(' ')[0]),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != selectedDate)
                  setState(() {
                    selectedDate = picked;
                  });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: createAppointment,
              child: Text('Book Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
