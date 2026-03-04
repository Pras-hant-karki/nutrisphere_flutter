import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/widgets/custom_app_bar.dart';

void main() {
  group('CustomAppBar', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(appBar: CustomAppBar(title: 'Settings'))));

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(appBar: CustomAppBar(title: 'Settings', subtitle: 'Manage'))));

      expect(find.text('Manage'), findsOneWidget);
    });

  });
}