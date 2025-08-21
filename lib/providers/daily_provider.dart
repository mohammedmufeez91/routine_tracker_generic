import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../models/progress.dart';
import 'goal_provider.dart';
import 'template_provider.dart';
import 'progress_provider.dart';

class DailyProvider extends ChangeNotifier {
  final GoalProvider goalProvider;
  final TemplateProvider templateProvider;
  final ProgressProvider progressProvider;

  DailyProvider(this.goalProvider, this.templateProvider, this.progressProvider);

  Future<Map<Goal, List<Map<String, dynamic>>>> getDailyProgress(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final goals = goalProvider.goals; // ✅ fixed
    final templates = templateProvider.templates; // ✅ fixed

    final Map<Goal, List<Map<String, dynamic>>> result = {};

    for (var goal in goals) {
      final goalTemplates =
      templates.where((t) => t.goalId == goal.id).toList();

      final progressList = <Map<String, dynamic>>[];

      for (var t in goalTemplates) {
        final entry = await progressProvider.getOrCreate(
          dateStr,
          t.id!,
          target: t.targetCount, // ✅ fixed
        );

        progressList.add({
          "template": t,
          "progress": entry,
        });
      }

      result[goal] = progressList;
    }

    return result;
  }
}
