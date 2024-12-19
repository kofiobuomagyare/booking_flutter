import 'package:flutter/material.dart';

class HairdressersPage extends StatelessWidget {
  const HairdressersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hairdressers'),
      ),
      body: const Center(
        child: Text(
          'Welcome to Hairdressers Page',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
