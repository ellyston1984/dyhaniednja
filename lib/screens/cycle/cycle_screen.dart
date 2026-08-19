import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/settings_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/cycle_log.dart';

class CycleScreen extends ConsumerStatefulWidget {
  const CycleScreen({super.key});

  @override
  ConsumerState<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends ConsumerState<CycleScreen> {
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accent = ref.watch(accentColorProvider);
    final cycleState = ref.watch(cycleProvider);

    // Если женские функции или цикл выключены
    if (!settings.womenFeaturesEnabled || !settings.cycleTrackingEnabled) {

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
          title: const Text('Цикл', style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        body: const Center(
          child: Text(
            'Отслеживание цикла выключено\nв настройках',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    }

    final logs = cycleState.logs;
    final currentCycleDay = cycleState.currentCycleDay;
    final nextPeriodIn = cycleState.daysUntilNextPeriod;
    final phase = cycleState.currentPhase;

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
          'Цикл',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: accent),
            onPressed: () => _showAddPeriodDialog(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // ---------- Текущий день цикла ----------
          _Card(
            child: Column(
              children: [
                Text(
                  'День цикла',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currentCycleDay != null ? '$currentCycleDay' : '—',
                  style: TextStyle(
                    color: accent,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phase ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 15,
                  ),
                ),
                if (nextPeriodIn != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Следующие месячные примерно через $nextPeriodIn дн.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ---------- Календарь ----------
          _sectionTitle('Календарь'),
          _Card(
            child: Column(
              children: [
                // Навигация по месяцам
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white54),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month - 1,
                          );
                        });
                      },
                    ),
                    Text(
                      DateFormat('LLLL yyyy', 'ru').format(_focusedMonth),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white54),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Дни недели
                Row(
                  children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(
                                d,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.35),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),

                // Сетка дней
                _buildCalendarGrid(logs, accent),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ---------- История ----------
          _sectionTitle('Последние циклы'),
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Пока нет записей.\nНажми + чтобы отметить начало месячных.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
              ),
            )
          else
            ...logs.take(5).map((log) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.water_drop, color: accent.withOpacity(0.7), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormat('d MMMM yyyy', 'ru').format(log.startDate),
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                    if (log.cycleLength != null)
                      Text(
                        '${log.cycleLength} дн.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(List<CycleLog> logs, Color accent) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    // Понедельник = 1
    int startWeekday = firstDayOfMonth.weekday; // 1=Пн ... 7=Вс
    final totalCells = ((startWeekday - 1) + daysInMonth);
    final rows = (totalCells / 7).ceil();

    // Дни месячных для текущего месяца
    final periodDays = <int>{};
    for (final log in logs) {
      if (log.startDate.year == _focusedMonth.year &&
          log.startDate.month == _focusedMonth.month) {
        final length = log.periodLength ?? 5;
        for (int i = 0; i < length; i++) {
          final d = log.startDate.day + i;
          if (d <= daysInMonth) periodDays.add(d);
        }
      }
    }

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNumber = cellIndex - (startWeekday - 1) + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 36));
              }

              final isPeriod = periodDays.contains(dayNumber);
              final isToday = dayNumber == DateTime.now().day &&
                  _focusedMonth.month == DateTime.now().month &&
                  _focusedMonth.year == DateTime.now().year;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Можно добавить отметку симптомов
                  },
                  child: Container(
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isPeriod
                          ? const Color(0xFFE57373).withOpacity(0.35)
                          : isToday
                              ? accent.withOpacity(0.2)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: accent, width: 1.5)
                          : null,
                    ),
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        color: isPeriod
                            ? const Color(0xFFFFCDD2)
                            : isToday
                                ? accent
                                : Colors.white70,
                        fontSize: 13,
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Future<void> _showAddPeriodDialog(BuildContext context, WidgetRef ref) async {
    DateTime selected = DateTime.now();

    final result = await showDialog<DateTime>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1E),
          title: const Text(
            'Начало месячных',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            height: 200,
            child: CalendarDatePicker(
              initialDate: selected,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              onDateChanged: (d) => selected = d,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, selected),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await ref.read(cycleProvider.notifier).addPeriodStart(result);
    }
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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