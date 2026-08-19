import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/habits_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/astrology_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/habit.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final settings = ref.watch(settingsProvider);
    final accent = ref.watch(accentColorProvider);
    final astrologyAsync = ref.watch(dailyAstrologyProvider);

    // Пока простая заглушка серии (позже посчитаем реально)
    final currentStreak = 0;
    final bestStreak = 0;
   
    final bg = ref.watch(backgroundColorProvider);
    final text = ref.watch(textColorProvider);
    final secondary = ref.watch(secondaryTextColorProvider);
    final card = ref.watch(cardColorProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Статистика',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // ---------- Текущая серия ----------
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_fire_department, color: accent, size: 28),
                    const SizedBox(width: 10),
                    const Text(
                      'Текущая серия',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$currentStreak дней',
                  style: TextStyle(
                    color: accent,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Лучшая серия: $bestStreak дней',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  settings.streakMode == 'strict'
                      ? 'Режим: строгий'
                      : 'Режим: мягкий',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ---------- Астрология (если включена) ----------
          if (settings.astrologyEnabled)
            astrologyAsync.when(
              data: (astro) => _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.nightlight_round, color: accent, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Лунный ритм',
                          style: TextStyle(
                            color: accent,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      astro.moonPhase ?? '—',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      astro.shortAdvice ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    if (astro.affirmation != null && astro.affirmation!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        '«${astro.affirmation}»',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

          if (settings.astrologyEnabled) const SizedBox(height: 16),

          // ---------- Привычки сегодня ----------
          _sectionTitle('Привычки'),
          if (habits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Пока нет привычек',
                style: TextStyle(color: Colors.white.withOpacity(0.4)),
              ),
            )
          else
            ...habits.map((habit) {
              return _HabitStatRow(
                habit: habit,
                accent: accent,
              );
            }),

          const SizedBox(height: 24),

          // ---------- Простой календарь (заглушка) ----------
          _sectionTitle('Календарь выполнений'),
          _Card(
            child: Column(
              children: [
                Text(
                  DateFormat('LLLL yyyy', 'ru').format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                // Простая сетка дней (заглушка)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(28, (i) {
                    final day = i + 1;
                    final isToday = day == DateTime.now().day;
                    return Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isToday
                            ? accent.withOpacity(0.3)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: accent, width: 1.5)
                            : null,
                      ),
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isToday ? accent : Colors.white54,
                          fontSize: 13,
                          fontWeight:
                              isToday ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  'Подробный календарь появится позже',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ======================================================
// Вспомогательные виджеты
// ======================================================

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _HabitStatRow extends StatelessWidget {
  final Habit habit;
  final Color accent;

  const _HabitStatRow({
    required this.habit,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              habit.title,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          Text(
            '0 / ${habit.targetCount}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

