import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_astrology.dart';
import '../services/astrology_service.dart';

final astrologyServiceProvider = Provider<AstrologyService>((ref) {
  return AstrologyService();
});

final dailyAstrologyProvider =
    StateNotifierProvider<AstrologyNotifier, AsyncValue<DailyAstrology>>((ref) {
  return AstrologyNotifier(ref.watch(astrologyServiceProvider));
});

class AstrologyNotifier extends StateNotifier<AsyncValue<DailyAstrology>> {
  AstrologyNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  final AstrologyService _service;

  Future<void> load({bool forceRefresh = false}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.getToday(forceRefresh: forceRefresh),
    );
  }

  Future<void> refresh() => load(forceRefresh: true);
}