import 'dart:convert'; // For decoding JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChefPage extends StatefulWidget {
  const ChefPage({super.key});

  @override
  _ChefPageState createState() => _ChefPageState();
}

class _ChefPageState extends State<ChefPage> {
  List<dynamic> _chefs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChefs();
  }

  Future<void> _fetchChefs() async {
    final url = Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/service_type?serviceTypes=Chef');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _chefs = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load chefs');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      print("Error fetching chefs: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chefs'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chefs.isEmpty
              ? const Center(child: Text('No chefs found'))
              : ListView.builder(
                  itemCount: _chefs.length,
                  itemBuilder: (context, index) {
                    final chef = _chefs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        leading: chef['profilePicture'] != null
                            ? Image.memory(
                                const Base64Decoder().convert(chef['profilePicture']),
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 50.0),
                        title: Text(chef['businessName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${chef['email']}'),
                            Text('Phone: ${chef['phoneNumber']}'),
                            Text('Location: ${chef['location']}'),
                            Text('Price per Hour: GHS  ${chef['pricePerHour']}'),
                            Text('Description: ${chef['description']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
