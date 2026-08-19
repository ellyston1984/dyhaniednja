import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child_profile.dart';
import '../models/habit.dart';

class ChildHabitsService {
  static const _profilesKey = 'child_profiles';
  static const _habitsKey = 'child_habits';

  Future<List<ChildProfile>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profilesKey);
    if (raw == null) return [];

    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => ChildProfile.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addProfile(ChildProfile profile) async {
    final list = await getProfiles();
    list.add(profile);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _profilesKey,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<Habit>> getHabitsForChild(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_habitsKey);
    if (raw == null) return [];

    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Habit.fromJson(Map<String, dynamic>.from(e)))
          .where((h) => h.childProfileId == childId)
          .toList();
    } catch (_) {
      return [];
    }
  }
}