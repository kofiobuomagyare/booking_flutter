import 'package:flutter/material.dart';

class TailorsPage extends StatelessWidget {
  const TailorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tailors'),
      ),
      body: const Center(
        child: Text(
          'Welcome to Tailors Page',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
