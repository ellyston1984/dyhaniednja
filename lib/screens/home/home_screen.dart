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
import '../../providers/cycle_provider.dart';
import '../cycle/cycle_screen.dart';
import '../astrology/astrology_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsState = ref.watch(habitsProvider);
    final habits = habitsState.habits;
    final settings = ref.watch(settingsProvider);
    final accent = ref.watch(accentColorProvider);
    final astrologyAsync = ref.watch(dailyAstrologyProvider);

    final bg = ref.watch(backgroundColorProvider);
    final text = ref.watch(textColorProvider);
    final secondary = ref.watch(secondaryTextColorProvider);
    final card = ref.watch(cardColorProvider);

    final now = DateTime.now();
    final dateStr = DateFormat('d MMMM', 'ru').format(now);
    final weekdayStr = DateFormat('EEEE', 'ru').format(now);

    final cycleState = ref.watch(cycleProvider);
    final showCycleStrip = settings.womenFeaturesEnabled &&
        settings.cycleTrackingEnabled &&
        settings.showCycleOnHome;

    return Scaffold(
      backgroundColor: bg,
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
                        Text(
                          'Дыхание дня',
                          style: TextStyle(
                            color: text,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$weekdayStr, $dateStr',
                          style: TextStyle(
                            color: secondary,
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
                    icon: Icon(Icons.settings_outlined, color: secondary),
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

            // ---------- Астрология ----------
            if (settings.astrologyEnabled)
              astrologyAsync.when(
                data: (astro) => _AstrologyCard(
                  astro: astro,
                  accent: accent,
                  card: card,
                  text: text,
                  secondary: secondary,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            
            // ---------- Полоска цикла ----------
            if (showCycleStrip)
              _CycleStrip(
                cycleState: cycleState,
                accent: accent,
                card: card,
                text: text,
                secondary: secondary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CycleScreen()),
                  );
                },
              ),

            // ---------- Список привычек ----------
            Expanded(
              child: habits.isEmpty
                  ? _EmptyState(accent: accent, text: text, secondary: secondary)
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: habits.length,
                      onReorder: (oldIndex, newIndex) {
                        ref.read(habitsProvider.notifier).reorder(oldIndex, newIndex);
                      },
                     itemBuilder: (context, index) {
                        final habit = habits[index];
                        final done = habitsState.todayCount(habit.id);
                        final target = habit.targetCount;
                        final completed = done >= target;

                        return _HabitCard(
                          key: ValueKey(habit.id),
                          habit: habit,
                          done: done,
                          target: target,
                          completed: completed,
                          accent: accent,
                          card: card,
                          text: text,
                          secondary: secondary,
                          onTap: () {},
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
class _AstrologyCard extends StatelessWidget {
  final dynamic astro;
  final Color accent;
  final Color card;
  final Color text;
  final Color secondary;

  const _AstrologyCard({
    required this.astro,
    required this.accent,
    required this.card,
    required this.text,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AstrologyScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
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
                    style: TextStyle(color: secondary, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: secondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ======================================================
class _HabitCard extends StatelessWidget {
  final Habit habit;
  final int done;
  final int target;
  final bool completed;
  final Color accent;
  final Color card;
  final Color text;
  final Color secondary;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _HabitCard({
    super.key,
    required this.habit,
    required this.done,
    required this.target,
    required this.completed,
    required this.accent,
    required this.card,
    required this.text,
    required this.secondary,
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
        color: card,
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
                Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    habit.title,
                    style: TextStyle(
                      color: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '$done/$target',
                  style: TextStyle(
                    color: completed ? accent : secondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completed ? color : Colors.transparent,
                      border: Border.all(
                        color: color.withOpacity(0.7),
                        width: 2,
                      ),
                    ),
                    child: completed
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : (done > 0
                            ? Text(
                                '$done',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null),
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
class _EmptyState extends StatelessWidget {
  final Color accent;
  final Color text;
  final Color secondary;

  const _EmptyState({
    required this.accent,
    required this.text,
    required this.secondary,
  });

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
                color: text,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Нажми + чтобы добавить первую',
              style: TextStyle(color: secondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
class _CycleStrip extends StatelessWidget {
  final dynamic cycleState;
  final Color accent;
  final Color card;
  final Color text;
  final Color secondary;
  final VoidCallback onTap;

  const _CycleStrip({
    required this.cycleState,
    required this.accent,
    required this.card,
    required this.text,
    required this.secondary,
    required this.onTap,
  });

  String get _phase => cycleState.currentPhase as String? ?? '';
  int? get _day => cycleState.currentCycleDay as int?;
  int? get _until => cycleState.daysUntilNextPeriod as int?;

  /// Основная мысль этих дней по фазе
  String get _mainThought {
    final phase = _phase.toLowerCase();
    if (phase.contains('менструац')) {
      return 'Время замедлиться и беречь силы. Мягкий режим, больше отдыха.';
    }
    if (phase.contains('фолликуляр')) {
      return 'Энергия растёт. Хорошие дни для новых привычек и планов.';
    }
    if (phase.contains('овуляц')) {
      return 'Пик сил и ясности. Удобно закреплять важное и общаться.';
    }
    if (phase.contains('лютеин')) {
      return 'Время завершать и успокаиваться. Меньше перегрузок.';
    }
    if (phase.contains('ожидан')) {
      return 'Цикл скоро обновится. Прислушайся к телу.';
    }
    if (_day == null) {
      return 'Отметь начало цикла — появится подсказка на эти дни.';
    }
    return 'Следи за ритмом. Маленькие шаги каждый день.';
  }

  String get _leftLabel {
    if (_day == null) return 'Цикл';
    return 'День $_day · $_phase';
  }

  String get _rightHint {
    if (_until == null) return '';
    if (_until == 0) return 'скоро месячные';
    return 'через $_until дн.';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE57373).withOpacity(0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя строка: день / фаза + прогноз
            Row(
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  size: 16,
                  color: const Color(0xFFE57373).withOpacity(0.9),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _leftLabel,
                    style: TextStyle(
                      color: accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_rightHint.isNotEmpty)
                  Text(
                    _rightHint,
                    style: TextStyle(color: secondary, fontSize: 12),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 18, color: secondary),
              ],
            ),
            const SizedBox(height: 8),
            // Основная мысль этих дней
            Text(
              _mainThought,
              style: TextStyle(
                color: text.withOpacity(0.85),
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}