class DailyAstrology {
  final DateTime date;
  final String moonPhase;
  final double moonIllumination;
  final String dayRuler;
  final String energyLevel;
  final int personalEnergyPercent;
  final String shortAdvice;
  final String affirmation;
  final Map<String, String> categoryTips;
  final Map<String, int> habitCompatibility;
  final bool isMercuryRetrograde;
  final String? retrogradeWarning;
  final List<String> weeklyLunarOverview;

  /// 'farmsense' | 'local'
  final String source;
  final DateTime? updatedAt;

  const DailyAstrology({
    required this.date,
    required this.moonPhase,
    required this.moonIllumination,
    required this.dayRuler,
    required this.energyLevel,
    required this.personalEnergyPercent,
    required this.shortAdvice,
    required this.affirmation,
    this.categoryTips = const {},
    this.habitCompatibility = const {},
    this.isMercuryRetrograde = false,
    this.retrogradeWarning,
    this.weeklyLunarOverview = const [],
    this.source = 'local',
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'moonPhase': moonPhase,
        'moonIllumination': moonIllumination,
        'dayRuler': dayRuler,
        'energyLevel': energyLevel,
        'personalEnergyPercent': personalEnergyPercent,
        'shortAdvice': shortAdvice,
        'affirmation': affirmation,
        'categoryTips': categoryTips,
        'habitCompatibility': habitCompatibility,
        'isMercuryRetrograde': isMercuryRetrograde,
        'retrogradeWarning': retrogradeWarning,
        'weeklyLunarOverview': weeklyLunarOverview,
        'source': source,
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory DailyAstrology.fromJson(Map<String, dynamic> json) {
    return DailyAstrology(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      moonPhase: json['moonPhase'] as String? ?? 'Луна',
      moonIllumination: (json['moonIllumination'] as num?)?.toDouble() ?? 0.5,
      dayRuler: json['dayRuler'] as String? ?? '',
      energyLevel: json['energyLevel'] as String? ?? '',
      personalEnergyPercent: json['personalEnergyPercent'] as int? ?? 50,
      shortAdvice: json['shortAdvice'] as String? ?? '',
      affirmation: json['affirmation'] as String? ?? '',
      categoryTips: Map<String, String>.from(json['categoryTips'] as Map? ?? {}),
      habitCompatibility: (json['habitCompatibility'] as Map?)
              ?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ??
          {},
      isMercuryRetrograde: json['isMercuryRetrograde'] as bool? ?? false,
      retrogradeWarning: json['retrogradeWarning'] as String?,
      weeklyLunarOverview: (json['weeklyLunarOverview'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      source: json['source'] as String? ?? 'local',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}