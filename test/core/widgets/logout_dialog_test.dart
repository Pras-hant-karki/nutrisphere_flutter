import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/widgets/logout_dialog.dart';

void main() {
  group('LogoutDialog', () {
    testWidgets('renders logout confirmation text', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
        return Scaffold(body: TextButton(onPressed: () => showDialog(context: context, builder: (_) => LogoutDialog(onConfirm: () {})), child: const Text('Open')));
      })));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Are you sure you want to logout?'), findsOneWidget);
    });

    testWidgets('calls onConfirm on logout tap', (tester) async {
      var called = false;
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
        return Scaffold(body: TextButton(onPressed: () => showDialog(context: context, builder: (_) => LogoutDialog(onConfirm: () => called = true)), child: const Text('Open')));
      })));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });
  });
}