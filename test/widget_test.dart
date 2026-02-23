import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';

void main() {
  testWidgets('Add, toggle, and delete a todo item', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // ✅ Verify empty state is shown
    expect(find.text('No tasks found'), findsOneWidget);

    // ✅ Tap the "Add Task" button (Extended FAB)
    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();

    // ✅ Enter a todo title
    await tester.enterText(find.byType(TextField).first, 'Test Todo');

    // ✅ Tap Add button in dialog
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // ✅ Verify that the new todo appears
    expect(find.text('Test Todo'), findsOneWidget);

    // ✅ Tap the todo to toggle completion
    await tester.tap(find.text('Test Todo'));
    await tester.pump();

    // ✅ Verify strikethrough is applied (task completed)
    final textFinder = find.text('Test Todo').first;
    final Text todoText = tester.widget(textFinder);
    expect(todoText.style?.decoration, TextDecoration.lineThrough);

    // ✅ Open popup menu (three dots)
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // ✅ Tap Delete option
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // ✅ Verify list is empty again
    expect(find.text('No tasks found'), findsOneWidget);
  });
}