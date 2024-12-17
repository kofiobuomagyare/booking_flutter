// TODO Implement this library.

import 'package:flutter/material.dart';

class ElectriciansPage extends StatelessWidget {
  const ElectriciansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electricians'),
      ),
      body: const Center(
        child: Text(
          'Welcome to Electricians Page',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
