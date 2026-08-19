class Habit {
  final String id;
  final String title;
  final int colorValue;
  final String categoryId;
  final List<int> daysOfWeek;
  final int targetCount;
  final int order;
  final DateTime createdAt;
  final bool isArchived;
  final String? stackedAfterHabitId;
  final String? stackNote;
  final String? childProfileId;

  Habit({
    required this.id,
    required this.title,
    required this.colorValue,
    required this.categoryId,
    required this.daysOfWeek,
    this.targetCount = 1,
    this.order = 0,
    DateTime? createdAt,
    this.isArchived = false,
    this.stackedAfterHabitId,
    this.stackNote,
    this.childProfileId,
  }) : createdAt = createdAt ?? DateTime.now();

  Habit copyWith({
    String? id,
    String? title,
    int? colorValue,
    String? categoryId,
    List<int>? daysOfWeek,
    int? targetCount,
    int? order,
    DateTime? createdAt,
    bool? isArchived,
    String? stackedAfterHabitId,
    String? stackNote,
    String? childProfileId,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      colorValue: colorValue ?? this.colorValue,
      categoryId: categoryId ?? this.categoryId,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      targetCount: targetCount ?? this.targetCount,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      stackedAfterHabitId: stackedAfterHabitId ?? this.stackedAfterHabitId,
      stackNote: stackNote ?? this.stackNote,
      childProfileId: childProfileId ?? this.childProfileId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'colorValue': colorValue,
        'categoryId': categoryId,
        'daysOfWeek': daysOfWeek,
        'targetCount': targetCount,
        'order': order,
        'createdAt': createdAt.toIso8601String(),
        'isArchived': isArchived,
        'stackedAfterHabitId': stackedAfterHabitId,
        'stackNote': stackNote,
        'childProfileId': childProfileId,
      };

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      colorValue: json['colorValue'] as int,
      categoryId: json['categoryId'] as String,
      daysOfWeek: (json['daysOfWeek'] as List).map((e) => e as int).toList(),
      targetCount: json['targetCount'] as int? ?? 1,
      order: json['order'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isArchived: json['isArchived'] as bool? ?? false,
      stackedAfterHabitId: json['stackedAfterHabitId'] as String?,
      stackNote: json['stackNote'] as String?,
      childProfileId: json['childProfileId'] as String?,
    );
  }
}