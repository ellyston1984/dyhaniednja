import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/cycle_log.dart';

class CycleCalculation {
  final int? currentDay;
  final int? daysUntilNext;
  final String? phase;
  final int averageCycleLength;
  final int averagePeriodLength;
  final DateTime? predictedNextStart;
  final DateTime? fertileStart;
  final DateTime? fertileEnd;
  final DateTime? ovulationDay;

  const CycleCalculation({
    this.currentDay,
    this.daysUntilNext,
    this.phase,
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.predictedNextStart,
    this.fertileStart,
    this.fertileEnd,
    this.ovulationDay,
  });
}

class CycleService {
  static const _key = 'cycle_logs';
  final _uuid = const Uuid();

  Future<List<CycleLog>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => CycleLog.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
    } catch (_) {
      return [];
    }
  }

  Future<void> _save(List<CycleLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(logs.map((e) => e.toJson()).toList()),
    );
  }

  /// Добавить начало месячных
  Future<void> addPeriodStart(
    DateTime date, {
    int periodLength = 5,
    int? cycleLength,
  }) async {
    final logs = await getAll();
    final start = DateTime(date.year, date.month, date.day);

    // Если уже есть запись на эту дату — не дублируем
    final exists = logs.any((l) =>
        l.startDate.year == start.year &&
        l.startDate.month == start.month &&
        l.startDate.day == start.day);
    if (exists) return;

    // Пересчитать длину предыдущего цикла
    if (logs.isNotEmpty) {
      final prev = logs.first;
      final prevStart = DateTime(
        prev.startDate.year,
        prev.startDate.month,
        prev.startDate.day,
      );
      final diff = start.difference(prevStart).inDays;
      if (diff > 10 && diff < 60) {
        final updatedPrev = CycleLog(
          id: prev.id,
          startDate: prev.startDate,
          endDate: prev.endDate,
          cycleLength: diff,
          periodLength: prev.periodLength,
          note: prev.note,
          symptoms: prev.symptoms,
          syncedWithHealth: prev.syncedWithHealth,
          userModified: prev.userModified,
          healthUuid: prev.healthUuid,
        );
        logs[0] = updatedPrev;
      }
    }

    final log = CycleLog(
      id: _uuid.v4(),
      startDate: start,
      periodLength: periodLength,
      cycleLength: cycleLength ?? 28,
      symptoms: [],
      syncedWithHealth: false,
      userModified: true,
    );
    logs.insert(0, log);
    await _save(logs);
  }

  /// Удалить запись цикла
  Future<void> deleteLog(String id) async {
    final logs = await getAll();
    logs.removeWhere((l) => l.id == id);
    await _save(logs);
  }

  /// Обновить длину месячных у последней записи
  Future<void> updatePeriodLength(String id, int days) async {
    final logs = await getAll();
    final index = logs.indexWhere((l) => l.id == id);
    if (index < 0) return;

    final old = logs[index];
    logs[index] = CycleLog(
      id: old.id,
      startDate: old.startDate,
      endDate: old.endDate,
      cycleLength: old.cycleLength,
      periodLength: days.clamp(1, 15),
      note: old.note,
      symptoms: old.symptoms,
      syncedWithHealth: old.syncedWithHealth,
      userModified: true,
      healthUuid: old.healthUuid,
    );
    await _save(logs);
  }

  /// Отметить / снять день как день месячных (тап по календарю)
  Future<void> togglePeriodDay(DateTime day) async {
    final logs = await getAll();
    final d = DateTime(day.year, day.month, day.day);

    // Ищем, попадает ли день в уже существующий период
    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      final start = DateTime(
        log.startDate.year,
        log.startDate.month,
        log.startDate.day,
      );
      final length = log.periodLength ?? 5;
      final end = start.add(Duration(days: length - 1));

      if (!d.isBefore(start) && !d.isAfter(end)) {
        // День уже в периоде — укорачиваем или удаляем
        if (d == start && length == 1) {
          logs.removeAt(i);
        } else if (d == start) {
          // Сдвигаем старт на следующий день
          logs[i] = CycleLog(
            id: log.id,
            startDate: start.add(const Duration(days: 1)),
            endDate: log.endDate,
            cycleLength: log.cycleLength,
            periodLength: length - 1,
            note: log.note,
            symptoms: log.symptoms,
            syncedWithHealth: false,
            userModified: true,
            healthUuid: log.healthUuid,
          );
        } else {
          // Укорачиваем период до дня перед d
          final newLength = d.difference(start).inDays;
          logs[i] = CycleLog(
            id: log.id,
            startDate: log.startDate,
            endDate: log.endDate,
            cycleLength: log.cycleLength,
            periodLength: newLength.clamp(1, 15),
            note: log.note,
            symptoms: log.symptoms,
            syncedWithHealth: false,
            userModified: true,
            healthUuid: log.healthUuid,
          );
        }
        await _save(logs);
        return;
      }
    }

    // День не в периоде — начинаем новый или расширяем ближайший
    // Простая логика: если рядом с существующим (±2 дня) — расширяем, иначе новый
    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      final start = DateTime(
        log.startDate.year,
        log.startDate.month,
        log.startDate.day,
      );
      final length = log.periodLength ?? 5;
      final end = start.add(Duration(days: length - 1));

      // День сразу после конца
      if (d == end.add(const Duration(days: 1)) && length < 15) {
        logs[i] = CycleLog(
          id: log.id,
          startDate: log.startDate,
          endDate: log.endDate,
          cycleLength: log.cycleLength,
          periodLength: length + 1,
          note: log.note,
          symptoms: log.symptoms,
          syncedWithHealth: false,
          userModified: true,
          healthUuid: log.healthUuid,
        );
        await _save(logs);
        return;
      }

      // День сразу перед стартом
      if (d == start.subtract(const Duration(days: 1)) && length < 15) {
        logs[i] = CycleLog(
          id: log.id,
          startDate: d,
          endDate: log.endDate,
          cycleLength: log.cycleLength,
          periodLength: length + 1,
          note: log.note,
          symptoms: log.symptoms,
          syncedWithHealth: false,
          userModified: true,
          healthUuid: log.healthUuid,
        );
        await _save(logs);
        return;
      }
    }

    // Новый период
    await addPeriodStart(d, periodLength: 1);
  }

  /// Средняя длина цикла по истории
  int _avgCycleLength(List<CycleLog> logs) {
    final lengths = logs
        .where((l) => l.cycleLength != null && l.cycleLength! >= 15 && l.cycleLength! <= 45)
        .map((l) => l.cycleLength!)
        .toList();
    if (lengths.isEmpty) return 28;
    return (lengths.reduce((a, b) => a + b) / lengths.length).round();
  }

  int _avgPeriodLength(List<CycleLog> logs) {
    final lengths = logs
        .where((l) => l.periodLength != null)
        .map((l) => l.periodLength!)
        .toList();
    if (lengths.isEmpty) return 5;
    return (lengths.reduce((a, b) => a + b) / lengths.length).round();
  }

  CycleCalculation calculate(List<CycleLog> logs) {
    if (logs.isEmpty) {
      return const CycleCalculation();
    }

    final avgCycle = _avgCycleLength(logs);
    final avgPeriod = _avgPeriodLength(logs);
    final last = logs.first;
    final today = DateTime.now();
    final start = DateTime(
      last.startDate.year,
      last.startDate.month,
      last.startDate.day,
    );
    final day = today.difference(start).inDays + 1;

    String phase;
    if (day <= avgPeriod) {
      phase = 'Менструация';
    } else if (day <= (avgCycle / 2).floor() - 2) {
      phase = 'Фолликулярная фаза';
    } else if (day <= (avgCycle / 2).floor() + 1) {
      phase = 'Овуляция';
    } else if (day <= avgCycle) {
      phase = 'Лютеиновая фаза';
    } else {
      phase = 'Ожидание цикла';
    }

    final daysUntil = day <= avgCycle ? avgCycle - day : 0;
    final predictedNext = start.add(Duration(days: avgCycle));

    // Фертильное окно: примерно за 5 дней до овуляции и день после
    final ovulationOffset = (avgCycle / 2).floor();
    final ovulation = start.add(Duration(days: ovulationOffset - 1));
    final fertileStart = ovulation.subtract(const Duration(days: 5));
    final fertileEnd = ovulation.add(const Duration(days: 1));

    return CycleCalculation(
      currentDay: day > 0 ? day : null,
      daysUntilNext: daysUntil,
      phase: phase,
      averageCycleLength: avgCycle,
      averagePeriodLength: avgPeriod,
      predictedNextStart: predictedNext,
      fertileStart: fertileStart,
      fertileEnd: fertileEnd,
      ovulationDay: ovulation,
    );
  }

  /// Все дни месячных в заданном месяце
  Set<int> periodDaysInMonth(List<CycleLog> logs, DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final result = <int>{};

    for (final log in logs) {
      final start = DateTime(
        log.startDate.year,
        log.startDate.month,
        log.startDate.day,
      );
      final length = log.periodLength ?? 5;

      for (int i = 0; i < length; i++) {
        final d = start.add(Duration(days: i));
        if (d.year == month.year && d.month == month.month && d.day <= daysInMonth) {
          result.add(d.day);
        }
      }
    }
    return result;
  }

  /// Дни фертильного окна в месяце
  Set<int> fertileDaysInMonth(CycleCalculation calc, DateTime month) {
    if (calc.fertileStart == null || calc.fertileEnd == null) return {};
    final result = <int>{};
    var d = calc.fertileStart!;
    while (!d.isAfter(calc.fertileEnd!)) {
      if (d.year == month.year && d.month == month.month) {
        result.add(d.day);
      }
      d = d.add(const Duration(days: 1));
    }
    return result;
  }
}