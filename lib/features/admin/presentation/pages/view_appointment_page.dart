import 'package:flutter/material.dart';

class ViewAppointmentPage extends StatelessWidget {
  const ViewAppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Appointments')),
      body: const Center(child: Text('View Appointment Page')),
    );
  }
}