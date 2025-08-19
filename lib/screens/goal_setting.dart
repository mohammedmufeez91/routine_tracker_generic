import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _totalDaysController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _showEndPicker = false;
  int? _editingGoalId;

  @override
  void dispose() {
    _nameController.dispose();
    _totalDaysController.dispose();
    super.dispose();
  }

  // Pick start date
  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (date != null) {
      setState(() {
        _startDate = date;

        // Auto-calculate end date if totalDays exists
        final days = int.tryParse(_totalDaysController.text);
        if (days != null) {
          _endDate = _startDate!.add(Duration(days: days - 1));
          _showEndPicker = false;
        } else {
          _endDate = null;
          _showEndPicker = true;
        }
      });
    }
  }

  // Pick end date manually
  Future<void> _pickEndDate() async {
    if (_startDate == null) return;
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime(_startDate!.year + 5),
    );
    if (date != null) {
      setState(() {
        _endDate = date;

        // Update totalDays automatically
        if (_startDate != null) {
          final diff = _endDate!.difference(_startDate!).inDays + 1;
          _totalDaysController.text = diff.toString();
        }
      });
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
      final name = _nameController.text.trim();
      final days = int.tryParse(_totalDaysController.text) ??
          _endDate!.difference(_startDate!).inDays + 1;

      final goal = Goal(
        id: _editingGoalId,
        name: name,
        totalDays: days,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      final goalProv = context.read<GoalProvider>();
      if (_editingGoalId == null) {
        goalProv.addGoal(goal);
      } else {
        goalProv.updateGoal(goal);
      }

      _clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form')),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _totalDaysController.clear();
    _startDate = null;
    _endDate = null;
    _editingGoalId = null;
    _showEndPicker = false;
    setState(() {});
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2,'0')}-${date.month.toString().padLeft(2,'0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final goalProv = context.watch<GoalProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Goal Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Goal Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Goal Name'),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),

                  // Total Days (optional)
                  TextFormField(
                    controller: _totalDaysController,
                    decoration: const InputDecoration(labelText: 'Total Days (optional)'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      if (_startDate != null) {
                        final days = int.tryParse(val);
                        setState(() {
                          if (days != null) {
                            _endDate = _startDate!.add(Duration(days: days - 1));
                            _showEndPicker = false;
                          } else {
                            // Reset end date if input is cleared
                            _endDate = null;
                            _showEndPicker = val.isEmpty && _startDate != null;
                          }
                        });
                      }
                    },
                  ),


                  const SizedBox(height: 8),

                  // Start Date
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Start Date: ${_formatDate(_startDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _pickStartDate,
                        child: const Text('Pick Start'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // End Date
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'End Date: ${_formatDate(_endDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      if (_showEndPicker)
                        ElevatedButton(
                          onPressed: _pickEndDate,
                          child: const Text('Pick End'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: _saveGoal,
                    icon: const Icon(Icons.save),
                    label:
                    Text(_editingGoalId == null ? 'Add Goal' : 'Update Goal'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Goal List
            Expanded(
              child: ListView(
                children: goalProv.goals
                    .map(
                      (g) => Card(
                    child: ListTile(
                      title: Text('${g.name} (${g.totalDays} days)'),
                      subtitle: Text(
                          'From: ${_formatDate(g.startDate)} To: ${_formatDate(g.endDate)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editingGoalId = g.id;
                              _nameController.text = g.name;
                              _totalDaysController.text =
                                  g.totalDays.toString();
                              _startDate = g.startDate;
                              _endDate = g.endDate;
                              _showEndPicker = false;
                              setState(() {});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              goalProv.deleteGoal(g.id!);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
