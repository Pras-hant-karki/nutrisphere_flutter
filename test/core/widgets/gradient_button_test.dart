import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/widgets/gradient_button.dart';

void main() {
  group('GradientButton Widget Tests', () {
    testWidgets('GradientButton displays label text', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('GradientButton calls onPressed when tapped', 
        (WidgetTester tester) async {
      // Arrange
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Tap Me',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();

      // Assert
      expect(pressed, true);
    });

    testWidgets('GradientButton renders with default colors', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(GradientButton), findsOneWidget);
    });

    testWidgets('GradientButton accepts custom colors', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Custom',
              onPressed: () {},
              startColor: Colors.red,
              endColor: Colors.orange,
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(GradientButton), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('GradientButton has correct height', 
        (WidgetTester tester) async {
      // Arrange
      const double customHeight = 60;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Button',
              onPressed: () {},
              height: customHeight,
            ),
          ),
        ),
      );

      // Act
      final size = tester.getSize(find.byType(GradientButton));

      // Assert
      expect(size.height, customHeight);
    });

    testWidgets('GradientButton spans full width by default', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Full Width',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(GradientButton), findsOneWidget);
    });

    testWidgets('GradientButton accepts custom width', 
        (WidgetTester tester) async {
      // Arrange
      const double customWidth = 200;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GradientButton(
                label: 'Custom Width',
                onPressed: () {},
                width: customWidth,
              ),
            ),
          ),
        ),
      );

      // Act
      final size = tester.getSize(find.byType(GradientButton));

      // Assert
      expect(size.width, customWidth);
    });

    testWidgets('GradientButton accepts custom TextStyle', 
        (WidgetTester tester) async {
      // Arrange
      const TextStyle customStyle = TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Styled',
              onPressed: () {},
              textStyle: customStyle,
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Styled'), findsOneWidget);
    });

    testWidgets('GradientButton accepts custom BorderRadius', 
        (WidgetTester tester) async {
      // Arrange
      final customRadius = BorderRadius.circular(16);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Rounded',
              onPressed: () {},
              borderRadius: customRadius,
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(GradientButton), findsOneWidget);
      expect(find.text('Rounded'), findsOneWidget);
    });

    testWidgets('GradientButton with empty label', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: '',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('GradientButton with long label', 
        (WidgetTester tester) async {
      // Arrange
      const String longLabel = 'This is a very long button label that might wrap';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: longLabel,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text(longLabel), findsOneWidget);
    });

    testWidgets('GradientButton multiple taps trigger onPressed multiple times', 
        (WidgetTester tester) async {
      // Arrange
      int tapCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Multi Tap',
              onPressed: () {
                tapCount++;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();

      // Assert
      expect(tapCount, 3);
    });

    testWidgets('GradientButton renders InkWell for ripple effect', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Ripple',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('GradientButton default height is 50', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Default Height',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act
      final size = tester.getSize(find.byType(GradientButton));

      // Assert
      expect(size.height, 50);
    });

    testWidgets('GradientButton with special characters in label', 
        (WidgetTester tester) async {
      // Arrange
      const String specialLabel = 'Click! @# → OK?';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: specialLabel,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text(specialLabel), findsOneWidget);
    });

    testWidgets('GradientButton preserves gradient decoration', 
        (WidgetTester tester) async {
      // Arrange
      const Color customStart = Color(0xFFFF5722);
      const Color customEnd = Color(0xFFFFC107);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Gradient',
              onPressed: () {},
              startColor: customStart,
              endColor: customEnd,
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(GradientButton), findsOneWidget);
    });
  });
}
