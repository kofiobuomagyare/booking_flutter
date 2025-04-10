import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaintersPage extends StatefulWidget {
  const PaintersPage({super.key});

  @override
  _PaintersPageState createState() => _PaintersPageState();
}

class _PaintersPageState extends State<PaintersPage> {
  List<dynamic> _painters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPainters();
  }

  Future<void> _fetchPainters() async {
    final url = Uri.parse(
        'https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/service_type?serviceTypes=Painter');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _painters = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load painters');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching painters: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painters'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _painters.isEmpty
              ? const Center(child: Text('No painters found'))
              : ListView.builder(
                  itemCount: _painters.length,
                  itemBuilder: (context, index) {
                    final painter = _painters[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        leading: painter['profilePicture'] != null
                            ? Image.memory(
                                Base64Decoder().convert(painter['profilePicture']),
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 50.0),
                        title: Text(painter['businessName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${painter['email']}'),
                            Text('Phone: ${painter['phoneNumber']}'),
                            Text('Location: ${painter['location']}'),
                            Text('Price per Hour: GHS ${painter['pricePerHour']}'),
                            Text('Description: ${painter['description']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
