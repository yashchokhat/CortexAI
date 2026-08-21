// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cortexai_app/main.dart';

void main() {
  testWidgets('App shows loading page then navigates to home',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify the loading page is displayed initially.
    expect(find.text('Loading CortexAI...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Advance past the 3-second loading delay and settle all animations.
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // After the delay, the app should navigate to the home page.
    expect(find.text('Flutter Demo Home Page'), findsOneWidget);
  });
}
