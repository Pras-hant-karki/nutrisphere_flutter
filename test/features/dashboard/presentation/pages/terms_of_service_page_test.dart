import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/features/dashboard/presentation/pages/terms_of_service_page.dart';

void main() {
  group('TermsOfServiceScreen', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TermsOfServiceScreen()));

      expect(find.text('Terms of Service'), findsOneWidget);
    });

    testWidgets('renders acceptance section', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TermsOfServiceScreen()));

      expect(find.text('Acceptance of Terms'), findsOneWidget);
    });
  });
}