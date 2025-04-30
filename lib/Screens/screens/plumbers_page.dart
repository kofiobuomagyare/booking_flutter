import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlumbersPage extends StatefulWidget {
  const PlumbersPage({super.key});

  @override
  _PlumbersPageState createState() => _PlumbersPageState();
}

class _PlumbersPageState extends State<PlumbersPage> {
  List<dynamic> _plumbers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlumbers();
  }

  Future<void> _fetchPlumbers() async {
    final url = Uri.parse(
        'https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/service_type?serviceTypes=Plumber');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _plumbers = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load plumbers');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching plumbers: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plumbers'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plumbers.isEmpty
              ? const Center(child: Text('No plumbers found'))
              : ListView.builder(
                  itemCount: _plumbers.length,
                  itemBuilder: (context, index) {
                    final plumber = _plumbers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        leading: plumber['profilePicture'] != null
                            ? Image.memory(
                                const Base64Decoder().convert(plumber['profilePicture']),
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 50.0),
                        title: Text(plumber['businessName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${plumber['email']}'),
                            Text('Phone: ${plumber['phoneNumber']}'),
                            Text('Location: ${plumber['location']}'),
                            Text('Price per Hour: GHS  ${plumber['pricePerHour']}'),
                            Text('Description: ${plumber['description']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
