import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/db.dart';

class GoalProvider extends ChangeNotifier {
  final List<Goal> _goals = [];
  List<Goal> get goals => List.unmodifiable(_goals);

  Future<void> init() async {
    await fetchAll();
  }

  Future<void> fetchAll() async {
    final db = await DB.instance.database;
    final rows = await db.query('goals', orderBy: 'id DESC');
    _goals
      ..clear()
      ..addAll(rows.map((e) => Goal.fromMap(e)));
    notifyListeners();
  }

  Future<int> addGoal(Goal g) async {
    final db = await DB.instance.database;
    final id = await db.insert('goals', g.toMap());
    await fetchAll();
    return id;
  }

  Future<void> updateGoal(Goal g) async {
    if (g.id == null) return;
    final db = await DB.instance.database;
    await db.update('goals', g.toMap(), where: 'id = ?', whereArgs: [g.id]);
    await fetchAll();
  }

  Future<void> deleteGoal(int id) async {
    final db = await DB.instance.database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
    await fetchAll();
  }
}
