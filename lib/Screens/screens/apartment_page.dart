import 'package:flutter/material.dart';

class ApartmentPage extends StatelessWidget {
  const ApartmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apartments'),
      ),
      body: const Center(
        child: Text(
          'Welcome to Apartments Page',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
