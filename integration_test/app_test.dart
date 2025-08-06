import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:magic_ai/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add workout, edit, delete', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Add Workout
    await tester.tap(find.text('Add Workout'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Set'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(Key('weightField')), '50');
    await tester.enterText(find.byKey(Key('repsField')), '10');

    await tester.tap(find.text('Save Workout'));
    await tester.pumpAndSettle();

    // Verify added
    expect(find.textContaining('50kg'), findsOneWidget);

    // Delete
    await tester.longPress(find.textContaining('50kg'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Verify removed
    expect(find.textContaining('50kg'), findsNothing);
  });
}
