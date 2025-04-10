import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SeeAllPage extends StatefulWidget {
  const SeeAllPage({super.key});

  @override
  _SeeAllPageState createState() => _SeeAllPageState();
}

class _SeeAllPageState extends State<SeeAllPage> {
  List<dynamic> _allProviders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllProviders();
  }

  Future<void> _fetchAllProviders() async {
    final url = Uri.parse(
        'https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/all');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _allProviders = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load providers');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching providers: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Service Providers'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allProviders.isEmpty
              ? const Center(child: Text('No service providers found.'))
              : ListView.builder(
                  itemCount: _allProviders.length,
                  itemBuilder: (context, index) {
                    final provider = _allProviders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        leading: provider['profilePicture'] != null
                            ? Image.memory(
                                base64Decode(provider['profilePicture']),
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 50.0),
                        title: Text(provider['businessName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Service: ${provider['serviceType']}'),
                            Text('Email: ${provider['email']}'),
                            Text('Phone: ${provider['phoneNumber']}'),
                            Text('Location: ${provider['location']}'),
                            Text('Rate: ${provider['pricePerHour']}'),
                            Text('Description: ${provider['description']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
