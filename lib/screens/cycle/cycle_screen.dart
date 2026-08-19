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

  static const _periodColor = Color(0xFFE57373);
  static const _fertileColor = Color(0xFF81C784);
  static const _ovulationColor = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accent = ref.watch(accentColorProvider);
    final cycleState = ref.watch(cycleProvider);

    final bg = ref.watch(backgroundColorProvider);
    final text = ref.watch(textColorProvider);
    final secondary = ref.watch(secondaryTextColorProvider);
    final card = ref.watch(cardColorProvider);

    // Функция выключена
    if (!settings.womenFeaturesEnabled || !settings.cycleTrackingEnabled) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: secondary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Цикл', style: TextStyle(color: text, fontSize: 18)),
        ),
        body: Center(
          child: Text(
            'Отслеживание цикла выключено\nв настройках',
            textAlign: TextAlign.center,
            style: TextStyle(color: secondary, fontSize: 16),
          ),
        ),
      );
    }

    final logs = cycleState.logs;
    final currentCycleDay = cycleState.currentCycleDay;
    final nextPeriodIn = cycleState.daysUntilNextPeriod;
    final phase = cycleState.currentPhase;
    final showFertile = settings.showFertileWindow;

    final periodDays =
        ref.read(cycleProvider.notifier).periodDaysInMonth(_focusedMonth);
    final fertileDays = showFertile
        ? ref.read(cycleProvider.notifier).fertileDaysInMonth(_focusedMonth)
        : <int>{};

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: secondary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Цикл', style: TextStyle(color: text, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: accent),
            tooltip: 'Начало месячных',
            onPressed: () => _showAddPeriodDialog(
              context,
              ref,
              bg,
              text,
              secondary,
              accent,
            ),
          ),
        ],
      ),
      body: cycleState.isLoading
          ? Center(child: CircularProgressIndicator(color: accent))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                // ---------- Текущий день ----------
                _Card(
                  color: card,
                  child: Column(
                    children: [
                      Text(
                        'День цикла',
                        style: TextStyle(color: secondary, fontSize: 13),
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
                        phase ?? 'Добавьте первую запись',
                        style: TextStyle(
                          color: text.withOpacity(0.8),
                          fontSize: 15,
                        ),
                      ),
                      if (nextPeriodIn != null && currentCycleDay != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          nextPeriodIn == 0
                              ? 'Ожидаются месячные'
                              : 'Следующие месячные примерно через $nextPeriodIn дн.',
                          style: TextStyle(color: secondary, fontSize: 13),
                        ),
                      ],
                      if (cycleState.averageCycleLength > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Средний цикл: ${cycleState.averageCycleLength} дн.  ·  '
                          'Месячные: ${cycleState.averagePeriodLength} дн.',
                          style: TextStyle(
                            color: secondary.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ---------- Календарь ----------
                _sectionTitle('Календарь', secondary),
                _Card(
                  color: card,
                  child: Column(
                    children: [
                      // Навигация по месяцам
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left, color: secondary),
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
                            style: TextStyle(
                              color: text,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right, color: secondary),
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
                      const SizedBox(height: 4),

                      // Дни недели
                      Row(
                        children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                            .map(
                              (d) => Expanded(
                                child: Center(
                                  child: Text(
                                    d,
                                    style: TextStyle(
                                      color: secondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),

                      // Сетка
                      _buildCalendarGrid(
                        periodDays: periodDays,
                        fertileDays: fertileDays,
                        ovulationDay: cycleState.ovulationDay,
                        accent: accent,
                        text: text,
                        secondary: secondary,
                      ),

                      const SizedBox(height: 16),

                      // Легенда
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _legendDot(_periodColor, 'Месячные', text),
                          if (showFertile)
                            _legendDot(_fertileColor, 'Фертильное окно', text),
                          if (showFertile)
                            _legendDot(_ovulationColor, 'Овуляция', text),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Text(
                        'Нажмите на день, чтобы отметить или снять месячные',
                        style: TextStyle(color: secondary, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ---------- История ----------
                _sectionTitle('Последние циклы', secondary),
                if (logs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Пока нет записей.\nНажми + или тапни по дню в календаре.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secondary, fontSize: 14),
                    ),
                  )
                else
                  ...logs.take(8).map((log) {
                    return _HistoryTile(
                      log: log,
                      card: card,
                      text: text,
                      secondary: secondary,
                      accent: accent,
                      onDelete: () => _confirmDelete(log, bg, text, secondary),
                    );
                  }),
              ],
            ),
    );
  }

  // ---------- Сетка календаря ----------
  Widget _buildCalendarGrid({
    required Set<int> periodDays,
    required Set<int> fertileDays,
    required DateTime? ovulationDay,
    required Color accent,
    required Color text,
    required Color secondary,
  }) {
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday; // 1=Пн
    final totalCells = (startWeekday - 1) + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final today = DateTime.now();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNumber = cellIndex - (startWeekday - 1) + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 40));
              }

              final date = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                dayNumber,
              );
              final isPeriod = periodDays.contains(dayNumber);
              final isFertile = fertileDays.contains(dayNumber) && !isPeriod;
              final isOvulation = ovulationDay != null &&
                  ovulationDay.year == date.year &&
                  ovulationDay.month == date.month &&
                  ovulationDay.day == date.day;
              final isToday = dayNumber == today.day &&
                  _focusedMonth.month == today.month &&
                  _focusedMonth.year == today.year;
              final isFuture = date.isAfter(today);

              Color? bgColor;
              if (isPeriod) {
                bgColor = _periodColor.withOpacity(0.4);
              } else if (isOvulation) {
                bgColor = _ovulationColor.withOpacity(0.35);
              } else if (isFertile) {
                bgColor = _fertileColor.withOpacity(0.25);
              }

              return Expanded(
                child: GestureDetector(
                  onTap: isFuture
                      ? null
                      : () {
                          ref
                              .read(cycleProvider.notifier)
                              .togglePeriodDay(date);
                        },
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bgColor ?? Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: accent, width: 1.5)
                          : null,
                    ),
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        color: isPeriod
                            ? const Color(0xFFB71C1C)
                            : isOvulation
                                ? const Color(0xFF1B5E20)
                                : isFuture
                                    ? secondary.withOpacity(0.35)
                                    : text.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight:
                            isToday || isPeriod ? FontWeight.w600 : FontWeight.normal,
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

  Widget _legendDot(Color color, String label, Color text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: text.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }

  // ---------- Диалог добавления ----------
  Future<void> _showAddPeriodDialog(
    BuildContext context,
    WidgetRef ref,
    Color bg,
    Color text,
    Color secondary,
    Color accent,
  ) async {
    DateTime selected = DateTime.now();
    int periodLength = 5;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: bg,
              title: Text('Начало месячных', style: TextStyle(color: text)),
              content: SizedBox(
                height: 280,
                width: double.maxFinite,
                child: Column(
                  children: [
                    Expanded(
                      child: CalendarDatePicker(
                        initialDate: selected,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        onDateChanged: (d) => selected = d,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Длительность:', style: TextStyle(color: secondary)),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.remove, color: secondary, size: 20),
                          onPressed: () {
                            if (periodLength > 1) {
                              setDialogState(() => periodLength--);
                            }
                          },
                        ),
                        Text(
                          '$periodLength дн.',
                          style: TextStyle(color: text, fontSize: 15),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: secondary, size: 20),
                          onPressed: () {
                            if (periodLength < 15) {
                              setDialogState(() => periodLength++);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Отмена', style: TextStyle(color: secondary)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, {
                    'date': selected,
                    'length': periodLength,
                  }),
                  child: Text('Сохранить', style: TextStyle(color: accent)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      await ref.read(cycleProvider.notifier).addPeriodStart(
            result['date'] as DateTime,
            periodLength: result['length'] as int,
          );
    }
  }

  Future<void> _confirmDelete(
    CycleLog log,
    Color bg,
    Color text,
    Color secondary,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: bg,
          title: Text('Удалить запись?', style: TextStyle(color: text)),
          content: Text(
            DateFormat('d MMMM yyyy', 'ru').format(log.startDate),
            style: TextStyle(color: secondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Отмена', style: TextStyle(color: secondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Удалить', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      await ref.read(cycleProvider.notifier).deleteLog(log.id);
    }
  }

  Widget _sectionTitle(String label, Color secondary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          color: secondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ======================================================
class _Card extends StatelessWidget {
  final Widget child;
  final Color color;

  const _Card({required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final CycleLog log;
  final Color card;
  final Color text;
  final Color secondary;
  final Color accent;
  final VoidCallback onDelete;

  const _HistoryTile({
    required this.log,
    required this.card,
    required this.text,
    required this.secondary,
    required this.accent,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.water_drop, color: accent.withOpacity(0.7), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('d MMMM yyyy', 'ru').format(log.startDate),
                  style: TextStyle(color: text, fontSize: 15),
                ),
                if (log.periodLength != null || log.cycleLength != null)
                  Text(
                    [
                      if (log.periodLength != null)
                        'месячные ${log.periodLength} дн.',
                      if (log.cycleLength != null)
                        'цикл ${log.cycleLength} дн.',
                    ].join('  ·  '),
                    style: TextStyle(color: secondary, fontSize: 12),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: secondary.withOpacity(0.5), size: 18),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}