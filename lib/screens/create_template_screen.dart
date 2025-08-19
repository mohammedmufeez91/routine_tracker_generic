import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timeslot_provider.dart';
import '../providers/template_provider.dart';
import '../providers/goal_provider.dart';
import '../models/template.dart';
import '../models/goal.dart';

class CreateTemplateScreen extends StatefulWidget {
  const CreateTemplateScreen({super.key});

  @override
  State<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _daysController = TextEditingController();

  String _topic = '';
  int _target = 0;
  int? _slotId;
  int? _selectedGoalId;

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slots = context.watch<TimeSlotProvider>().slots;
    final templateProv = context.watch<TemplateProvider>();
    final goalProv = context.watch<GoalProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Template')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Topic field
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Topic (e.g., Pushups, Dhikr, Study)'),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                    onSaved: (v) => _topic = v!.trim(),
                  ),
                  const SizedBox(height: 8),

                  // Target count
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Target Count (e.g., 20, 30, 100)'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                    (v == null || int.tryParse(v) == null)
                        ? 'Enter a number'
                        : null,
                    onSaved: (v) => _target = int.parse(v!),
                  ),
                  const SizedBox(height: 8),

                  // Time Slot Dropdown
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                        labelText: 'Time Slot (from master)'),
                    value: _slotId,
                    items: slots
                        .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.name} • ${s.clock}')))
                        .toList(),
                    validator: (v) => v == null ? 'Pick a slot' : null,
                    onChanged: (v) => setState(() => _slotId = v),
                  ),
                  const SizedBox(height: 8),

                  // Goal Dropdown
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Link Goal'),
            value: _selectedGoalId,
            items: goalProv.goals
                .map((g) => DropdownMenuItem(
                value: g.id,
                child: Text('${g.name} (${g.totalDays} days)')))
                .toList(),
            validator: (v) => v == null ? 'Pick a goal' : null,
            onChanged: (v) {
              setState(() {
                _selectedGoalId = v;

                // Auto-fill days if a goal is selected
                final selectedGoal = goalProv.goals.firstWhere((g) => g.id == v, orElse: () => Goal(id: null, name: '', totalDays: 0, startDate: DateTime.now(), endDate: DateTime.now()));
                _daysController.text = selectedGoal.totalDays.toString();
              });
            },
          ),
                  const SizedBox(height: 8),

                  // No. of days TextField
                  TextFormField(
                    controller: _daysController,
                    decoration: const InputDecoration(
                      labelText: "No. of Days",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter number of days";
                      }
                      if (int.tryParse(value) == null) {
                        return "Enter a valid number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  FilledButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        final int days = int.parse(_daysController.text);

                        final id = await templateProv.addTemplate(Template(
                          topic: _topic,
                          targetCount: _target,
                          timeSlotId: _slotId!,
                          totalDays: days,
                          goalId: _selectedGoalId, // Link goal
                        ));

                        await templateProv.createRoutineFromTemplate(id);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Template created & routine started')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Create Routine'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // List of existing templates
            Expanded(
              child: ListView(
                children: templateProv.templates
                    .map((t) => Card(
                  child: ListTile(
                    title: Text('${t.topic} (${t.targetCount})'),
                    subtitle: Text(
                        'Days: ${t.totalDays} • Time slot id: ${t.timeSlotId} • Goal id: ${t.goalId ?? '-'}'),
                  ),
                ))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
