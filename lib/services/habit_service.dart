import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class HabitService {
  static const _key = 'habits';

  Future<List<Habit>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Habit.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final list = habits.map((h) => h.toJson()).toList();
    await prefs.setString(_key, jsonEncode(list));
  }

  Future<void> add(Habit habit) async {
    final list = await getAll();
    list.add(habit);
    await saveAll(list);
  }

  Future<void> update(Habit habit) async {
    final list = await getAll();
    final index = list.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      list[index] = habit;
      await saveAll(list);
    }
  }

  Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((h) => h.id == id);
    await saveAll(list);
  }
}