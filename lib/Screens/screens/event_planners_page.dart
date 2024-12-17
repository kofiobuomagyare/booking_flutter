// TODO Implement this library.
import 'package:flutter/material.dart';

class EventPlannersPage extends StatelessWidget {
  const EventPlannersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Planners'),
      ),
      body: const Center(
        child: Text(
          'Welcome to Event Planners Page',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
