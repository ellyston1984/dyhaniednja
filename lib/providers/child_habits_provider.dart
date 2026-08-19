import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child_profile.dart';
import '../models/habit.dart';
import '../services/child_habits_service.dart';

class ChildHabitsState {
  final List<ChildProfile> profiles;
  final ChildProfile? selectedProfile;
  final List<Habit> habitsForSelected;

  const ChildHabitsState({
    this.profiles = const [],
    this.selectedProfile,
    this.habitsForSelected = const [],
  });

  ChildHabitsState copyWith({
    List<ChildProfile>? profiles,
    ChildProfile? selectedProfile,
    List<Habit>? habitsForSelected,
  }) {
    return ChildHabitsState(
      profiles: profiles ?? this.profiles,
      selectedProfile: selectedProfile ?? this.selectedProfile,
      habitsForSelected: habitsForSelected ?? this.habitsForSelected,
    );
  }
}

class ChildHabitsNotifier extends StateNotifier<ChildHabitsState> {
  ChildHabitsNotifier(this._service) : super(const ChildHabitsState()) {
    _load();
  }

  final ChildHabitsService _service;

  Future<void> _load() async {
    final profiles = await _service.getProfiles();
    final selected = profiles.isNotEmpty ? profiles.first : null;
    final habits = selected != null
        ? await _service.getHabitsForChild(selected.id)
        : <Habit>[];

    state = ChildHabitsState(
      profiles: profiles,
      selectedProfile: selected,
      habitsForSelected: habits,
    );
  }

  Future<void> selectProfile(String id) async {
    final profile = state.profiles.firstWhere((p) => p.id == id);
    final habits = await _service.getHabitsForChild(id);
    state = state.copyWith(
      selectedProfile: profile,
      habitsForSelected: habits,
    );
  }

  Future<void> addProfile(ChildProfile profile) async {
    await _service.addProfile(profile);
    await _load();
  }

  Future<void> toggleCompletion(String habitId) async {
    // заглушка
  }
}

final childHabitsServiceProvider = Provider<ChildHabitsService>((ref) {
  return ChildHabitsService();
});

final childHabitsProvider =
    StateNotifierProvider<ChildHabitsNotifier, ChildHabitsState>((ref) {
  final service = ref.watch(childHabitsServiceProvider);
  return ChildHabitsNotifier(service);
});