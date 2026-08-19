class ChildProfile {
  final String id;
  final String name;
  final DateTime? birthDate;
  final String? avatarColor;
  final DateTime createdAt;

  ChildProfile({
    required this.id,
    required this.name,
    this.birthDate,
    this.avatarColor,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate?.toIso8601String(),
        'avatarColor': avatarColor,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: json['birthDate'] != null ? DateTime.tryParse(json['birthDate']) : null,
      avatarColor: json['avatarColor'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}