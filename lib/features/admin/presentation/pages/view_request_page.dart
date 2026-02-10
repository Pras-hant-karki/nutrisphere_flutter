import 'package:flutter/material.dart';

class ViewRequestPage extends StatelessWidget {
  const ViewRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Requests')),
      body: const Center(child: Text('View Request Page')),
    );
  }
}