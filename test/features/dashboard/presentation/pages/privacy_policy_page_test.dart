import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/features/dashboard/presentation/pages/privacy_policy_page.dart';

void main() {
  group('PrivacyPolicyScreen', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyScreen()));

      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('renders contact section', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyScreen()));

      expect(find.text('Contact Us'), findsOneWidget);
    });
  });
}