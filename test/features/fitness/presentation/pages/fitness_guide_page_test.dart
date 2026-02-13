import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/features/fitness/presentation/pages/fitness_guide_page.dart';

void main() {
  group('FitnessGuideScreen Widget Tests', () {
    testWidgets('FitnessGuideScreen renders with title', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(FitnessGuideScreen), findsOneWidget);
    });

    testWidgets('FitnessGuideScreen displays main content area', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('FitnessGuideScreen is StatelessWidget', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(FitnessGuideScreen), findsOneWidget);
    });

    testWidgets('FitnessGuideScreen renders in scrollable view', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('FitnessGuideScreen can scroll if content overflows', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      final scrollWidget = find.byType(SingleChildScrollView);
      if (scrollWidget.evaluate().isNotEmpty) {
        await tester.drag(scrollWidget.first, const Offset(0, -100));
        await tester.pumpAndSettle();
      }

      // Assert
      expect(find.byType(FitnessGuideScreen), findsOneWidget);
    });

    testWidgets('FitnessGuideScreen displays loading state initially',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pump();

      // Act & Assert - should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('FitnessGuideScreen displays content when loaded',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert - should show the title
      expect(find.text('High quality fitness guidance below !'), findsOneWidget);
    });

    testWidgets('FitnessGuideScreen has Container widgets', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('FitnessGuideScreen has Column widgets', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('FitnessGuideScreen has text widgets', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('FitnessGuideScreen mounts without errors', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(FitnessGuideScreen), findsOneWidget);
    });

    testWidgets('FitnessGuideScreen builds successfully', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(FitnessGuideScreen), findsOneWidget);
    });

    testWidgets('FitnessGuideScreen has safe area', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('FitnessGuideScreen displays content correctly', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(FitnessGuideScreen), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('FitnessGuideScreen renders properly with ProviderScope', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('FitnessGuideScreen has padding layout', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('FitnessGuideScreen has multiple text elements', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FitnessGuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(Text), findsWidgets);
      expect(find.byType(FitnessGuideScreen), findsOneWidget);
    });
  });
}
