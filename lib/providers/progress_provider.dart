import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/progress.dart';
import '../services/db.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/progress.dart';
import '../services/db.dart';

class ProgressProvider extends ChangeNotifier {
  final Map<String, Map<int, ProgressEntry>> _cache = {}; // date -> templateId -> entry

  String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<ProgressEntry> getOrCreate(String date, int templateId, {int target = 1}) async {
    _cache.putIfAbsent(date, () => {});
    if (_cache[date]!.containsKey(templateId)) return _cache[date]![templateId]!;

    final db = await DB.instance.database;
    final rows = await db.query(
      'progress',
      where: 'date = ? AND template_id = ?',
      whereArgs: [date, templateId],
      limit: 1,
    );

    ProgressEntry entry;
    if (rows.isEmpty) {
      final newEntry = ProgressEntry(
        id: null,
        date: date,
        templateId: templateId,
        completedCount: 0,
        isCompleted: false,
      );
      final id = await db.insert('progress', newEntry.toMap());
      entry = ProgressEntry(
        id: id,
        date: date,
        templateId: templateId,
        completedCount: 0,
        isCompleted: false,
      );
    } else {
      entry = ProgressEntry.fromMap(rows.first);
    }

    _cache[date]![templateId] = entry;
    return entry;
  }

  ProgressEntry getProgress(String date, int templateId, {int target = 1}) {
    return _cache[date]?[templateId] ??
        ProgressEntry(
          id: null,
          date: date,
          templateId: templateId,
          completedCount: 0,
          isCompleted: false,
        );
  }

  /// Increment progress by 1
  Future<ProgressEntry> incrementToday(int templateId, int target) async {
    final date = _today();
    final oldEntry = await getOrCreate(date, templateId, target: target);

    final newCount = (oldEntry.completedCount + 1).clamp(0, target);
    final entry = ProgressEntry(
      id: oldEntry.id,
      date: date,
      templateId: templateId,
      completedCount: newCount,
      isCompleted: newCount >= target,
    );

    _cache[date]![templateId] = entry;
    await _insertOrUpdateDB(entry);

    notifyListeners();
    return entry;
  }

  /// Complete task immediately (long press)
  Future<ProgressEntry> completeToday(int templateId, int target) async {
    final date = _today();
    final oldEntry = await getOrCreate(date, templateId, target: target);

    final entry = ProgressEntry(
      id: oldEntry.id,
      date: date,
      templateId: templateId,
      completedCount: target,
      isCompleted: true,
    );

    _cache[date]![templateId] = entry;
    await _insertOrUpdateDB(entry);

    notifyListeners();
    return entry;
  }

  Future<void> _insertOrUpdateDB(ProgressEntry entry) async {
    final db = await DB.instance.database;
    if (entry.id == null) {
      await db.insert('progress', entry.toMap());
    } else {
      await db.update(
        'progress',
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    }
  }

  Future<List<DateTime>> getCompletedDates(int templateId) async {
    final db = await DB.instance.database;
    final rows = await db.query(
      'progress',
      where: 'template_id = ? AND is_completed = 1',
      whereArgs: [templateId],
    );
    return rows
        .map((e) => DateTime.parse((e['date'] as String) + 'T00:00:00.000'))
        .toList();
  }
}
