import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:magic_ai/screens/workout_screen.dart';
import 'package:magic_ai/models/workout.dart';

void main() {
  setUpAll(() async {
    await Hive.initFlutter();

    await Hive.openBox('workouts');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('Add workout set form works', (tester) async {
    final workout = Workout(date: DateTime.now(), sets: [], workoutId: '');

    await tester.pumpWidget(
      MaterialApp(home: WorkoutScreen(workout: workout, isNew: true)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add Set'), findsOneWidget);

    await tester.tap(find.text('Add Set'));
    await tester.pump();

    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
