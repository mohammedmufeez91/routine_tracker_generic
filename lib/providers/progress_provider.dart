import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/progress.dart';
import '../services/db.dart';

class ProgressProvider extends ChangeNotifier {
  final Map<String, Map<int, ProgressEntry>> _cache = {}; // date->templateId->entry
  String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<ProgressEntry> getOrCreate(String date, int templateId, int target) async {
    _cache.putIfAbsent(date, () => {});
    if (_cache[date]!.containsKey(templateId)) return _cache[date]![templateId]!;

    final db = await DB.instance.database;
    final rows = await db.query('progress',
        where: 'date = ? AND template_id = ?', whereArgs: [date, templateId], limit: 1);
    ProgressEntry entry;
    if (rows.isEmpty) {
      entry = ProgressEntry(date: date, templateId: templateId, completedCount: 0, isCompleted: false);
      final id = await db.insert('progress', entry.toMap());
      entry = ProgressEntry(id: id, date: date, templateId: templateId, completedCount: 0, isCompleted: false);
    } else {
      entry = ProgressEntry.fromMap(rows.first);
    }
    _cache[date]![templateId] = entry;
    return entry;
  }

  ProgressEntry getProgress(String date, int templateId, {int target = 0}) {
    if (_cache.containsKey(date) && _cache[date]!.containsKey(templateId)) {
      return _cache[date]![templateId]!;
    } else {
      return ProgressEntry(
        templateId: templateId,
        date: date,
        completedCount: 0,
        isCompleted: false,
      );
    }
  }

  Future<ProgressEntry> incrementToday(int templateId, int target) async {
    final date = _today();
    final db = await DB.instance.database;
    final entry = await getOrCreate(date, templateId, target);
    final newCount = entry.completedCount + 1;
    final completed = target > 0 && newCount >= target;
    await db.update('progress', {
      'completed_count': newCount,
      'is_completed': completed ? 1 : 0,
    }, where: 'id = ?', whereArgs: [entry.id]);
    final updated = ProgressEntry(
      id: entry.id,
      date: date,
      templateId: templateId,
      completedCount: newCount,
      isCompleted: completed,
    );
    _cache[date]![templateId] = updated;
    notifyListeners();
    return updated;
  }

  Future<List<DateTime>> getCompletedDates(int templateId) async {
    final db = await DB.instance.database;
    final rows = await db.query('progress',
        where: 'template_id = ? AND is_completed = 1', whereArgs: [templateId]);
    return rows
        .map((e) => DateTime.parse((e['date'] as String) + 'T00:00:00.000'))
        .toList();
  }
}
