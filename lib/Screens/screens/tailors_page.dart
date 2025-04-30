import 'dart:convert'; // For decoding JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TailorsPage extends StatefulWidget {
  const TailorsPage({super.key});

  @override
  _TailorsPageState createState() => _TailorsPageState();
}

class _TailorsPageState extends State<TailorsPage> {
  List<dynamic> _tailors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTailors();
  }

  Future<void> _fetchTailors() async {
    final url = Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/service_type?serviceTypes=Tailor');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _tailors = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load tailors');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      print("Error fetching tailors: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tailors'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tailors.isEmpty
              ? const Center(child: Text('No tailors found'))
              : ListView.builder(
                  itemCount: _tailors.length,
                  itemBuilder: (context, index) {
                    final tailor = _tailors[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        leading: tailor['profilePicture'] != null
                            ? Image.memory(
                                const Base64Decoder().convert(tailor['profilePicture']),
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 50.0),
                        title: Text(tailor['businessName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${tailor['email']}'),
                            Text('Phone: ${tailor['phoneNumber']}'),
                            Text('Location: ${tailor['location']}'),
                            Text('Price per Hour: ${tailor['pricePerHour']}'),
                            Text('Description: ${tailor['description']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
