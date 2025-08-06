import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_ai/models/workout.dart';

class WorkoutSummaryWidget extends StatelessWidget {
  final Workout workout;
  const WorkoutSummaryWidget({required this.workout, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Workout ID: ${workout.workoutId}'),
        Text('Date: ${workout.date.toLocal().toIso8601String()}'),
        Text('Sets count: ${workout.sets.length}'),
      ],
    );
  }
}

void main() {
  testWidgets('WorkoutSummaryWidget shows correct info', (
    WidgetTester tester,
  ) async {
    final workout = Workout(
      workoutId: 'widgetTest1',
      date: DateTime(2025, 8, 6),
      sets: [
        WorkoutSet(exercise: Exercise.BenchPress, weight: 70, repetitions: 8),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: WorkoutSummaryWidget(workout: workout))),
    );

    expect(find.text('Workout ID: widgetTest1'), findsOneWidget);
    expect(find.text('Date: 2025-08-06T00:00:00.000'), findsOneWidget);
    expect(find.text('Sets count: 1'), findsOneWidget);
  });
}
