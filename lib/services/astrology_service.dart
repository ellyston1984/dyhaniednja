import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_astrology.dart';

class AstrologyService {
  static const _cacheKey = 'astrology_cache_v1';
  static const _cacheDateKey = 'astrology_cache_date';

  /// Сегодня: сначала кэш на сегодня, потом API, потом локальный расчёт
  Future<DailyAstrology> getToday({bool forceRefresh = false}) async {
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cachedDate = prefs.getString(_cacheDateKey);
      final raw = prefs.getString(_cacheKey);
      if (cachedDate == todayKey && raw != null) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          return DailyAstrology.fromJson(map);
        } catch (_) {}
      }
    }

    // Пробуем официальный/публичный API
    try {
      final remote = await _fetchFromFarmsense(now);
      await prefs.setString(_cacheKey, jsonEncode(remote.toJson()));
      await prefs.setString(_cacheDateKey, todayKey);
      return remote;
    } catch (_) {
      // офлайн / ошибка сети
      final local = _localCalculate(now);
      // кэшируем локальный результат на сегодня, чтобы не дёргать каждый раз
      await prefs.setString(_cacheKey, jsonEncode(local.toJson()));
      await prefs.setString(_cacheDateKey, todayKey);
      return local;
    }
  }

  /// Farmsense: http://api.farmsense.net/v1/moonphases/?d=<unix>
  Future<DailyAstrology> _fetchFromFarmsense(DateTime date) async {
    final ts = date.toUtc().millisecondsSinceEpoch ~/ 1000;
    final uri = Uri.parse(
      'https://api.farmsense.net/v1/moonphases/?d=$ts',
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('Moon API status ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    // API возвращает список
    final list = decoded is List ? decoded : [decoded];
    if (list.isEmpty) throw Exception('Empty moon response');

    final item = Map<String, dynamic>.from(list.first as Map);
    final phaseName = (item['Phase'] ?? item['phase'] ?? 'Moon').toString();
    final illumination = _toDouble(item['Illumination'] ?? item['illumination']) ?? 0.5;

    final energy = _energyFromPhase(phaseName, illumination);

    return DailyAstrology(
      date: date,
      moonPhase: _localizePhase(phaseName),
      moonIllumination: illumination,
      dayRuler: _dayRuler(date.weekday),
      energyLevel: energy.level,
      personalEnergyPercent: energy.percent,
      shortAdvice: energy.advice,
      affirmation: energy.affirmation,
      categoryTips: {},
      habitCompatibility: {},
      isMercuryRetrograde: false,
      retrogradeWarning: null,
      weeklyLunarOverview: [],
      source: 'farmsense',
      updatedAt: DateTime.now(),
    );
  }

  DailyAstrology _localCalculate(DateTime date) {
    final phase = _moonPhase(date);
    return DailyAstrology(
      date: date,
      moonPhase: phase.name,
      moonIllumination: phase.illumination,
      dayRuler: _dayRuler(date.weekday),
      energyLevel: phase.energy,
      personalEnergyPercent: phase.energyPercent,
      shortAdvice: phase.advice,
      affirmation: phase.affirmation,
      categoryTips: {},
      habitCompatibility: {},
      isMercuryRetrograde: false,
      retrogradeWarning: null,
      weeklyLunarOverview: [],
      source: 'local',
      updatedAt: DateTime.now(),
    );
  }

  String _localizePhase(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('new')) return 'Новолуние';
    if (s.contains('waxing crescent')) return 'Растущий серп';
    if (s.contains('first quarter')) return 'Первая четверть';
    if (s.contains('waxing gibbous')) return 'Растущая Луна';
    if (s.contains('full')) return 'Полнолуние';
    if (s.contains('waning gibbous')) return 'Убывающая Луна';
    if (s.contains('last quarter') || s.contains('third quarter')) {
      return 'Последняя четверть';
    }
    if (s.contains('waning crescent')) return 'Убывающий серп';
    return raw;
  }

  _Energy _energyFromPhase(String phase, double illumination) {
    final p = phase.toLowerCase();
    if (p.contains('new')) {
      return _Energy('Низкая', 25, 'Время начинать новое', 'Я открыт новому');
    }
    if (p.contains('full')) {
      return _Energy('Пик', 95, 'Кульминация, завершай дела', 'Я завершаю начатое');
    }
    if (p.contains('waxing')) {
      return _Energy('Растущая', 70, 'Хорошее время для привычек', 'Я расту каждый день');
    }
    if (p.contains('waning')) {
      return _Energy('Спадающая', 40, 'Время отпускать', 'Я отпускаю лишнее');
    }
    if (illumination > 0.7) {
      return _Energy('Высокая', 80, 'Энергия на подъёме', 'Я полон сил');
    }
    return _Energy('Средняя', 55, 'Действуй уверенно', 'Я в потоке');
  }

  _MoonInfo _moonPhase(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;
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

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class _MoonInfo {
  final String name;
  final double illumination;
  final String energy;
  final int energyPercent;
  final String advice;
  final String affirmation;

  _MoonInfo(
    this.name,
    this.illumination,
    this.energy,
    this.energyPercent,
    this.advice,
    this.affirmation,
  );
}

class _Energy {
  final String level;
  final int percent;
  final String advice;
  final String affirmation;

  _Energy(this.level, this.percent, this.advice, this.affirmation);
}