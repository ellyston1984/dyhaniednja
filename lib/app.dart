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
      theme: ThemeData(
        brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: const Color(0xFF0A0A0B),
        primaryColor: accent,
        colorScheme: ColorScheme.dark(
          primary: accent,
          secondary: accent,
          surface: const Color(0xFF0A0A0B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: settings.onboardingCompleted
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}