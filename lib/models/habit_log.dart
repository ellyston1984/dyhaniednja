class HabitLog {
  final String id;
  final String habitId;
  final DateTime date;
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'habitId': habitId,
        'date': date.toIso8601String(),
        'completedCount': completedCount,
        'note': note,
        'moodScore': moodScore,
      };

  factory HabitLog.fromJson(Map<String, dynamic> json) {
    return HabitLog(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      date: DateTime.parse(json['date'] as String),
      completedCount: json['completedCount'] as int? ?? 1,
      note: json['note'] as String?,
      moodScore: json['moodScore'] as int?,
    );
  }
}