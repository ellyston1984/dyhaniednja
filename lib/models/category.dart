class Category {
  final String id;
  final String name;
  final bool isCustom;
  final int? colorValue;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.isCustom = false,
    this.colorValue,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isCustom': isCustom,
        'colorValue': colorValue,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
      colorValue: json['colorValue'] as int?,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}