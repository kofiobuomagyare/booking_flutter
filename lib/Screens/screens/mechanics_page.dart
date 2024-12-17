import 'package:flutter/material.dart' show AppBar, BuildContext, Center, Scaffold, StatelessWidget, Text, TextStyle, Widget;

class MechanicsPage extends StatelessWidget {
  const MechanicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanics'),
      ),
      body: const Center(
        child: Text(
          'Welcome to Mechanics Page!',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
