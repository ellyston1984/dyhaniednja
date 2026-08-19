import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cycle_log.dart';
import '../services/cycle_service.dart';

class CycleState {
  final List<CycleLog> logs;
  final int? currentCycleDay;
  final int? daysUntilNextPeriod;
  final String? currentPhase;
  final int averageCycleLength;
  final int averagePeriodLength;
  final DateTime? predictedNextStart;
  final DateTime? fertileStart;
  final DateTime? fertileEnd;
  final DateTime? ovulationDay;
  final bool isLoading;

  const CycleState({
    this.logs = const [],
    this.currentCycleDay,
    this.daysUntilNextPeriod,
    this.currentPhase,
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.predictedNextStart,
    this.fertileStart,
    this.fertileEnd,
    this.ovulationDay,
    this.isLoading = false,
  });

  CycleState copyWith({
    List<CycleLog>? logs,
    int? currentCycleDay,
    int? daysUntilNextPeriod,
    String? currentPhase,
    int? averageCycleLength,
    int? averagePeriodLength,
    DateTime? predictedNextStart,
    DateTime? fertileStart,
    DateTime? fertileEnd,
    DateTime? ovulationDay,
    bool? isLoading,
  }) {
    return CycleState(
      logs: logs ?? this.logs,
      currentCycleDay: currentCycleDay ?? this.currentCycleDay,
      daysUntilNextPeriod: daysUntilNextPeriod ?? this.daysUntilNextPeriod,
      currentPhase: currentPhase ?? this.currentPhase,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodLength: averagePeriodLength ?? this.averagePeriodLength,
      predictedNextStart: predictedNextStart ?? this.predictedNextStart,
      fertileStart: fertileStart ?? this.fertileStart,
      fertileEnd: fertileEnd ?? this.fertileEnd,
      ovulationDay: ovulationDay ?? this.ovulationDay,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CycleNotifier extends StateNotifier<CycleState> {
  CycleNotifier(this._service) : super(const CycleState(isLoading: true)) {
    _load();
  }

  final CycleService _service;

  Future<void> _load() async {
    final logs = await _service.getAll();
    final calc = _service.calculate(logs);
    state = CycleState(
      logs: logs,
      currentCycleDay: calc.currentDay,
      daysUntilNextPeriod: calc.daysUntilNext,
      currentPhase: calc.phase,
      averageCycleLength: calc.averageCycleLength,
      averagePeriodLength: calc.averagePeriodLength,
      predictedNextStart: calc.predictedNextStart,
      fertileStart: calc.fertileStart,
      fertileEnd: calc.fertileEnd,
      ovulationDay: calc.ovulationDay,
      isLoading: false,
    );
  }

  Future<void> addPeriodStart(DateTime date, {int periodLength = 5}) async {
    await _service.addPeriodStart(date, periodLength: periodLength);
    await _load();
  }

  Future<void> togglePeriodDay(DateTime day) async {
    await _service.togglePeriodDay(day);
    await _load();
  }

  Future<void> deleteLog(String id) async {
    await _service.deleteLog(id);
    await _load();
  }

  Future<void> updatePeriodLength(String id, int days) async {
    await _service.updatePeriodLength(id, days);
    await _load();
  }

  Set<int> periodDaysInMonth(DateTime month) {
    return _service.periodDaysInMonth(state.logs, month);
  }

  Set<int> fertileDaysInMonth(DateTime month) {
    final calc = CycleCalculation(
      fertileStart: state.fertileStart,
      fertileEnd: state.fertileEnd,
    );
    return _service.fertileDaysInMonth(calc, month);
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