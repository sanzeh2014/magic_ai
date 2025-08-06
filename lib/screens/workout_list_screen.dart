import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/workout.dart';
import 'workout_screen.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  late Box<Workout> workoutBox;

  @override
  void initState() {
    super.initState();
    workoutBox = Hive.box<Workout>('workouts');
  }

  void _createNewWorkout() {
    final newWorkout = Workout(
      workoutId: const Uuid().v4(),
      date: DateTime.now(),
      sets: [],
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(workout: newWorkout, isNew: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workouts'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ValueListenableBuilder<Box<Workout>>(
          valueListenable: workoutBox.listenable(),
          builder: (context, box, _) {
            if (box.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 64,
                      // ignore: deprecated_member_use
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Workouts Yet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add your first workout',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.only(top: 16, bottom: 80),
              itemCount: box.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final workout = box.getAt(index)!;
                return _WorkoutCard(
                  workout: workout,
                  onTap:
                      () => _navigateToWorkoutDetail(context, workout, index),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewWorkout,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToWorkoutDetail(
    BuildContext context,
    Workout workout,
    int index,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => WorkoutScreen(
              workout: workout,
              isNew: false,
              workoutIndex: index,
            ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;

  const _WorkoutCard({required this.workout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        side: BorderSide(color: theme.dividerColor.withOpacity(0.1), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(workout.date),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildExerciseSummary(context),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatItem(
                    icon: Icons.fitness_center,
                    value: '${workout.sets.length}',
                    label: 'Sets',
                  ),
                  _StatItem(
                    icon: Icons.timer,
                    value: _calculateWorkoutDuration(workout),
                    label: 'Duration',
                  ),
                  _StatItem(
                    icon: Icons.calendar_today,
                    value: _formatTime(workout.date),
                    label: 'Time',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseSummary(BuildContext context) {
    // Group sets by exercise type
    final exerciseCounts = <Exercise, int>{};
    for (final set in workout.sets) {
      exerciseCounts[set.exercise] = (exerciseCounts[set.exercise] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Exercises:', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children:
              exerciseCounts.entries.map((entry) {
                return Chip(
                  label: Text(
                    '${_formatExerciseName(entry.key)} (${entry.value})',
                  ),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
        ),
      ],
    );
  }

  String _formatExerciseName(Exercise exercise) {
    return exercise
        .toString()
        .split('.')
        .last
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}');
  }

  String _formatDate(DateTime date) {
    return '${_getWeekday(date)}, ${date.day} ${_getMonthName(date)} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  String _getWeekday(DateTime date) {
    return const [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ][date.weekday - 1];
  }

  String _getMonthName(DateTime date) {
    return const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][date.month - 1];
  }

  String _calculateWorkoutDuration(Workout workout) {
    // Implementation of  actual duration calculation as per track start/end times
    final estimatedMinutes =
        workout.sets.length * 2; // 2 minutes per set estimate
    return '$estimatedMinutes min';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.disabledColor,
          ),
        ),
      ],
    );
  }
}
