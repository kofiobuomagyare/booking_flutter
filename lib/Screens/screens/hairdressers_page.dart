import 'dart:convert'; // For decoding base64
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HairdressersPage extends StatefulWidget {
  const HairdressersPage({super.key});

  @override
  _HairdressersPageState createState() => _HairdressersPageState();
}

class _HairdressersPageState extends State<HairdressersPage> {
  List<dynamic> _hairdressers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHairdressers();
  }

  Future<void> _fetchHairdressers() async {
    final url = Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/service_type?serviceTypes=Hairdresser');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _hairdressers = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load hairdressers');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching hairdressers: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hairdressers'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hairdressers.isEmpty
              ? const Center(child: Text('No hairdressers found'))
              : ListView.builder(
                  itemCount: _hairdressers.length,
                  itemBuilder: (context, index) {
                    final hairdresser = _hairdressers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        leading: hairdresser['profilePicture'] != null
                            ? Image.memory(
                                const Base64Decoder().convert(hairdresser['profilePicture']),
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 50.0),
                        title: Text(hairdresser['businessName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${hairdresser['email']}'),
                            Text('Phone: ${hairdresser['phoneNumber']}'),
                            Text('Location: ${hairdresser['location']}'),
                            Text('Price per Hour: GHS  ${hairdresser['pricePerHour']}'),
                            Text('Description: ${hairdresser['description']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
