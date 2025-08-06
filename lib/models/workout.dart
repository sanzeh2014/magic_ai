import 'package:hive/hive.dart';

part 'workout.g.dart';

@HiveType(typeId: 0)
enum Exercise {
  @HiveField(0)
  BarbellRow,
  @HiveField(1)
  BenchPress,
  @HiveField(2)
  ShoulderPress,
  @HiveField(3)
  Deadlift,
  @HiveField(4)
  Squat,
}

@HiveType(typeId: 1)
class WorkoutSet extends HiveObject {
  @HiveField(0)
  Exercise exercise;

  @HiveField(1)
  double weight;

  @HiveField(2)
  int repetitions;

  WorkoutSet({
    required this.exercise,
    required this.weight,
    required this.repetitions,
  });
}

@HiveType(typeId: 2)
class Workout extends HiveObject {
  @HiveField(0)
  String workoutId;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  List<WorkoutSet> sets;

  Workout({required this.workoutId, required this.date, required this.sets});

  static Workout from(Workout workout) {
    //copy of the workout
    return Workout(
      workoutId: workout.workoutId,
      date: workout.date,
      sets: List<WorkoutSet>.from(workout.sets),
    );
  }
}
