import 'package:flutter/material.dart';

class RequestPlanScreen extends StatefulWidget {
  const RequestPlanScreen({super.key});

  @override
  State<RequestPlanScreen> createState() => _RequestPlanScreenState();
}

class _RequestPlanScreenState extends State<RequestPlanScreen> {
  int dietType = 2; 
  int medical = 1; 

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
              _header(context, "Request Plan"),
              const SizedBox(height: 20),

              _textField("Height"),
              _rowFields("Weight", "Job"),
              _textField("Any food allergy"),

              const SizedBox(height: 10),
              const Text("Diet Type"),
              Row(
                children: [
                  Radio(
                    value: 1,
                    groupValue: dietType,
                    onChanged: (v) => setState(() => dietType = v!),
                  ),
                  const Text("Veg"),
                  Radio(
                    value: 2,
                    groupValue: dietType,
                    onChanged: (v) => setState(() => dietType = v!),
                  ),
                  const Text("Non-Veg"),
                ],
              ),

              const Text("Any Medical Condition"),
              Row(
                children: [
                  Radio(
                    value: 1,
                    groupValue: medical,
                    onChanged: (v) => setState(() => medical = v!),
                  ),
                  const Text("No"),
                  Radio(
                    value: 2,
                    groupValue: medical,
                    onChanged: (v) => setState(() => medical = v!),
                  ),
                  const Text("Yes"),
                ],
              ),

              _textField("Your Goal"),
              _textField("Any special request or suggestions ?"),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Request"),
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
}
