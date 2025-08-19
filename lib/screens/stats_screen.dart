import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/template_provider.dart';
import '../providers/progress_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = context.watch<TemplateProvider>().templates;
    return Scaffold(
      appBar: AppBar(title: const Text('Stats & Streaks')),
      body: ListView.builder(
        itemCount: templates.length,
        itemBuilder: (context, i) {
          final t = templates[i];
          return FutureBuilder<List<DateTime>>(
            future: context.read<ProgressProvider>().getCompletedDates(t.id!),
            builder: (context, snap) {
              final dates = snap.data ?? [];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${t.topic} (${t.targetCount})', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TableCalendar(
                        firstDay: DateTime.utc(2024, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: DateTime.now(),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            final done = dates.any((d) => d.year == day.year && d.month == day.month && d.day == day.day);
                            return Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: done ? Colors.green.withOpacity(0.25) : null,
                                border: Border.all(color: done ? Colors.green : Colors.black12),
                              ),
                              alignment: Alignment.center,
                              child: Text('${day.day}'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
