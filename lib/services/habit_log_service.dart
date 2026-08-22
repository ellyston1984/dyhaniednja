import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/habit_log.dart';

class HabitLogService {
  static const _key = 'habit_logs';
  final _uuid = const Uuid();

  Future<List<HabitLog>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => HabitLog.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _save(List<HabitLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(logs.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<HabitLog>> getForHabit(String habitId) async {
    final all = await getAll();
    return all.where((l) => l.habitId == habitId).toList();
  }

  Future<HabitLog?> getForHabitOnDay(String habitId, DateTime day) async {
    final d = DateTime(day.year, day.month, day.day);
    final all = await getAll();
    try {
      return all.firstWhere(
        (l) =>
            l.habitId == habitId &&
            l.dayOnly.year == d.year &&
            l.dayOnly.month == d.month &&
            l.dayOnly.day == d.day,
      );
    } catch (_) {
      return null;
    }
  }

  /// +1 к выполнению за сегодня; если достигли target — не больше target
  Future<HabitLog> incrementToday(String habitId, int targetCount) async {
    final today = DateTime.now();
    final all = await getAll();
    final d = DateTime(today.year, today.month, today.day);

    final index = all.indexWhere(
      (l) =>
          l.habitId == habitId &&
          l.dayOnly.year == d.year &&
          l.dayOnly.month == d.month &&
          l.dayOnly.day == d.day,
    );

    if (index >= 0) {
      final old = all[index];
      final next = (old.completedCount + 1).clamp(0, targetCount);
      final updated = HabitLog(
        id: old.id,
        habitId: old.habitId,
        date: old.date,
        completedCount: next,
        note: old.note,
        moodScore: old.moodScore,
      );
      all[index] = updated;
      await _save(all);
      return updated;
    }

    final created = HabitLog(
      id: _uuid.v4(),
      habitId: habitId,
      date: d,
      completedCount: 1.clamp(0, targetCount),
    );
    all.add(created);
    await _save(all);
    return created;
  }

  /// Цикл: 0 → 1 → … → target → 0
  Future<int> toggleToday(String habitId, int targetCount) async {
    final today = DateTime.now();
    final all = await getAll();
    final d = DateTime(today.year, today.month, today.day);

    final index = all.indexWhere(
      (l) =>
          l.habitId == habitId &&
          l.dayOnly.year == d.year &&
          l.dayOnly.month == d.month &&
          l.dayOnly.day == d.day,
    );

    if (index < 0) {
      final created = HabitLog(
        id: _uuid.v4(),
        habitId: habitId,
        date: d,
        completedCount: targetCount <= 1 ? 1 : 1,
      );
      all.add(created);
      await _save(all);
      return created.completedCount;
    }

    final old = all[index];
    int next;
    if (old.completedCount >= targetCount) {
      // сброс
      all.removeAt(index);
      await _save(all);
      return 0;
    } else {
      next = old.completedCount + 1;
      all[index] = HabitLog(
        id: old.id,
        habitId: old.habitId,
        date: old.date,
        completedCount: next,
        note: old.note,
        moodScore: old.moodScore,
      );
      await _save(all);
      return next;
    }
  }

  Future<Map<String, int>> todayCounts() async {
    final today = DateTime.now();
    final d = DateTime(today.year, today.month, today.day);
    final all = await getAll();
    final map = <String, int>{};
    for (final l in all) {
      if (l.dayOnly.year == d.year &&
          l.dayOnly.month == d.month &&
          l.dayOnly.day == d.day) {
        map[l.habitId] = l.completedCount;
      }
    }
    return map;
  }
}