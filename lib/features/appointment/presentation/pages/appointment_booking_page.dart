import 'package:flutter/material.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState
    extends State<AppointmentBookingScreen> {
  int trainingType = 1;
  DateTime? selectedDate;

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

              const Text("Training Type"),
              Row(
                children: [
                  Radio(
                    value: 1,
                    groupValue: trainingType,
                    onChanged: (v) => setState(() => trainingType = v!),
                  ),
                  const Text("Online"),
                  Radio(
                    value: 2,
                    groupValue: trainingType,
                    onChanged: (v) => setState(() => trainingType = v!),
                  ),
                  const Text("In-Person"),
                ],
              ),

              _textField("Your Goal"),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  selectedDate == null
                      ? "Preferred date"
                      : selectedDate!.toLocal().toString().split(" ")[0],
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickDate,
              ),

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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
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
}
