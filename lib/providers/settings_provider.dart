import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._service) : super(AppSettings.defaults()) {
    _load();
  }

  final SettingsService _service;

  Future<void> _load() async {
    final loaded = await _service.load();
    state = loaded.copyWith(isLoaded: true);
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    state = newSettings.copyWith(isLoaded: true);
    await _service.save(state);
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return SettingsNotifier(service);
});