// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:convert'; // For decoding JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BarbersPage extends StatefulWidget {
  const BarbersPage({super.key});

  @override
  _BarbersPageState createState() => _BarbersPageState();
}

class _BarbersPageState extends State<BarbersPage> {
  List<dynamic> _barbers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBarbers();
  }

  Future<void> _fetchBarbers() async {
    final url = Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/service_type?serviceTypes=Barber');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _barbers = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load barbers');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      print("Error fetching barbers: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barbers'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _barbers.isEmpty
              ? const Center(child: Text('No barbers found'))
              : ListView.builder(
                  itemCount: _barbers.length,
                  itemBuilder: (context, index) {
                    final barber = _barbers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        leading: barber['profilePicture'] != null
                            ? Image.memory(
                                const Base64Decoder().convert(barber['profilePicture']),
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 50.0),
                        title: Text(barber['businessName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${barber['email']}'),
                            Text('Phone: ${barber['phoneNumber']}'),
                            Text('Location: ${barber['location']}'),
                            Text('Price per Hour: GHS  ${barber['pricePerHour']}'),
                            Text('Description: ${barber['description']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
