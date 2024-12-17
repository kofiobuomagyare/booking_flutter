// TODO Implement this library.
import 'package:flutter/material.dart';

class BarbersPage extends StatelessWidget {
  const BarbersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barbers'),
      ),
      body: const Center(
        child: Text(
          'Welcome to Barbers Page',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
