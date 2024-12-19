import 'package:flutter/material.dart';

class NailTechniciansPage extends StatelessWidget {
  const NailTechniciansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nail Technicians'),
      ),
      body: const Center(
        child: Text(
          'Welcome to Nail Technicians Page',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
