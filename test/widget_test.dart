import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/screens/home_screen.dart';

void main() {
  testWidgets('Add and toggle a todo item', (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(MyApp(isDarkMode: false)); // ✅ pass isDarkMode

    // Verify that the HomeScreen shows "No tasks yet"
    expect(find.text('No tasks yet.\nTap + to add one!'), findsOneWidget);

    // Tap the floating action button to add a todo
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Enter a todo title
    await tester.enterText(find.byType(TextField), 'Test Todo');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify that the new todo appears in the list
    expect(find.text('Test Todo'), findsOneWidget);

    // Tap the todo to toggle completion
    await tester.tap(find.text('Test Todo'));
    await tester.pump();

    // Verify that the text now has strikethrough (isDone toggled)
    Text todoText =
        tester.widget<Text>(find.text('Test Todo').first);
    expect(todoText.style!.decoration, TextDecoration.lineThrough);

    // Delete the todo
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    // Verify that the list is empty again
    expect(find.text('No tasks yet.\nTap + to add one!'), findsOneWidget);
  });
}