import 'package:flutter/material.dart';

class AdminBioPage extends StatelessWidget {
  const AdminBioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Bio')),
      body: const Center(child: Text('Admin Bio Page')),
    );
  }
}