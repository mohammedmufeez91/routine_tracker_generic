import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  double _calculateProgress(Goal goal) {
    final totalDays = goal.totalDays;
    final elapsedDays = DateTime.now().difference(goal.startDate).inDays + 1;
    if (elapsedDays <= 0) return 0.0;
    if (elapsedDays >= totalDays) return 1.0;
    return elapsedDays / totalDays;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final goalProv = context.watch<GoalProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Goal Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: goalProv.goals.map((g) {
            final progress = _calculateProgress(g);
            return Card(
              child: ListTile(
                title: Text('${g.name} (${(progress * 100).toStringAsFixed(1)}% completed)'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From: ${_formatDate(g.startDate)} To: ${_formatDate(g.endDate)}'),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(value: progress),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}