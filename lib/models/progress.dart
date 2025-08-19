class ProgressEntry {
  final int? id;
  final String date; // yyyy-MM-dd
  final int templateId;
  final int completedCount;
  final bool isCompleted;

  ProgressEntry({
    this.id,
    required this.date,
    required this.templateId,
    required this.completedCount,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'template_id': templateId,
        'completed_count': completedCount,
        'is_completed': isCompleted ? 1 : 0,
      };

  factory ProgressEntry.fromMap(Map<String, dynamic> m) => ProgressEntry(
        id: m['id'] as int?,
        date: m['date'] as String,
        templateId: m['template_id'] as int,
        completedCount: m['completed_count'] as int,
        isCompleted: (m['is_completed'] as int) == 1,
      );
}
