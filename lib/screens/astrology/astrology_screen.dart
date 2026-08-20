import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/astrology_provider.dart';
import '../../providers/theme_provider.dart';

class AstrologyScreen extends ConsumerWidget {
  const AstrologyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentColorProvider);
    final bg = ref.watch(backgroundColorProvider);
    final text = ref.watch(textColorProvider);
    final secondary = ref.watch(secondaryTextColorProvider);
    final card = ref.watch(cardColorProvider);
    final async = ref.watch(dailyAstrologyProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: secondary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Луна и день', style: TextStyle(color: text, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accent),
            tooltip: 'Обновить с сервера',
            onPressed: () => ref.read(dailyAstrologyProvider.notifier).refresh(),
          ),
        ],
      ),
      body: async.when(
        loading: () => Center(child: CircularProgressIndicator(color: accent)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Не удалось загрузить', style: TextStyle(color: text)),
                const SizedBox(height: 8),
                Text('$e', style: TextStyle(color: secondary, fontSize: 12)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(dailyAstrologyProvider.notifier).refresh(),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
        data: (astro) {
          final updated = astro.updatedAt != null
              ? DateFormat('d MMM, HH:mm', 'ru').format(astro.updatedAt!)
              : '—';
          final sourceLabel =
              astro.source == 'farmsense' ? 'Farmsense API' : 'Локальный расчёт';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              _Card(
                color: card,
                child: Column(
                  children: [
                    Icon(Icons.nightlight_round, size: 48, color: accent),
                    const SizedBox(height: 12),
                    Text(
                      astro.moonPhase,
                      style: TextStyle(
                        color: text,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Освещённость: ${(astro.moonIllumination * 100).round()}%',
                      style: TextStyle(color: secondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Card(
                color: card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('Управитель дня', astro.dayRuler, text, secondary),
                    const SizedBox(height: 10),
                    _row('Энергия', '${astro.energyLevel} · ${astro.personalEnergyPercent}%', text, secondary),
                    const SizedBox(height: 10),
                    Text('Совет дня', style: TextStyle(color: secondary, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(astro.shortAdvice, style: TextStyle(color: text, fontSize: 15, height: 1.35)),
                    if (astro.affirmation.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        '«${astro.affirmation}»',
                        style: TextStyle(
                          color: secondary,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Card(
                color: card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Данные', style: TextStyle(color: secondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    _row('Источник', sourceLabel, text, secondary),
                    const SizedBox(height: 8),
                    _row('Обновлено', updated, text, secondary),
                    const SizedBox(height: 12),
                    Text(
                      'Обновление берёт фазу Луны с публичного API Farmsense. '
                      'Без сети используется локальный расчёт.',
                      style: TextStyle(color: secondary, fontSize: 12, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, Color text, Color secondary) {
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(color: secondary, fontSize: 13))),
        Text(value, style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

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