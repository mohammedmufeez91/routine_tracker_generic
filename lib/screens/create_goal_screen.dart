import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'goal_provider.dart';
import 'goal.dart';

class CreateGoalScreen extends StatefulWidget {
  @override
  _CreateGoalScreenState createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  String _goalName = '';
  int _totalDays = 0;

  @override
  Widget build(BuildContext context) {
    final goalProv = Provider.of<GoalProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Goal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Goal name
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Goal Name'),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                    onSaved: (v) => _goalName = v!.trim(),
                  ),
                  const SizedBox(height: 8),

                  // Total days
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Total Days'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                    (v == null || int.tryParse(v) == null)
                        ? 'Enter a number'
                        : null,
                    onSaved: (v) => _totalDays = int.parse(v!),
                  ),
                  const SizedBox(height: 8),

                  // Create Goal button
                  FilledButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final goal = Goal(
                          id: 0,
                          name: _goalName,
                          totalDays: _totalDays,
                          startDate: DateTime.now(),
                          endDate: DateTime.now().add(Duration(days: _totalDays)),
                          templates: [],
                        );
                        await goalProv.addGoal(goal);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goal created')));
                        }
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Create Goal'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}