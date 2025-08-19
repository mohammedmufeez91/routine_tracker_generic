class Goal {
  final int? id;
  final String name;
  final int totalDays;
  final DateTime startDate;
  final DateTime endDate;

  Goal({
    this.id,
    required this.name,
    required this.totalDays,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'total_days': totalDays,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
  };

  factory Goal.fromMap(Map<String, dynamic> m) => Goal(
    id: m['id'] as int?,
    name: m['name'] as String,
    totalDays: m['total_days'] as int,
    startDate: DateTime.parse(m['start_date']),
    endDate: DateTime.parse(m['end_date']),
  );
}
