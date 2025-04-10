import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MechanicsPage extends StatefulWidget {
  const MechanicsPage({super.key});

  @override
  _MechanicsPageState createState() => _MechanicsPageState();
}

class _MechanicsPageState extends State<MechanicsPage> {
  List<dynamic> _mechanics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMechanics();
  }

  Future<void> _fetchMechanics() async {
    final url = Uri.parse(
        'https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/service_type?serviceTypes=Mechanic');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _mechanics = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load mechanics');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching mechanics: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanics'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mechanics.isEmpty
              ? const Center(child: Text('No mechanics found'))
              : ListView.builder(
                  itemCount: _mechanics.length,
                  itemBuilder: (context, index) {
                    final mechanic = _mechanics[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        leading: mechanic['profilePicture'] != null
                            ? Image.memory(
                                Base64Decoder().convert(mechanic['profilePicture']),
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 50.0),
                        title: Text(mechanic['businessName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${mechanic['email']}'),
                            Text('Phone: ${mechanic['phoneNumber']}'),
                            Text('Location: ${mechanic['location']}'),
                            Text('Price per Hour: GHS  ${mechanic['pricePerHour']}'),
                            Text('Description: ${mechanic['description']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
