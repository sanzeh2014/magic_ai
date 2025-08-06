import 'package:flutter/material.dart';
import '../../../models/workout.dart';

class EditableSetCard extends StatefulWidget {
  final WorkoutSet set;
  final int index;
  final Function(int) onToggleEdit;
  final Function(int) onRemove;
  final Function(WorkoutSet) onUpdate;

  const EditableSetCard({
    super.key,
    required this.set,
    required this.index,
    required this.onToggleEdit,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  State<EditableSetCard> createState() => _EditableSetCardState();
}

class _EditableSetCardState extends State<EditableSetCard> {
  late WorkoutSet _currentSet;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentSet = widget.set;
    _weightController.text = _currentSet.weight.toString();
    _repsController.text = _currentSet.repetitions.toString();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  String _formatExerciseName(Exercise exercise) {
    return exercise
        .toString()
        .split('.')
        .last
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}');
  }

  void _updateWeight(double newWeight) {
    setState(() {
      _currentSet.weight = newWeight;
      _weightController.text = newWeight.toString();
      widget.onUpdate(_currentSet);
    });
  }

  void _updateReps(int newReps) {
    setState(() {
      _currentSet.repetitions = newReps;
      _repsController.text = newReps.toString();
      widget.onUpdate(_currentSet);
    });
  }

  Widget _buildNumberInput({
    required String label,
    required String suffix,
    required TextEditingController controller,
    required void Function(double) onChanged,
    required String? Function(String?) validator,
    bool isInt = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                final currentValue = double.tryParse(controller.text) ?? 0;
                final newValue = currentValue - (isInt ? 1 : 5);
                if (newValue >= 0) {
                  onChanged(newValue);
                }
              },
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: controller,
                // decoration: InputDecoration(
                //   border: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   suffixText: suffix,
                //   contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                // ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                validator: validator,
                onChanged: (value) {
                  final parsedValue =
                      isInt
                          ? int.tryParse(value)?.toDouble()
                          : double.tryParse(value);
                  if (parsedValue != null && parsedValue >= 0) {
                    onChanged(parsedValue);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final currentValue = double.tryParse(controller.text) ?? 0;
                onChanged(currentValue + (isInt ? 1 : 5));
              },
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Set ${widget.index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: colorScheme.primary),
                      onPressed: () => widget.onToggleEdit(widget.index),
                      splashRadius: 20,
                      tooltip: 'Save changes',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                      onPressed: () => widget.onRemove(widget.index),
                      splashRadius: 20,
                      tooltip: 'Remove set',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Exercise>(
              value: _currentSet.exercise,
              decoration: InputDecoration(
                labelText: 'Exercise',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              isExpanded: true,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _currentSet.exercise = val;
                    widget.onUpdate(_currentSet);
                  });
                }
              },
              items:
                  Exercise.values.map((ex) {
                    return DropdownMenuItem(
                      value: ex,
                      child: Text(
                        _formatExerciseName(ex),
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNumberInput(
                    label: 'Weight (kg)',
                    suffix: _weightController.text,
                    controller: _weightController,
                    onChanged: _updateWeight,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final weight = double.tryParse(value);
                      if (weight == null || weight <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberInput(
                    label: 'Repetitions',
                    suffix: _repsController.text,
                    controller: _repsController,
                    onChanged: (value) => _updateReps(value.toInt()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final reps = int.tryParse(value);
                      if (reps == null || reps <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                    isInt: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
