import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/widgets/gradient_button.dart';

void main() {
  group('GradientButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GradientButton(label: 'Continue', onPressed: () {})),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('invokes callback on tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(label: 'Tap', onPressed: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(GradientButton));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}