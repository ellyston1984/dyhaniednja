import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_provider.dart';

final accentColorProvider = Provider<Color>((ref) {
  final settings = ref.watch(settingsProvider);
  if (settings.monochromeMode) {
    return settings.isDarkMode ? Colors.white70 : Colors.black54;
  }
  return Color(settings.accentColorValue);
});

/// Фон экрана
final backgroundColorProvider = Provider<Color>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.isDarkMode
      ? const Color(0xFF0A0A0B)
      : const Color(0xFFF5F5F7);
});

/// Цвет текста
final textColorProvider = Provider<Color>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1E);
});

/// Вторичный текст
final secondaryTextColorProvider = Provider<Color>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.isDarkMode
      ? Colors.white.withOpacity(0.5)
      : Colors.black.withOpacity(0.45);
});

/// Цвет карточек
final cardColorProvider = Provider<Color>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.isDarkMode
      ? Colors.white.withOpacity(0.05)
      : Colors.white;
});