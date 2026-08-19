import '../models/daily_astrology.dart';

class AstrologyService {
  Future<DailyAstrology> getToday() async {
    final now = DateTime.now();
    final phase = _moonPhase(now);

    return DailyAstrology(
      date: now,
      moonPhase: phase.name,
      moonIllumination: phase.illumination,
      dayRuler: _dayRuler(now.weekday),
      energyLevel: phase.energy,
      personalEnergyPercent: phase.energyPercent,
      shortAdvice: phase.advice,
      affirmation: phase.affirmation,
      categoryTips: {},
      habitCompatibility: {},
      isMercuryRetrograde: false,
      retrogradeWarning: null,
      weeklyLunarOverview: [],
    );
  }

  _MoonInfo _moonPhase(DateTime date) {
    // Упрощённый расчёт фазы Луны
    final year = date.year;
    final month = date.month;
    final day = date.day;

    // Приближённый алгоритм
    final c = (year - 2000) * 12.3685 + month + day / 30.0;
    final phase = c % 29.53;

    if (phase < 1.85) {
      return _MoonInfo('Новолуние', 0.05, 'Низкая', 25, 'Время начинать новое', 'Я открыт новому');
    } else if (phase < 7.4) {
      return _MoonInfo('Растущая Луна', 0.35, 'Растущая', 55, 'Хорошее время для привычек', 'Я расту каждый день');
    } else if (phase < 9.25) {
      return _MoonInfo('Первая четверть', 0.5, 'Средняя', 60, 'Действуй уверенно', 'Я в потоке');
    } else if (phase < 14.8) {
      return _MoonInfo('Растущая Луна', 0.75, 'Высокая', 80, 'Энергия на подъёме', 'Я полон сил');
    } else if (phase < 16.6) {
      return _MoonInfo('Полнолуние', 1.0, 'Пик', 95, 'Кульминация, завершай дела', 'Я завершаю начатое');
    } else if (phase < 22.1) {
      return _MoonInfo('Убывающая Луна', 0.7, 'Спадающая', 50, 'Время отпускать', 'Я отпускаю лишнее');
    } else if (phase < 24.0) {
      return _MoonInfo('Последняя четверть', 0.5, 'Средняя', 40, 'Анализ и отдых', 'Я восстанавливаюсь');
    } else {
      return _MoonInfo('Убывающая Луна', 0.2, 'Низкая', 30, 'Подготовка к новому циклу', 'Я готовлюсь к новому');
    }
  }

  String _dayRuler(int weekday) {
    const rulers = {
      1: 'Луна',
      2: 'Марс',
      3: 'Меркурий',
      4: 'Юпитер',
      5: 'Венера',
      6: 'Сатурн',
      7: 'Солнце',
    };
    return rulers[weekday] ?? 'Луна';
  }
}

class _MoonInfo {
  final String name;
  final double illumination;
  final String energy;
  final int energyPercent;
  final String advice;
  final String affirmation;

  _MoonInfo(this.name, this.illumination, this.energy, this.energyPercent, this.advice, this.affirmation);
}