import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/progress.dart';
import '../models/goal.dart';
import '../providers/daily_provider.dart';
import '../providers/progress_provider.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  late Future<Map<Goal, List<Map<String, dynamic>>>> _dailyFuture;

  @override
  void initState() {
    super.initState();
    _loadDailyProgress();
  }

  void _loadDailyProgress() {
    final dailyProvider = Provider.of<DailyProvider>(context, listen: false);
    _dailyFuture = dailyProvider.getDailyProgress(DateTime.now());
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  int daysRemaining(DateTime endDate) {
    final today = DateTime.now();
    return endDate.isBefore(today)
        ? 0
        : endDate.difference(today).inDays + 1;
  }

  void _refresh() {
    setState(() {
      _loadDailyProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Progress"),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: FutureBuilder<Map<Goal, List<Map<String, dynamic>>>>(
        future: _dailyFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final goalMap = snapshot.data!;
          if (goalMap.isEmpty) {
            return const Center(child: Text("No progress available for today."));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: goalMap.entries.map((entry) {
              final goal = entry.key;
              final progressList = entry.value;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    goal.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📅 ${formatDate(goal.startDate)} → ${formatDate(goal.endDate)}",
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      Text(
                        "⏳ ${daysRemaining(goal.endDate)} days remaining",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  children: progressList.isEmpty
                      ? [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        "No entries yet for today",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    )
                  ]
                      : progressList.map((p) {
                    final template = p["template"];
                    final templateId = template.id;

                    return Consumer<ProgressProvider>(
                      builder: (context, prov, _) {
                        final progress = prov.getProgress(
                          DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          templateId,
                          target: template.targetCount,
                        );

                        final progressPercent =
                        (progress.completedCount / template.targetCount)
                            .clamp(0.0, 1.0);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            child: Icon(
                              Icons.check_circle,
                              color: progress.isCompleted ? Colors.teal : Colors.grey,
                            ),
                          ),
                          title: Text(template.topic, style: const TextStyle(fontSize: 15)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${progress.completedCount} / ${template.targetCount}",
                                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: progressPercent,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            progress.isCompleted ? Icons.verified : Icons.pending_actions,
                            color: progress.isCompleted ? Colors.green : Colors.red,
                          ),
                          onTap: () async {
                            await prov.incrementToday(progress.templateId, template.targetCount);
                          },
                          onLongPress: () async {
                            await prov.completeToday(progress.templateId, template.targetCount);
                          },
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
