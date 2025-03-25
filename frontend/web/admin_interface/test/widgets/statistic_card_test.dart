import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_interface/widgets/statistic_card.dart';

void main() {
  group('StatisticCard Widget Tests', () {
    testWidgets('StatisticCard displays correct title and value', (WidgetTester tester) async {
      // Build our widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatisticCard(
            title: 'Total Customers',
            value: '150',
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
      ));

      // Verify the title is displayed
      expect(find.text('Total Customers'), findsOneWidget);
      
      // Verify the value is displayed
      expect(find.text('150'), findsOneWidget);
      
      // Verify the icon is displayed
      expect(find.byIcon(Icons.people), findsOneWidget);
    });
    
    testWidgets('StatisticCard displays subtitle when provided', (WidgetTester tester) async {
      // Build our widget with a subtitle
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatisticCard(
            title: 'Total Revenue',
            value: 'TD 15,000',
            subtitle: '+5% from last month',
            icon: Icons.monetization_on,
            color: Colors.green,
          ),
        ),
      ));

      // Verify the title is displayed
      expect(find.text('Total Revenue'), findsOneWidget);
      
      // Verify the value is displayed
      expect(find.text('TD 15,000'), findsOneWidget);
      
      // Verify the subtitle is displayed
      expect(find.text('+5% from last month'), findsOneWidget);
      
      // Verify the icon is displayed
      expect(find.byIcon(Icons.monetization_on), findsOneWidget);
    });
    
    testWidgets('StatisticCard onTap works correctly', (WidgetTester tester) async {
      // Track if onTap was called
      bool wasTapped = false;
      
      // Build our widget with an onTap callback
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatisticCard(
            title: 'Active Vehicles',
            value: '75',
            icon: Icons.directions_car,
            color: Colors.orange,
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      ));

      // Verify initial state
      expect(wasTapped, false);
      
      // Tap the card
      await tester.tap(find.byType(StatisticCard));
      
      // Verify the onTap callback was called
      expect(wasTapped, true);
    });
    
    testWidgets('StatisticCard applies correct styling', (WidgetTester tester) async {
      // Define a custom color
      final customColor = Colors.purple;
      
      // Build our widget with custom color
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatisticCard(
            title: 'Completed Repairs',
            value: '42',
            icon: Icons.build,
            color: customColor,
          ),
        ),
      ));

      // Find the container with the background color
      final cardFinder = find.ancestor(
        of: find.byIcon(Icons.build),
        matching: find.byType(Container),
      ).first;
      
      // Get the Container widget
      final container = tester.widget<Container>(cardFinder);
      
      // Check if the decoration has the correct color
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(customColor.withOpacity(0.1)));
      
      // Find the icon
      final iconFinder = find.byIcon(Icons.build);
      final icon = tester.widget<Icon>(iconFinder);
      
      // Check if the icon has the correct color
      expect(icon.color, equals(customColor));
    });
    
    testWidgets('StatisticCard handles loading state correctly', (WidgetTester tester) async {
      // Build our widget in loading state
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatisticCard(
            title: 'Total Repairs',
            value: '',
            icon: Icons.build,
            color: Colors.blue,
            isLoading: true,
          ),
        ),
      ));

      // Verify the title is displayed
      expect(find.text('Total Repairs'), findsOneWidget);
      
      // Verify the value is not displayed
      expect(find.text(''), findsNothing);
      
      // Verify the loading indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
} 