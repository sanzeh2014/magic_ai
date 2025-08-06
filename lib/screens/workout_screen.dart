import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:magic_ai/widgets/editable_set_card.dart';
import 'package:magic_ai/widgets/view_set_card.dart';
import '../../models/workout.dart';

class WorkoutScreen extends StatefulWidget {
  final Workout workout;
  final bool isNew;
  final int? workoutIndex;

  const WorkoutScreen({
    super.key,
    required this.workout,
    required this.isNew,
    this.workoutIndex,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late Workout workout;
  late Box<Workout> workoutBox;
  final _formKey = GlobalKey<FormState>();
  Set<int> _editingSetIndices = {};

  @override
  void initState() {
    super.initState();
    workout = Workout.from(widget.workout);
    workoutBox = Hive.box<Workout>('workouts');
    if (widget.isNew) {
      _editingSetIndices = Set.from(workout.sets.asMap().keys);
    }
  }

  void _toggleEditModeForSet(int index) {
    setState(() {
      if (_editingSetIndices.contains(index)) {
        _editingSetIndices.remove(index);
      } else {
        _editingSetIndices.add(index);
      }
    });
  }

  void _addSet() {
    setState(() {
      workout.sets.add(
        WorkoutSet(exercise: Exercise.BenchPress, weight: 20, repetitions: 8),
      );
      _editingSetIndices.add(workout.sets.length - 1);
    });
  }

  void _removeSet(int index) {
    setState(() {
      workout.sets.removeAt(index);
      _editingSetIndices =
          _editingSetIndices
              .where((i) => i != index)
              .map((i) => i > index ? i - 1 : i)
              .toSet();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Set removed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _updateSet(int index, WorkoutSet updatedSet) {
    setState(() {
      workout.sets[index] = updatedSet;
    });
  }

  void _saveWorkout() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _editingSetIndices.clear());

      if (widget.isNew) {
        workoutBox.add(workout);
      } else {
        workoutBox.putAt(widget.workoutIndex!, workout);
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New Workout' : 'Workout Details'),
        actions: [
          TextButton.icon(
            onPressed: _saveWorkout,
            icon: const Icon(Icons.save),
            label: const Text(
              "Save",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child:
                  workout.sets.isEmpty
                      ? _buildEmptyState(theme, colorScheme)
                      : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        itemCount: workout.sets.length,
                        itemBuilder: (context, index) {
                          final set = workout.sets[index];
                          return _editingSetIndices.contains(index)
                              ? EditableSetCard(
                                key: ValueKey('editable_${set.hashCode}'),
                                set: set,
                                index: index,
                                onToggleEdit: _toggleEditModeForSet,
                                onRemove: _removeSet,
                                onUpdate:
                                    (updatedSet) =>
                                        _updateSet(index, updatedSet),
                              )
                              : ViewSetCard(
                                key: ValueKey('view_${set.hashCode}'),
                                set: set,
                                index: index,
                                onToggleEdit: _toggleEditModeForSet,
                                onRemove: _removeSet,
                              );
                        },
                      ),
            ),
            _buildAddSetButton(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 48,
            color: colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No sets added yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first set',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAddSetButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FilledButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add Set'),
        onPressed: _addSet,
      ),
    );
  }
}
