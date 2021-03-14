// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukrpay_input_test/main.dart';

void main() {
  // AutomatedTestWidgetsFlutterBinding().addTime(Duration(minutes: 10));
  testWidgets('The creating numerical widget Containers test ',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    for (int i = 0; i < 4; i++) {
      expect(
        find.byKey(ValueKey(i)),
        findsOneWidget,
      );
    }
  });
  testWidgets('The numerical widgets filling test',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    await tester.enterText(find.byType(TextField), '1');
    // verify that our TextField contains '1'

    await tester.pump();
    // verify that our TextField and Text contain '1'
    expect(find.text('1'), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), '11');
    // verify that our TextField contains '11'
    expect(find.text('11'), findsOneWidget);
    await tester.pump();
    // verify that two Text widgets contain '1'
    expect(find.text('1'), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), '111');
    // verify that our TextField contains '111'
    expect(find.text('111'), findsOneWidget);
    await tester.pump();
    // verify that tree Text widgets contain '1'
    expect(find.text('1'), findsNWidgets(3));

    await tester.enterText(find.byType(TextField), '1111');
    // verify that our TextField contains '1111'
    expect(find.text('1111'), findsOneWidget);
    await tester.pump(Duration(seconds: 5));
    // verify that four Text widgets contain '1'
    expect(find.text('1'), findsNWidgets(4));
  });
  testWidgets('The numerical widgets filling test (from a List)',
      (WidgetTester tester) async {
    // For this case, the max length of the List should be 4,
    // and !! all elements of the List should be distinct !!
    List<String> listTestChar = ['1', '2', '3', '4'];
    String str = '';
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    for (int i = 0; i < listTestChar.length - 1; i++) {
      str = str + listTestChar[i];

      await tester.enterText(find.byType(TextField), str);
      // verify that our TextField contains the row of first i + 1 listTestChar[] characters
      expect(find.text(str), findsOneWidget);
      await tester.pump();
      if (i == 0) {
        // verify that our TextField and Text contain listTestChar[0] character
        expect(find.text(listTestChar[i]), findsNWidgets(2));
      } else {
        // verify that only one Text widget contains listTestChar[i] character
        expect(find.text(listTestChar[i]), findsOneWidget);
      }
    }
  });
  testWidgets('The ElevatedButton widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
    expect(
      find.widgetWithText(ElevatedButton, 'Confirm code'),
      findsOneWidget,
    );
  });
}
