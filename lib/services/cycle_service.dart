import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/cycle_log.dart';

class CycleCalculation {
  final int? currentDay;
  final int? daysUntilNext;
  final String? phase;

  CycleCalculation({this.currentDay, this.daysUntilNext, this.phase});
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

  Future<void> addPeriodStart(DateTime date) async {
    final logs = await getAll();
    final log = CycleLog(
      id: _uuid.v4(),
      startDate: DateTime(date.year, date.month, date.day),
      periodLength: 5,
      cycleLength: 28,
      symptoms: [],
      syncedWithHealth: false,
      userModified: true,
    );
    logs.insert(0, log);
    await _save(logs);
  }

  CycleCalculation calculate(List<CycleLog> logs) {
    if (logs.isEmpty) {
      return CycleCalculation();
    }

    final last = logs.first;
    final today = DateTime.now();
    final start = DateTime(last.startDate.year, last.startDate.month, last.startDate.day);
    final day = today.difference(start).inDays + 1;
    final avgCycle = last.cycleLength ?? 28;

    String phase;
    if (day <= 5) {
      phase = 'Менструация';
    } else if (day <= 13) {
      phase = 'Фолликулярная фаза';
    } else if (day <= 16) {
      phase = 'Овуляция';
    } else {
      phase = 'Лютеиновая фаза';
    }

    final daysUntil = avgCycle - day;
    return CycleCalculation(
      currentDay: day > 0 ? day : null,
      daysUntilNext: daysUntil > 0 ? daysUntil : 0,
      phase: phase,
    );
  }
}