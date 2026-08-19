class CycleLog {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int? cycleLength;
  final int? periodLength;
  final String? note;
  final List<String> symptoms;
  final bool syncedWithHealth;
  final bool userModified;
  final String? healthUuid;

  CycleLog({
    required this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength,
    this.periodLength,
    this.note,
    this.symptoms = const [],
    this.syncedWithHealth = false,
    this.userModified = true,
    this.healthUuid,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'cycleLength': cycleLength,
        'periodLength': periodLength,
        'note': note,
        'symptoms': symptoms,
        'syncedWithHealth': syncedWithHealth,
        'userModified': userModified,
        'healthUuid': healthUuid,
      };

  factory CycleLog.fromJson(Map<String, dynamic> json) {
    return CycleLog(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      cycleLength: json['cycleLength'] as int?,
      periodLength: json['periodLength'] as int?,
      note: json['note'] as String?,
      symptoms: (json['symptoms'] as List?)?.map((e) => e.toString()).toList() ?? [],
      syncedWithHealth: json['syncedWithHealth'] as bool? ?? false,
      userModified: json['userModified'] as bool? ?? true,
      healthUuid: json['healthUuid'] as String?,
    );
  }
}