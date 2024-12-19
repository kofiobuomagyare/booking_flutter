import 'package:flutter/material.dart';

class PlumbersPage extends StatelessWidget {
  const PlumbersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plumbers'),
      ),
      body: const Center(
        child: Text(
          'Welcome to Plumbers Page',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
