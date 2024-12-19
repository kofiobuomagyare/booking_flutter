import 'package:flutter/material.dart';

class PaintersPage extends StatelessWidget {
  const PaintersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painters'),
      ),
      body: const Center(
        child: Text(
          'Welcome to Painters Page',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
