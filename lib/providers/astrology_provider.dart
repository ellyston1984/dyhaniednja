import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_astrology.dart';
import '../services/astrology_service.dart';

final astrologyServiceProvider = Provider<AstrologyService>((ref) {
  return AstrologyService();
});

final dailyAstrologyProvider = FutureProvider<DailyAstrology>((ref) async {
  final service = ref.watch(astrologyServiceProvider);
  return service.getToday();
});