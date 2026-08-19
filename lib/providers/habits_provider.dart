import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class HabitsNotifier extends StateNotifier<List<Habit>> {
  HabitsNotifier(this._service) : super([]) {
    _load();
  }

  final HabitService _service;

  Future<void> _load() async {
    state = await _service.getAll();
  }

  Future<void> addHabit(Habit habit) async {
    await _service.add(habit);
    state = [...state, habit];
  }

  Future<void> updateHabit(Habit habit) async {
    await _service.update(habit);
    state = [
      for (final h in state)
        if (h.id == habit.id) habit else h,
    ];
  }

  Future<void> deleteHabit(String id) async {
    await _service.delete(id);
    state = state.where((h) => h.id != id).toList();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    // обновляем order
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(order: i);
    }
    state = list;
    await _service.saveAll(list);
  }

  Future<void> toggleCompletion(String habitId) async {
    // Пока простая заглушка — позже подключим HabitLog
    // await _service.toggleToday(habitId);
  }
}

final habitServiceProvider = Provider<HabitService>((ref) {
  return HabitService();
});

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, List<Habit>>((ref) {
  final service = ref.watch(habitServiceProvider);
  return HabitsNotifier(service);
});