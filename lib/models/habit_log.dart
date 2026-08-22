class HabitLog {
  final String id;
  final String habitId;
  final DateTime date; // только день, без времени
  final int completedCount;
  final String? note;
  final int? moodScore;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    this.completedCount = 1,
    this.note,
    this.moodScore,
  });

  DateTime get dayOnly =>
      DateTime(date.year, date.month, date.day);

  Map<String, dynamic> toJson() => {
        'id': id,
        'habitId': habitId,
        'date': dayOnly.toIso8601String(),
        'completedCount': completedCount,
        'note': note,
        'moodScore': moodScore,
      };

  factory HabitLog.fromJson(Map<String, dynamic> json) {
    final d = DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now();
    return HabitLog(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      date: DateTime(d.year, d.month, d.day),
      completedCount: json['completedCount'] as int? ?? 1,
      note: json['note'] as String?,
      moodScore: json['moodScore'] as int?,
    );
  }
}