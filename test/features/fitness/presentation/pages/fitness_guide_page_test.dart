import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/services/storage/user_session_service.dart';
import 'package:nutrisphere_flutter/features/fitness/presentation/pages/fitness_guide_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: FitnessGuideScreen()),
      ),
    );
  }

  group('FitnessGuideScreen', () {
    testWidgets('shows screen title', (tester) async {
      await pumpPage(tester);

      expect(find.text('High quality fitness guidance below !'), findsOneWidget);
    });

    testWidgets('starts in loading state', (tester) async {
      await pumpPage(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}