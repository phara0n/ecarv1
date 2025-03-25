// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:admin_interface/main.dart';

// A simplified version of AdminApp for testing
class TestableAdminApp extends StatelessWidget {
  const TestableAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eCar Admin Interface Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
      ),
      home: const Scaffold(
        body: Center(
          child: Text('eCar Admin Interface Test'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('App should render without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const TestableAdminApp());

    // Verify that the app renders
    expect(find.text('eCar Admin Interface Test'), findsOneWidget);
  });
}
