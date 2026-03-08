import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/features/dashboard/presentation/pages/help_center_page.dart';

void main() {
  group('HelpCenterScreen', () {
    testWidgets('renders help center title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HelpCenterScreen()));

      expect(find.text('Help Center'), findsOneWidget);
    });

    testWidgets('renders FAQ section header', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HelpCenterScreen()));

      expect(find.text('Frequently Asked Questions'), findsOneWidget);
    });
  });
}