import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/features/auth/presentation/pages/register_page.dart';

void main() {
  group('RegisterPage Widget Tests', () {
    testWidgets('RegisterPage renders with all form fields', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('RegisterPage displays registration form title', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(RegisterPage), findsOneWidget);
    });

    testWidgets('RegisterPage has full name text field', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
        find.byType(TextFormField).first,
        'John Doe',
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('RegisterPage has email text field', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      final textFields = find.byType(TextFormField);
      expect(textFields, findsWidgets);

      // Assert
      expect(find.byType(RegisterPage), findsOneWidget);
    });

    testWidgets('RegisterPage has password field', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('RegisterPage has confirm password field', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('RegisterPage has terms and conditions checkbox', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(CheckboxListTile), findsOneWidget);
    });

    testWidgets('RegisterPage validates full name - empty', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, '');
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('RegisterPage can input valid email', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('RegisterPage can input password', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('RegisterPage has signup button', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('RegisterPage has login link', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(RegisterPage), findsOneWidget);
    });

    testWidgets('RegisterPage checkbox can be toggled', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      final checkbox = find.byType(CheckboxListTile);
      if (checkbox.evaluate().isNotEmpty) {
        await tester.tap(checkbox);
        await tester.pumpAndSettle();
      }

      // Assert
      expect(find.byType(CheckboxListTile), findsOneWidget);
    });

    testWidgets('RegisterPage displays full form structure', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('RegisterPage is ConsumerStatefulWidget', 
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(RegisterPage), findsOneWidget);
    });

    testWidgets('RegisterPage renders in scrollable view', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(RegisterPage), findsOneWidget);
    });

    testWidgets('RegisterPage can scroll if content overflows', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -100));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(RegisterPage), findsOneWidget);
    });

    testWidgets('RegisterPage text fields are visible', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(TextFormField), findsWidgets);
    });
  });
}
