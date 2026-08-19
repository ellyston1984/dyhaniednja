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
  });
}