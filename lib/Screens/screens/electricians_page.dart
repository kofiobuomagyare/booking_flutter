import 'dart:convert'; // For decoding JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ElectriciansPage extends StatefulWidget {
  const ElectriciansPage({super.key});

  @override
  _ElectriciansPageState createState() => _ElectriciansPageState();
}

class _ElectriciansPageState extends State<ElectriciansPage> {
  List<dynamic> _electricians = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchElectricians();
  }

  Future<void> _fetchElectricians() async {
    final url = Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/service_type?serviceTypes=Electrician');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _electricians = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load electricians');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      print("Error fetching electricians: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electricians'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _electricians.isEmpty
              ? const Center(child: Text('No electricians found'))
              : ListView.builder(
                  itemCount: _electricians.length,
                  itemBuilder: (context, index) {
                    final electrician = _electricians[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        leading: electrician['profilePicture'] != null
                            ? Image.memory(
                                Base64Decoder().convert(electrician['profilePicture']),
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 50.0),
                        title: Text(electrician['businessName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${electrician['email']}'),
                            Text('Phone: ${electrician['phoneNumber']}'),
                            Text('Location: ${electrician['location']}'),
                            Text('Price per Hour: GHS  ${electrician['pricePerHour']}'),
                            Text('Description: ${electrician['description']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
