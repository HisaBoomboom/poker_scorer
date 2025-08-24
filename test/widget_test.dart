// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_scorer/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('HomePage initial state test', (WidgetTester tester) async {
    // Set mock initial values for shared_preferences
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const PokerScoreTrackerApp());

    // Verify the title is displayed.
    expect(find.text('Poker Score Tracker'), findsOneWidget);

    // Verify the initial empty state message is shown.
    expect(find.text('No games saved yet.\nPress the "+" button to start a new game.'), findsOneWidget);

    // Verify the FloatingActionButton is present.
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Verify the new ranking button is present.
    expect(find.byIcon(Icons.leaderboard), findsOneWidget);
  });
}
