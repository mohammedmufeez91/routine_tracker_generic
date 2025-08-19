

class Goal {
  final int id;
  final String name;
  final int totalDays;
  final DateTime startDate;
  final DateTime endDate;
  final List<Template> templates;

  Goal({
    required this.id,
    required this.name,
    required this.totalDays,
    required this.startDate,
    required this.endDate,
    required this.templates,
  });

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      totalDays: map['total_days'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      templates: (map['templates'] as List)
          .map((template) => Template.fromMap(template))
          .toList(),
    );
  }
}

class Template {
  final int id;
  final String topic;
  final int targetCount;
  final int timeSlotId;
  final Goal goal;

  Template({
    required this.id,
    required this.topic,
    required this.targetCount,
    required this.timeSlotId,
    required this.goal,
  });

  factory Template.fromMap(Map<String, dynamic> map) {
    return Template(
      id: map['id'],
      topic: map['topic'],
      targetCount: map['target_count'],
      timeSlotId: map['timeslot_id'],
      goal: Goal.fromMap(map['goal']),
    );
  }
}