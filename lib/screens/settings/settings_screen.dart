import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = ref.watch(accentColorProvider);
    final notifier = ref.read(settingsProvider.notifier);

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
          icon: Icon(Icons.arrow_back_ios_new, color: secondary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Настройки',
          style: TextStyle(color: text, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _sectionTitle('Тема и цвета', secondary),
          _card(
            card,
            children: [
              _switchTile(
                title: 'Тёмная тема',
                value: settings.isDarkMode,
                accent: accent,
                text: text,
                secondary: secondary,
                onChanged: (v) {
                  notifier.updateSettings(settings.copyWith(isDarkMode: v));
                },
              ),
              _divider(secondary),
              _switchTile(
                title: 'Монохромный режим',
                subtitle: 'Убрать цветные акценты',
                value: settings.monochromeMode,
                accent: accent,
                text: text,
                secondary: secondary,
                onChanged: (v) {
                  notifier.updateSettings(settings.copyWith(monochromeMode: v));
                },
              ),
              _divider(secondary),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Акцентный цвет',
                      style: TextStyle(color: text.withOpacity(0.85), fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        0xFF4A9B9B,
                        0xFF7C9A72,
                        0xFFD4A373,
                        0xFFC77DFF,
                        0xFFFF6B6B,
                        0xFF4D96FF,
                      ].map((c) {
                        final selected = settings.accentColorValue == c;
                        return GestureDetector(
                          onTap: () {
                            notifier.updateSettings(
                              settings.copyWith(accentColorValue: c),
                            );
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: selected
                                  ? Border.all(color: text, width: 2.5)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _sectionTitle('Серии', secondary),
          _card(
            card,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Режим серии',
                        style: TextStyle(color: text.withOpacity(0.85), fontSize: 15),
                      ),
                    ),
                    _modeChip(
                      label: 'Строгий',
                      selected: settings.streakMode == 'strict',
                      accent: accent,
                      text: text,
                      onTap: () {
                        notifier.updateSettings(
                          settings.copyWith(streakMode: 'strict'),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _modeChip(
                      label: 'Мягкий',
                      selected: settings.streakMode == 'soft',
                      accent: accent,
                      text: text,
                      onTap: () {
                        notifier.updateSettings(
                          settings.copyWith(streakMode: 'soft'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _sectionTitle('Астрология и эзотерика', secondary),
          _card(
            card,
            children: [
              _switchTile(
                title: 'Астрология',
                subtitle: 'Фазы Луны и рекомендации',
                value: settings.astrologyEnabled,
                accent: accent,
                text: text,
                secondary: secondary,
                onChanged: (v) {
                  notifier.updateSettings(
                    settings.copyWith(astrologyEnabled: v),
                  );
                },
              ),
              if (settings.astrologyEnabled) ...[
                _divider(secondary),
                _switchTile(
                  title: 'Персональная энергия',
                  value: settings.showPersonalEnergy,
                  accent: accent,
                  text: text,
                  secondary: secondary,
                  onChanged: (v) {
                    notifier.updateSettings(
                      settings.copyWith(showPersonalEnergy: v),
                    );
                  },
                ),
                _divider(secondary),
                _switchTile(
                  title: 'Управитель дня',
                  value: settings.showDayRuler,
                  accent: accent,
                  text: text,
                  secondary: secondary,
                  onChanged: (v) {
                    notifier.updateSettings(
                      settings.copyWith(showDayRuler: v),
                    );
                  },
                ),
                _divider(secondary),
                _switchTile(
                  title: 'Аффирмации',
                  value: settings.showAffirmation,
                  accent: accent,
                  text: text,
                  secondary: secondary,
                  onChanged: (v) {
                    notifier.updateSettings(
                      settings.copyWith(showAffirmation: v),
                    );
                  },
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),

          _sectionTitle('Женские функции', secondary),
          _card(
            card,
            children: [
              _switchTile(
                title: 'Женские функции',
                subtitle: 'Цикл, ребёнок и др.',
                value: settings.womenFeaturesEnabled,
                accent: accent,
                text: text,
                secondary: secondary,
                onChanged: (v) {
                  notifier.updateSettings(
                    settings.copyWith(womenFeaturesEnabled: v),
                  );
                },
              ),
              if (settings.womenFeaturesEnabled) ...[
                _divider(secondary),
                _switchTile(
                  title: 'Менструальный цикл',
                  value: settings.cycleTrackingEnabled,
                  accent: accent,
                  text: text,
                  secondary: secondary,
                  onChanged: (v) {
                    notifier.updateSettings(
                      settings.copyWith(cycleTrackingEnabled: v),
                    );
                  },
                ),
                _divider(secondary),
                _switchTile(
                  title: 'Привычки ребёнка',
                  value: settings.childHabitsEnabled,
                  accent: accent,
                  text: text,
                  secondary: secondary,
                  onChanged: (v) {
                    notifier.updateSettings(
                      settings.copyWith(childHabitsEnabled: v),
                    );
                  },
                ),
                _divider(secondary),
                _stubTile('Беременность', 'Скоро', text, secondary),
              ],
            ],
          ),

          const SizedBox(height: 20),

          _sectionTitle('Умные подсказки', secondary),
          _card(
            card,
            children: [
              _switchTile(
                title: 'Smart Insights',
                subtitle: 'Анализ на основе вашей истории',
                value: settings.smartInsightsEnabled,
                accent: accent,
                text: text,
                secondary: secondary,
                onChanged: (v) {
                  notifier.updateSettings(
                    settings.copyWith(smartInsightsEnabled: v),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          _sectionTitle('Скоро', secondary),
          _card(
            card,
            children: [
              _stubTile('Виджеты', 'Скоро', text, secondary),
              _divider(secondary),
              _stubTile('Уведомления', 'Скоро', text, secondary),
              _divider(secondary),
              _stubTile('Голосовой ввод', 'Скоро', text, secondary),
              _divider(secondary),
              _stubTile('Health интеграция', 'Скоро', text, secondary),
              _divider(secondary),
              _stubTile('Привычки-цепочки', 'Скоро', text, secondary),
            ],
          ),

          const SizedBox(height: 20),

          _sectionTitle('Ссылки', secondary),
          _card(
            card,
            children: [
              _linkTile(
                title: 'Нейросети',
                subtitle: 'Заглушка',
                text: text,
                secondary: secondary,
                onTap: () {},
              ),
              _divider(secondary),
              _linkTile(
                title: 'Мессенджер Дыхание',
                subtitle: 'dyhanie.su',
                text: text,
                secondary: secondary,
                onTap: () async {
                  final uri = Uri.parse('https://dyhanie.su');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'Дыхание дня  v1.0.0-dev',
              style: TextStyle(color: secondary.withOpacity(0.6), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, Color secondary) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: secondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _card(Color cardColor, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (cardColor == Colors.white)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(Color secondary) {
    return Divider(
      height: 1,
      color: secondary.withOpacity(0.15),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _switchTile({
    required String title,
    String? subtitle,
    required bool value,
    required Color accent,
    required Color text,
    required Color secondary,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(color: text, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: secondary, fontSize: 12))
          : null,
      value: value,
      activeColor: accent,
      onChanged: onChanged,
    );
  }

  Widget _modeChip({
    required String label,
    required bool selected,
    required Color accent,
    required Color text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? accent : text.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : text.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _stubTile(String title, String badge, Color text, Color secondary) {
    return ListTile(
      title: Text(title, style: TextStyle(color: secondary, fontSize: 15)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: text.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(badge, style: TextStyle(color: secondary, fontSize: 11)),
      ),
    );
  }

  Widget _linkTile({
    required String title,
    String? subtitle,
    required Color text,
    required Color secondary,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(color: text, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: secondary, fontSize: 12))
          : null,
      trailing: Icon(Icons.chevron_right, color: secondary),
      onTap: onTap,
    );
  }
}