class Routine {
  final int? id;
  final int templateId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;

  Routine({
    this.id,
    required this.templateId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'template_id': templateId,
        'start_date': startDate.toIso8601String().substring(0,10),
        'end_date': endDate.toIso8601String().substring(0,10),
        'total_days': totalDays,
      };

  factory Routine.fromMap(Map<String, dynamic> m) => Routine(
        id: m['id'] as int?,
        templateId: m['template_id'] as int,
        startDate: DateTime.parse((m['start_date'] as String) + 'T00:00:00.000'),
        endDate: DateTime.parse((m['end_date'] as String) + 'T00:00:00.000'),
        totalDays: m['total_days'] as int,
      );
}
