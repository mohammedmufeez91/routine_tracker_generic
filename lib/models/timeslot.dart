class TimeSlot {
  final int? id;
  final String name; // e.g., Morning before Fajr
  final String? note; // optional description
  final String clock; // HH:mm or localized string

  TimeSlot({this.id, required this.name, this.note, required this.clock});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'note': note,
        'clock': clock,
      };

  factory TimeSlot.fromMap(Map<String, dynamic> m) => TimeSlot(
        id: m['id'] as int?,
        name: m['name'] as String,
        note: m['note'] as String?,
        clock: m['clock'] as String,
      );
}
