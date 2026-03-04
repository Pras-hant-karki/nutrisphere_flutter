import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/features/appointment/presentation/pages/appointment_page.dart';

void main() {
  group('AppointmentScreen', () {
    testWidgets('shows service chooser title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AppointmentScreen()));

      expect(find.text('Choose any service below !'), findsOneWidget);
    });

    testWidgets('shows both service cards', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AppointmentScreen()));

      expect(find.text('Request Diet &\nWorkout Plan'), findsOneWidget);
      expect(find.text('Book PT\nAppointment'), findsOneWidget);
    });
  });
}