class Template {
  final int? id;
  final String topic;
  final int targetCount;
  final int timeSlotId;
  final int totalDays; // 10/30/40 etc
  final int? goalId;   // NEW: linked goal

  Template({
    this.id,
    required this.topic,
    required this.targetCount,
    required this.timeSlotId,
    required this.totalDays,
    this.goalId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'topic': topic,
    'target_count': targetCount,
    'timeslot_id': timeSlotId,
    'total_days': totalDays,
    'goal_id': goalId,   // store linked goal
  };

  factory Template.fromMap(Map<String, dynamic> m) => Template(
    id: m['id'] as int?,
    topic: m['topic'] as String,
    targetCount: m['target_count'] as int,
    timeSlotId: m['timeslot_id'] as int,
    totalDays: m['total_days'] as int,
    goalId: m['goal_id'] as int?,  // read linked goal
  );
}
