import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';

class DyhanieDnyaApp extends ConsumerWidget {
  const DyhanieDnyaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = ref.watch(accentColorProvider);

    // Пока настройки грузятся — чёрный экран
    if (!settings.isLoaded) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF0A0A0B),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF4A9B9B)),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Дыхание дня',
      debugShowCheckedModeBanner: false,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        primaryColor: accent,
        colorScheme: ColorScheme.light(
          primary: accent,
          secondary: accent,
          surface: const Color(0xFFF5F5F7),
          onSurface: const Color(0xFF1A1A1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF1A1A1E),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0B),
        primaryColor: accent,
        colorScheme: ColorScheme.dark(
          primary: accent,
          secondary: accent,
          surface: const Color(0xFF0A0A0B),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: settings.onboardingCompleted
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}