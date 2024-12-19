import 'package:flutter/material.dart';

class CarpentersPage extends StatelessWidget {
  const CarpentersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carpenters'),
      ),
      body: const Center(
        child: Text(
          'Welcome to Carpenters Page!',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
