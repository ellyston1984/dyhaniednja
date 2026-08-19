class AppSettings {
  final bool isLoaded;
  final String localeCode;
  final bool isDarkMode;
  final int accentColorValue;
  final String backgroundStyle;
  final String cardStyle;
  final bool monochromeMode;
  final String streakMode;
  final bool astrologyEnabled;
  final bool showPersonalEnergy;
  final bool showDayRuler;
  final bool showWeeklyLunar;
  final bool showAffirmation;
  final bool showRetrogrades;
  final DateTime? birthDate;
  final String astrologyStyle;
  final bool smartInsightsEnabled;
  final bool womenFeaturesEnabled;
  final bool cycleTrackingEnabled;
  final bool showCycleOnHome;
  final bool showFertileWindow;
  final int averageCycleLength;
  final int averagePeriodLength;
  final bool pregnancyModeEnabled;
  final DateTime? pregnancyDueDate;
  final int? pregnancyWeek;
  final bool childHabitsEnabled;
  final bool showChildHabitsOnHome;
  final bool widgetsEnabled;
  final bool notificationsEnabled;
  final bool voiceInputEnabled;
  final bool healthIntegrationEnabled;
  final bool habitStackingEnabled;
  final bool sharedHabitsEnabled;
  final bool advancedLunarEnabled;
  final bool fullAstroProfileEnabled;
  final bool syncCycleWithHealth;
  final bool onboardingCompleted;
  final bool showNeuralNetworkStub;
  final bool showMessengerLink;

  const AppSettings({
    this.isLoaded = false,
    this.localeCode = 'ru',
    this.isDarkMode = true,
    this.accentColorValue = 0xFF4A9B9B,
    this.backgroundStyle = 'pure_black',
    this.cardStyle = 'flat',
    this.monochromeMode = false,
    this.streakMode = 'soft',
    this.astrologyEnabled = false,
    this.showPersonalEnergy = true,
    this.showDayRuler = true,
    this.showWeeklyLunar = false,
    this.showAffirmation = true,
    this.showRetrogrades = false,
    this.birthDate,
    this.astrologyStyle = 'soft',
    this.smartInsightsEnabled = true,
    this.womenFeaturesEnabled = false,
    this.cycleTrackingEnabled = false,
    this.showCycleOnHome = true,
    this.showFertileWindow = true,
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.pregnancyModeEnabled = false,
    this.pregnancyDueDate,
    this.pregnancyWeek,
    this.childHabitsEnabled = false,
    this.showChildHabitsOnHome = true,
    this.widgetsEnabled = false,
    this.notificationsEnabled = false,
    this.voiceInputEnabled = false,
    this.healthIntegrationEnabled = false,
    this.habitStackingEnabled = false,
    this.sharedHabitsEnabled = false,
    this.advancedLunarEnabled = false,
    this.fullAstroProfileEnabled = false,
    this.syncCycleWithHealth = false,
    this.onboardingCompleted = false,
    this.showNeuralNetworkStub = true,
    this.showMessengerLink = true,
  });

  factory AppSettings.defaults() => const AppSettings();

  AppSettings copyWith({
    bool? isLoaded,
    String? localeCode,
    bool? isDarkMode,
    int? accentColorValue,
    String? backgroundStyle,
    String? cardStyle,
    bool? monochromeMode,
    String? streakMode,
    bool? astrologyEnabled,
    bool? showPersonalEnergy,
    bool? showDayRuler,
    bool? showWeeklyLunar,
    bool? showAffirmation,
    bool? showRetrogrades,
    DateTime? birthDate,
    String? astrologyStyle,
    bool? smartInsightsEnabled,
    bool? womenFeaturesEnabled,
    bool? cycleTrackingEnabled,
    bool? showCycleOnHome,
    bool? showFertileWindow,
    int? averageCycleLength,
    int? averagePeriodLength,
    bool? pregnancyModeEnabled,
    DateTime? pregnancyDueDate,
    int? pregnancyWeek,
    bool? childHabitsEnabled,
    bool? showChildHabitsOnHome,
    bool? widgetsEnabled,
    bool? notificationsEnabled,
    bool? voiceInputEnabled,
    bool? healthIntegrationEnabled,
    bool? habitStackingEnabled,
    bool? sharedHabitsEnabled,
    bool? advancedLunarEnabled,
    bool? fullAstroProfileEnabled,
    bool? syncCycleWithHealth,
    bool? onboardingCompleted,
    bool? showNeuralNetworkStub,
    bool? showMessengerLink,
  }) {
    return AppSettings(
      isLoaded: isLoaded ?? this.isLoaded,
      localeCode: localeCode ?? this.localeCode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      backgroundStyle: backgroundStyle ?? this.backgroundStyle,
      cardStyle: cardStyle ?? this.cardStyle,
      monochromeMode: monochromeMode ?? this.monochromeMode,
      streakMode: streakMode ?? this.streakMode,
      astrologyEnabled: astrologyEnabled ?? this.astrologyEnabled,
      showPersonalEnergy: showPersonalEnergy ?? this.showPersonalEnergy,
      showDayRuler: showDayRuler ?? this.showDayRuler,
      showWeeklyLunar: showWeeklyLunar ?? this.showWeeklyLunar,
      showAffirmation: showAffirmation ?? this.showAffirmation,
      showRetrogrades: showRetrogrades ?? this.showRetrogrades,
      birthDate: birthDate ?? this.birthDate,
      astrologyStyle: astrologyStyle ?? this.astrologyStyle,
      smartInsightsEnabled: smartInsightsEnabled ?? this.smartInsightsEnabled,
      womenFeaturesEnabled: womenFeaturesEnabled ?? this.womenFeaturesEnabled,
      cycleTrackingEnabled: cycleTrackingEnabled ?? this.cycleTrackingEnabled,
      showCycleOnHome: showCycleOnHome ?? this.showCycleOnHome,
      showFertileWindow: showFertileWindow ?? this.showFertileWindow,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodLength: averagePeriodLength ?? this.averagePeriodLength,
      pregnancyModeEnabled: pregnancyModeEnabled ?? this.pregnancyModeEnabled,
      pregnancyDueDate: pregnancyDueDate ?? this.pregnancyDueDate,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      childHabitsEnabled: childHabitsEnabled ?? this.childHabitsEnabled,
      showChildHabitsOnHome: showChildHabitsOnHome ?? this.showChildHabitsOnHome,
      widgetsEnabled: widgetsEnabled ?? this.widgetsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      voiceInputEnabled: voiceInputEnabled ?? this.voiceInputEnabled,
      healthIntegrationEnabled: healthIntegrationEnabled ?? this.healthIntegrationEnabled,
      habitStackingEnabled: habitStackingEnabled ?? this.habitStackingEnabled,
      sharedHabitsEnabled: sharedHabitsEnabled ?? this.sharedHabitsEnabled,
      advancedLunarEnabled: advancedLunarEnabled ?? this.advancedLunarEnabled,
      fullAstroProfileEnabled: fullAstroProfileEnabled ?? this.fullAstroProfileEnabled,
      syncCycleWithHealth: syncCycleWithHealth ?? this.syncCycleWithHealth,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      showNeuralNetworkStub: showNeuralNetworkStub ?? this.showNeuralNetworkStub,
      showMessengerLink: showMessengerLink ?? this.showMessengerLink,
    );
  }

  Map<String, dynamic> toJson() => {
        'localeCode': localeCode,
        'isDarkMode': isDarkMode,
        'accentColorValue': accentColorValue,
        'backgroundStyle': backgroundStyle,
        'cardStyle': cardStyle,
        'monochromeMode': monochromeMode,
        'streakMode': streakMode,
        'astrologyEnabled': astrologyEnabled,
        'showPersonalEnergy': showPersonalEnergy,
        'showDayRuler': showDayRuler,
        'showWeeklyLunar': showWeeklyLunar,
        'showAffirmation': showAffirmation,
        'showRetrogrades': showRetrogrades,
        'birthDate': birthDate?.toIso8601String(),
        'astrologyStyle': astrologyStyle,
        'smartInsightsEnabled': smartInsightsEnabled,
        'womenFeaturesEnabled': womenFeaturesEnabled,
        'cycleTrackingEnabled': cycleTrackingEnabled,
        'showCycleOnHome': showCycleOnHome,
        'showFertileWindow': showFertileWindow,
        'averageCycleLength': averageCycleLength,
        'averagePeriodLength': averagePeriodLength,
        'pregnancyModeEnabled': pregnancyModeEnabled,
        'pregnancyDueDate': pregnancyDueDate?.toIso8601String(),
        'pregnancyWeek': pregnancyWeek,
        'childHabitsEnabled': childHabitsEnabled,
        'showChildHabitsOnHome': showChildHabitsOnHome,
        'widgetsEnabled': widgetsEnabled,
        'notificationsEnabled': notificationsEnabled,
        'voiceInputEnabled': voiceInputEnabled,
        'healthIntegrationEnabled': healthIntegrationEnabled,
        'habitStackingEnabled': habitStackingEnabled,
        'sharedHabitsEnabled': sharedHabitsEnabled,
        'advancedLunarEnabled': advancedLunarEnabled,
        'fullAstroProfileEnabled': fullAstroProfileEnabled,
        'syncCycleWithHealth': syncCycleWithHealth,
        'onboardingCompleted': onboardingCompleted,
        'showNeuralNetworkStub': showNeuralNetworkStub,
        'showMessengerLink': showMessengerLink,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isLoaded: true,
      localeCode: json['localeCode'] as String? ?? 'ru',
      isDarkMode: json['isDarkMode'] as bool? ?? true,
      accentColorValue: json['accentColorValue'] as int? ?? 0xFF4A9B9B,
      backgroundStyle: json['backgroundStyle'] as String? ?? 'pure_black',
      cardStyle: json['cardStyle'] as String? ?? 'flat',
      monochromeMode: json['monochromeMode'] as bool? ?? false,
      streakMode: json['streakMode'] as String? ?? 'soft',
      astrologyEnabled: json['astrologyEnabled'] as bool? ?? false,
      showPersonalEnergy: json['showPersonalEnergy'] as bool? ?? true,
      showDayRuler: json['showDayRuler'] as bool? ?? true,
      showWeeklyLunar: json['showWeeklyLunar'] as bool? ?? false,
      showAffirmation: json['showAffirmation'] as bool? ?? true,
      showRetrogrades: json['showRetrogrades'] as bool? ?? false,
      birthDate: json['birthDate'] != null ? DateTime.tryParse(json['birthDate']) : null,
      astrologyStyle: json['astrologyStyle'] as String? ?? 'soft',
      smartInsightsEnabled: json['smartInsightsEnabled'] as bool? ?? true,
      womenFeaturesEnabled: json['womenFeaturesEnabled'] as bool? ?? false,
      cycleTrackingEnabled: json['cycleTrackingEnabled'] as bool? ?? false,
      showCycleOnHome: json['showCycleOnHome'] as bool? ?? true,
      showFertileWindow: json['showFertileWindow'] as bool? ?? true,
      averageCycleLength: json['averageCycleLength'] as int? ?? 28,
      averagePeriodLength: json['averagePeriodLength'] as int? ?? 5,
      pregnancyModeEnabled: json['pregnancyModeEnabled'] as bool? ?? false,
      pregnancyDueDate: json['pregnancyDueDate'] != null ? DateTime.tryParse(json['pregnancyDueDate']) : null,
      pregnancyWeek: json['pregnancyWeek'] as int?,
      childHabitsEnabled: json['childHabitsEnabled'] as bool? ?? false,
      showChildHabitsOnHome: json['showChildHabitsOnHome'] as bool? ?? true,
      widgetsEnabled: json['widgetsEnabled'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      voiceInputEnabled: json['voiceInputEnabled'] as bool? ?? false,
      healthIntegrationEnabled: json['healthIntegrationEnabled'] as bool? ?? false,
      habitStackingEnabled: json['habitStackingEnabled'] as bool? ?? false,
      sharedHabitsEnabled: json['sharedHabitsEnabled'] as bool? ?? false,
      advancedLunarEnabled: json['advancedLunarEnabled'] as bool? ?? false,
      fullAstroProfileEnabled: json['fullAstroProfileEnabled'] as bool? ?? false,
      syncCycleWithHealth: json['syncCycleWithHealth'] as bool? ?? false,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      showNeuralNetworkStub: json['showNeuralNetworkStub'] as bool? ?? true,
      showMessengerLink: json['showMessengerLink'] as bool? ?? true,
    );
  }
}