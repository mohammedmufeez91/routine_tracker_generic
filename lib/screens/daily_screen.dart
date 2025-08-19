import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/progress.dart';
import '../providers/template_provider.dart';
import '../providers/timeslot_provider.dart';
import '../providers/progress_provider.dart';

class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = context.watch<TemplateProvider>().templates;
    final slots = context.watch<TimeSlotProvider>().slots;
    final progressProv = context.watch<ProgressProvider>();
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());


    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: ListView.builder(
        itemCount: templates.length,
        itemBuilder: (context, i) {
          final t = templates[i];
          final slot = slots.firstWhere(
                  (s) => s.id == t.timeSlotId,
              orElse: () => slots.first);

          // Get progress from cache if exists, else create default
      /*    final entry = progressProv._cache[dateStr]?[t.id] ??
              ProgressEntry(
                  templateId: t.id!,
                  date: dateStr,
                  completedCount: 0,
                  isCompleted: false);*/
          final entry = progressProv.getProgress(dateStr, t.id!, target: t.targetCount);
          final count = entry.completedCount;
          final done = entry.isCompleted;

          return Card(
            child: ListTile(
              title: Text(t.topic,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${slot.name} • ${slot.clock} • $count / ${t.targetCount}'),
              trailing: Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? Colors.green : null,
              ),
              onTap: () async {
                await progressProv.incrementToday(t.id!, t.targetCount);
              },
            ),
          );
        },
      ),
    );
  }
}
