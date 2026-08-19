import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/theme_provider.dart';

/// Универсальный экран-заглушка
class StubScreen extends ConsumerWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const StubScreen({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.hourglass_empty,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentColorProvider);

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
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.12),
                ),
                child: Icon(icon, size: 40, color: accent),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 15,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Скоро',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ),
              if (buttonText != null && onButtonPressed != null) ...[
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(buttonText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// Конкретные заглушки
// ======================================================

class NeuralNetworkStubScreen extends StatelessWidget {
  const NeuralNetworkStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StubScreen(
      title: 'Нейросети',
      description:
          'Здесь можно будет задавать вопросы\nо привычках, цикле и астрологии.',
      icon: Icons.auto_awesome,
    );
  }
}

class MessengerStubScreen extends StatelessWidget {
  const MessengerStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StubScreen(
      title: 'Мессенджер Дыхание',
      description: 'Эфемерный P2P-мессенджер\nиз экосистемы Дыхание.',
      icon: Icons.chat_bubble_outline,
      buttonText: 'Открыть dyhanie.su',
      onButtonPressed: () async {
        final uri = Uri.parse('https://dyhanie.su');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}

class WidgetsStubScreen extends StatelessWidget {
  const WidgetsStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StubScreen(
      title: 'Виджеты',
      description: 'Виджеты для главного экрана\nпоявится в следующих версиях.',
      icon: Icons.widgets_outlined,
    );
  }
}

class NotificationsStubScreen extends StatelessWidget {
  const NotificationsStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StubScreen(
      title: 'Уведомления',
      description: 'Напоминания о привычках\nбудут добавлены позже.',
      icon: Icons.notifications_none,
    );
  }
}

class VoiceInputStubScreen extends StatelessWidget {
  const VoiceInputStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StubScreen(
      title: 'Голосовой ввод',
      description: 'Отмечать привычки голосом\nпоявится в будущих обновлениях.',
      icon: Icons.mic_none,
    );
  }
}

class HealthStubScreen extends StatelessWidget {
  const HealthStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StubScreen(
      title: 'Health интеграция',
      description: 'Синхронизация с HealthKit\nи Health Connect появится позже.',
      icon: Icons.favorite_border,
    );
  }
}

class HabitStackingStubScreen extends StatelessWidget {
  const HabitStackingStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StubScreen(
      title: 'Привычки-цепочки',
      description: 'Habit Stacking — связывание\nпривычек друг с другом.',
      icon: Icons.link,
    );
  }
}

class PregnancyStubScreen extends StatelessWidget {
  const PregnancyStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StubScreen(
      title: 'Беременность',
      description: 'Режим отслеживания беременности\nпоявится в следующих версиях.',
      icon: Icons.pregnant_woman_outlined,
    );
  }
}