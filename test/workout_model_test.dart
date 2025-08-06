import 'package:flutter_test/flutter_test.dart';
import 'package:magic_ai/models/workout.dart';

void main() {
  test('WorkoutSet stores values correctly', () {
    final set = WorkoutSet(
      exercise: Exercise.Squat,
      weight: 60.0,
      repetitions: 10,
    );
    expect(set.exercise, Exercise.Squat);
    expect(set.weight, 60.0);
    expect(set.repetitions, 10);
  });

  test('Workout stores list of sets', () {
    final workout = Workout(
      date: DateTime(2024, 1, 1),
      sets: [
        WorkoutSet(exercise: Exercise.Deadlift, weight: 80, repetitions: 5),
      ],
      workoutId: '',
    );
    expect(workout.sets.length, 1);
    expect(workout.sets[0].exercise, Exercise.Deadlift);
  });
}
