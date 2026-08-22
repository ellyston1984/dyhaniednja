import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../services/habit_log_service.dart';

class HabitsState {
  final List<Habit> habits;
  final Map<String, int> todayCounts; // habitId → сколько раз сегодня

  const HabitsState({
    this.habits = const [],
    this.todayCounts = const {},
  });

  HabitsState copyWith({
    List<Habit>? habits,
    Map<String, int>? todayCounts,
  }) {
    return HabitsState(
      habits: habits ?? this.habits,
      todayCounts: todayCounts ?? this.todayCounts,
    );
  }

  int todayCount(String habitId) => todayCounts[habitId] ?? 0;

  bool isDoneToday(Habit habit) =>
      todayCount(habit.id) >= habit.targetCount;
}

class HabitsNotifier extends StateNotifier<HabitsState> {
  HabitsNotifier(this._habitService, this._logService)
      : super(const HabitsState()) {
    _load();
  }

  final HabitService _habitService;
  final HabitLogService _logService;

  Future<void> _load() async {
    final habits = await _habitService.getAll();
    final counts = await _logService.todayCounts();
    state = HabitsState(habits: habits, todayCounts: counts);
  }

  Future<void> addHabit(Habit habit) async {
    await _habitService.add(habit);
    await _load();
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitService.update(habit);
    await _load();
  }

  Future<void> deleteHabit(String id) async {
    await _habitService.delete(id);
    await _load();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final list = [...state.habits];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(order: i);
    }
    await _habitService.saveAll(list);
    state = state.copyWith(habits: list);
  }

  Future<void> toggleCompletion(String habitId) async {
    final habit = state.habits.where((h) => h.id == habitId).firstOrNull;
    if (habit == null) return;

    await _logService.toggleToday(habitId, habit.targetCount);
    final counts = await _logService.todayCounts();
    state = state.copyWith(todayCounts: counts);
  }
}

final habitServiceProvider = Provider<HabitService>((ref) => HabitService());
final habitLogServiceProvider =
    Provider<HabitLogService>((ref) => HabitLogService());

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, HabitsState>((ref) {
  return HabitsNotifier(
    ref.watch(habitServiceProvider),
    ref.watch(habitLogServiceProvider),
  );
});