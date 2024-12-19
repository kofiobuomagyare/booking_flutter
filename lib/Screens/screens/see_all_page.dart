import 'package:flutter/material.dart';

class SeeAllPage extends StatelessWidget {
  const SeeAllPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('See All'),
      ),
      body: const Center(
        child: Text(
          'Welcome to See All Page',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
