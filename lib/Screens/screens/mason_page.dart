import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MasonPage extends StatefulWidget {
  const MasonPage({super.key});

  @override
  _MasonPageState createState() => _MasonPageState();
}

class _MasonPageState extends State<MasonPage> {
  List<dynamic> _masons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMasons();
  }

  Future<void> _fetchMasons() async {
    final url = Uri.parse(
        'https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/service_type?serviceTypes=Mason');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _masons = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load masons');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching masons: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masons'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _masons.isEmpty
              ? const Center(child: Text('No masons found'))
              : ListView.builder(
                  itemCount: _masons.length,
                  itemBuilder: (context, index) {
                    final mason = _masons[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        leading: mason['profilePicture'] != null
                            ? Image.memory(
                                const Base64Decoder().convert(mason['profilePicture']),
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 50.0),
                        title: Text(mason['businessName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${mason['email']}'),
                            Text('Phone: ${mason['phoneNumber']}'),
                            Text('Location: ${mason['location']}'),
                            Text('Price per Hour: GHS  ${mason['pricePerHour']}'),
                            Text('Description: ${mason['description']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
