import 'package:flutter/material.dart';
import '../models/timeslot.dart';
import '../services/db.dart';

class TimeSlotProvider extends ChangeNotifier {
  final List<TimeSlot> _slots = [];
  List<TimeSlot> get slots => List.unmodifiable(_slots);

  Future<void> init() async {
    await fetchAll();
    if (_slots.isEmpty) {
      // Seed defaults
      await add(TimeSlot(name: 'Morning', note: 'Before work', clock: '07:00'));
      await add(TimeSlot(name: 'Afternoon', note: 'After lunch', clock: '14:00'));
      await add(TimeSlot(name: 'Evening', note: 'Gym time', clock: '19:00'));
      await add(TimeSlot(name: 'Night', note: 'Before sleep', clock: '22:00'));
    }
  }

  Future<void> fetchAll() async {
    final db = await DB.instance.database;
    final rows = await db.query('timeslots', orderBy: 'clock ASC');
    _slots
      ..clear()
      ..addAll(rows.map((e) => TimeSlot.fromMap(e)));
    notifyListeners();
  }

  Future<void> add(TimeSlot slot) async {
    final db = await DB.instance.database;
    await db.insert('timeslots', slot.toMap());
    await fetchAll();
  }

  Future<void> remove(int id) async {
    final db = await DB.instance.database;
    await db.delete('timeslots', where: 'id = ?', whereArgs: [id]);
    await fetchAll();
  }
}
