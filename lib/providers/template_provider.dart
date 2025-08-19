import 'package:flutter/material.dart';
import '../models/template.dart';
import '../models/routine.dart';
import '../services/db.dart';

class TemplateProvider extends ChangeNotifier {
  final List<Template> _templates = [];
  List<Template> get templates => List.unmodifiable(_templates);

  Future<void> init() async {
    await fetchAll();
  }

  Future<void> fetchAll() async {
    final db = await DB.instance.database;
    final rows = await db.query('templates', orderBy: 'id DESC');
    _templates
      ..clear()
      ..addAll(rows.map((e) => Template.fromMap(e)));
    notifyListeners();
  }

  Future<int> addTemplate(Template t) async {
    final db = await DB.instance.database;
    final id = await db.insert('templates', t.toMap());
    await fetchAll();
    return id;
  }

  Future<void> createRoutineFromTemplate(int templateId, {DateTime? start, int? days}) async {
    final db = await DB.instance.database;
    final tRow = (await db.query('templates', where: 'id = ?', whereArgs: [templateId], limit: 1)).first;
    final t = Template.fromMap(tRow);
    final total = days ?? t.totalDays;
    final s = (start ?? DateTime.now());
    final startDate = DateTime(s.year, s.month, s.day);
    final endDate = startDate.add(Duration(days: total - 1));
    final r = Routine(templateId: templateId, startDate: startDate, endDate: endDate, totalDays: total);
    await db.insert('routines', r.toMap());
  }
}
