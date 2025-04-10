import 'dart:convert'; // For decoding JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CarpentersPage extends StatefulWidget {
  const CarpentersPage({super.key});

  @override
  _CarpentersPageState createState() => _CarpentersPageState();
}

class _CarpentersPageState extends State<CarpentersPage> {
  List<dynamic> _carpenters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCarpenters();
  }

  Future<void> _fetchCarpenters() async {
    final url = Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/service_type?serviceTypes=Carpenter');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _carpenters = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load carpenters');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      print("Error fetching carpenters: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carpenters'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _carpenters.isEmpty
              ? const Center(child: Text('No carpenters found'))
              : ListView.builder(
                  itemCount: _carpenters.length,
                  itemBuilder: (context, index) {
                    final carpenter = _carpenters[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        leading: carpenter['profilePicture'] != null
                            ? Image.memory(
                                Base64Decoder().convert(carpenter['profilePicture']),
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 50.0),
                        title: Text(carpenter['businessName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${carpenter['email']}'),
                            Text('Phone: ${carpenter['phoneNumber']}'),
                            Text('Location: ${carpenter['location']}'),
                            Text('Price per Hour: GHS  ${carpenter['pricePerHour']}'),
                            Text('Description: ${carpenter['description']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
