part of 'workout.dart';

class WorkoutSetAdapter extends TypeAdapter<WorkoutSet> {
  @override
  final int typeId = 1;

  @override
  WorkoutSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSet(
      exercise: fields[0] as Exercise,
      weight: fields[1] as double,
      repetitions: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSet obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.exercise)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.repetitions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 2;

  @override
  Workout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workout(
      workoutId: fields[0] as String,
      date: fields[1] as DateTime,
      sets: (fields[2] as List).cast<WorkoutSet>(),
    );
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.workoutId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.sets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 0;

  @override
  Exercise read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Exercise.BarbellRow;
      case 1:
        return Exercise.BenchPress;
      case 2:
        return Exercise.ShoulderPress;
      case 3:
        return Exercise.Deadlift;
      case 4:
        return Exercise.Squat;
      default:
        return Exercise.BarbellRow;
    }
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    switch (obj) {
      case Exercise.BarbellRow:
        writer.writeByte(0);
        break;
      case Exercise.BenchPress:
        writer.writeByte(1);
        break;
      case Exercise.ShoulderPress:
        writer.writeByte(2);
        break;
      case Exercise.Deadlift:
        writer.writeByte(3);
        break;
      case Exercise.Squat:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
