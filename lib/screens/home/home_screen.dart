import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/habit.dart';
import '../../providers/habits_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/astrology_provider.dart';
import '../../providers/theme_provider.dart';
import '../habit/habit_edit_screen.dart';
import '../stats/stats_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final settings = ref.watch(settingsProvider);
    final accent = ref.watch(accentColorProvider);
    final astrologyAsync = ref.watch(dailyAstrologyProvider);

    final now = DateTime.now();
    final dateStr = DateFormat('d MMMM', 'ru').format(now);
    final weekdayStr = DateFormat('EEEE', 'ru').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- AppBar ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Дыхание дня',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$weekdayStr, $dateStr',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.bar_chart_rounded, color: accent),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StatsScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: Colors.white54),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ---------- Астрология (если включена) ----------
            if (settings.astrologyEnabled)
              astrologyAsync.when(
                data: (astro) => _AstrologyCard(astro: astro, accent: accent),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

            // ---------- Список привычек ----------
            Expanded(
              child: habits.isEmpty
                  ? _EmptyState(accent: accent)
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: habits.length,
                      onReorder: (oldIndex, newIndex) {
                        ref.read(habitsProvider.notifier).reorder(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        return _HabitCard(
                          key: ValueKey(habit.id),
                          habit: habit,
                          accent: accent,
                          onTap: () {
                            // TODO: открыть детали / отметить
                          },
                          onToggle: () {
                            ref.read(habitsProvider.notifier).toggleCompletion(habit.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ---------- FAB ----------
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HabitEditScreen()),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

// ======================================================
// Карточка астрологии
// ======================================================
class _AstrologyCard extends StatelessWidget {
  final dynamic astro; // DailyAstrology
  final Color accent;

  const _AstrologyCard({required this.astro, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.nightlight_round, color: accent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  astro.moonPhase ?? 'Луна',
                  style: TextStyle(
                    color: accent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  astro.shortAdvice ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// Карточка привычки
// ======================================================
class _HabitCard extends StatelessWidget {
  final Habit habit;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _HabitCard({
    super.key,
    required this.habit,
    required this.accent,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                // Цветная полоска
                Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),

                // Название
                Expanded(
                  child: Text(
                    habit.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Прогресс (пока заглушка 0/target)
                Text(
                  '0/${habit.targetCount}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),

                // Кнопка отметки
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withOpacity(0.6), width: 2),
                    ),
                    child: Icon(Icons.check, size: 18, color: color.withOpacity(0.0)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// Пустое состояние
// ======================================================
class _EmptyState extends StatelessWidget {
  final Color accent;

  const _EmptyState({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 64, color: accent.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(
              'Пока нет привычек',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Нажми + чтобы добавить первую',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
