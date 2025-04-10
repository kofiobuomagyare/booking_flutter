import 'dart:convert'; // For decoding base64
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MakeupArtistPage extends StatefulWidget {
  const MakeupArtistPage({super.key});

  @override
  _MakeupArtistPageState createState() => _MakeupArtistPageState();
}

class _MakeupArtistPageState extends State<MakeupArtistPage> {
  List<dynamic> _makeupArtists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMakeupArtists();
  }

  Future<void> _fetchMakeupArtists() async {
    final url = Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/service_type?serviceTypes=Makeup Artist');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _makeupArtists = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load makeup artists');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching makeup artists: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Makeup Artists'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _makeupArtists.isEmpty
              ? const Center(child: Text('No makeup artists found'))
              : ListView.builder(
                  itemCount: _makeupArtists.length,
                  itemBuilder: (context, index) {
                    final artist = _makeupArtists[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        leading: artist['profilePicture'] != null
                            ? Image.memory(
                                Base64Decoder().convert(artist['profilePicture']),
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 50.0),
                        title: Text(artist['businessName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${artist['email']}'),
                            Text('Phone: ${artist['phoneNumber']}'),
                            Text('Location: ${artist['location']}'),
                            Text('Price per Hour: ${artist['pricePerHour']}'),
                            Text('Description: ${artist['description']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
