import 'package:flutter/material.dart';

class AppointmentBookingScreen extends StatelessWidget {
  const AppointmentBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context, "PT Appointment"),

              const SizedBox(height: 20),

              _textField("Height"),
              _rowFields("Weight", "Job"),
              _trainingType(),
              _textField("Your Goal"),
              _textField("Preferred date"),
              _textField("Any special request or suggestions ?"),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Book"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String title) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _textField(String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        decoration: InputDecoration(hintText: hint),
      ),
    );
  }

  Widget _rowFields(String h1, String h2) {
    return Row(
      children: [
        Expanded(child: _textField(h1)),
        const SizedBox(width: 12),
        Expanded(child: _textField(h2)),
      ],
    );
  }

  Widget _trainingType() {
    return Row(
      children: const [
        Text("Training Type"),
        SizedBox(width: 12),
        Radio(value: 1, groupValue: 1, onChanged: null),
        Text("Online"),
        Radio(value: 2, groupValue: 1, onChanged: null),
        Text("In-Person"),
      ],
    );
  }
}
