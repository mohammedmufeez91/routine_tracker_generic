import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timeslot_provider.dart';
import '../models/timeslot.dart';

class ManageTimeSlotsScreen extends StatefulWidget {
  const ManageTimeSlotsScreen({super.key});

  @override
  State<ManageTimeSlotsScreen> createState() => _ManageTimeSlotsScreenState();
}

class _ManageTimeSlotsScreenState extends State<ManageTimeSlotsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  TimeOfDay _clock = const TimeOfDay(hour: 7, minute: 0);

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TimeSlotProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Master Time Slots')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        labelText: 'Name (e.g., Morning before Fajr)'),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteController,
                    decoration:
                    const InputDecoration(labelText: 'Note (optional)'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child: Text('Clock: ${_clock.format(context)}')),
                      OutlinedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                              context: context, initialTime: _clock);
                          if (picked != null) {
                            setState(() => _clock = picked);
                          }
                        },
                        child: const Text('Pick Time'),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final slot = TimeSlot(
                          name: _nameController.text.trim(),
                          note: _noteController.text.trim().isEmpty
                              ? null
                              : _noteController.text.trim(),
                          clock: _clock.format(context),
                        );
                        await prov.add(slot);

                        if (mounted) {
                          // Reset fields
                          _nameController.clear();
                          _noteController.clear();
                          setState(() {
                            _clock = const TimeOfDay(hour: 7, minute: 0);
                          });

                          // Hide keyboard
                          FocusScope.of(context).unfocus();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Time slot added')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Time Slot'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: prov.slots.length,
                itemBuilder: (context, i) {
                  final s = prov.slots[i];
                  return Card(
                    child: ListTile(
                      title: Text(s.name),
                      subtitle: Text('${s.note ?? ''} • ${s.clock}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => prov.remove(s.id!),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
