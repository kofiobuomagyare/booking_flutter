import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingScreen extends StatefulWidget {
  final String token;

  const BookingScreen({super.key, required this.token});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<dynamic> serviceProviders = [];
  String selectedServiceProviderId = '';
  String userId = '';
  DateTime selectedDate = DateTime.now();
  String phoneNumber = '';
  String password = '';
  List<dynamic> userAppointments = [];

  @override
  void initState() {
    super.initState();
    fetchServiceProviders();
  }

  // Fetch all service providers
  Future<void> fetchServiceProviders() async {
    final response = await http.get(Uri.parse(
        'https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/all'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        serviceProviders = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load service providers');
    }
  }

  // Fetch user ID using phone and password
  Future<void> fetchUserId() async {
    final response = await http.get(Uri.parse(
        'https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/users/findUserIdByPhoneNumberAndPassword?phoneNumber=$phoneNumber&password=$password'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      setState(() {
        userId = data['user_id'];
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User ID fetched successfully')));
      fetchUserAppointments();
    } else {
      setState(() {
        userId = '';
        userAppointments = [];
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User not found')));
    }
  }

  // Book an appointment
  Future<void> createAppointment() async {
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter valid credentials')));
      return;
    }

    final appointment = {
      'user_id': userId,
      'service_provider_id': selectedServiceProviderId,
      'appointmentDate': selectedDate.toIso8601String(),
      'status': 'Pending',
    };

    final response = await http.post(
      Uri.parse(
          'https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/appointments/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(appointment),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment created successfully')));
      fetchUserAppointments(); // Refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create appointment')));
    }
  }

  // Fetch all appointments by this user
  Future<void> fetchUserAppointments() async {
    final response = await http.get(
      Uri.parse(
          'https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/appointments/all'),
    );

    if (response.statusCode == 200) {
      List<dynamic> allAppointments = json.decode(response.body);
      List<dynamic> filtered = allAppointments
          .where((appt) => appt['user_id'].toString() == userId)
          .toList();

      setState(() {
        userAppointments = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Service Provider:'),
            DropdownButton<String>(
              isExpanded: true,
              value:
                  selectedServiceProviderId.isNotEmpty ? selectedServiceProviderId : null,
              hint: Text("Choose a provider"),
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
              onChanged: (value) => phoneNumber = value,
              decoration: InputDecoration(hintText: 'Phone number'),
            ),
            SizedBox(height: 10),
            Text('Enter Your Password:'),
            TextField(
              obscureText: true,
              onChanged: (value) => password = value,
              decoration: InputDecoration(hintText: 'Password'),
            ),
            SizedBox(height: 10),
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
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: createAppointment,
              child: Text('Book Appointment'),
            ),
            SizedBox(height: 30),
            Divider(),
            Text(
              'Previous Appointments',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            userAppointments.isEmpty
                ? Text('No appointments found.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: userAppointments.length,
                    itemBuilder: (context, index) {
                      final appt = userAppointments[index];
                      return ListTile(
                        leading: Icon(Icons.event_note),
                        title: Text('Provider ID: ${appt['service_provider_id']}'),
                        subtitle: Text(
                            'Date: ${appt['appointmentDate']}\nStatus: ${appt['status']}'),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
