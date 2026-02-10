import 'package:flutter/material.dart';

class SessionManagePage extends StatelessWidget {
  const SessionManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Management')),
      body: const Center(child: Text('Session Manage Page')),
    );
  }
}