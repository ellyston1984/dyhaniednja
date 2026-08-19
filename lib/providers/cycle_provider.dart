import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cycle_log.dart';
import '../services/cycle_service.dart';

class CycleState {
  final List<CycleLog> logs;
  final int? currentCycleDay;
  final int? daysUntilNextPeriod;
  final String? currentPhase;

  const CycleState({
    this.logs = const [],
    this.currentCycleDay,
    this.daysUntilNextPeriod,
    this.currentPhase,
  });

  CycleState copyWith({
    List<CycleLog>? logs,
    int? currentCycleDay,
    int? daysUntilNextPeriod,
    String? currentPhase,
  }) {
    return CycleState(
      logs: logs ?? this.logs,
      currentCycleDay: currentCycleDay ?? this.currentCycleDay,
      daysUntilNextPeriod: daysUntilNextPeriod ?? this.daysUntilNextPeriod,
      currentPhase: currentPhase ?? this.currentPhase,
    );
  }
}

class CycleNotifier extends StateNotifier<CycleState> {
  CycleNotifier(this._service) : super(const CycleState()) {
    _load();
  }

  final CycleService _service;

  Future<void> _load() async {
    final logs = await _service.getAll();
    final calculated = _service.calculate(logs);
    state = CycleState(
      logs: logs,
      currentCycleDay: calculated.currentDay,
      daysUntilNextPeriod: calculated.daysUntilNext,
      currentPhase: calculated.phase,
    );
  }

  Future<void> addPeriodStart(DateTime date) async {
    await _service.addPeriodStart(date);
    await _load();
  }
}

final cycleServiceProvider = Provider<CycleService>((ref) {
  return CycleService();
});

final cycleProvider =
    StateNotifierProvider<CycleNotifier, CycleState>((ref) {
  final service = ref.watch(cycleServiceProvider);
  return CycleNotifier(service);
});