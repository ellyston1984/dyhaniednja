import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/app_settings.dart';

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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Настройки',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ========== ТЕМА И ЦВЕТА ==========
          _sectionTitle('Тема и цвета'),
          _card(
            children: [
              _switchTile(
                title: 'Тёмная тема',
                value: settings.isDarkMode,
                accent: accent,
                onChanged: (v) {
                  notifier.updateSettings(settings.copyWith(isDarkMode: v));
                },
              ),
              _divider(),
              _switchTile(
                title: 'Монохромный режим',
                subtitle: 'Убрать цветные акценты',
                value: settings.monochromeMode,
                accent: accent,
                onChanged: (v) {
                  notifier.updateSettings(settings.copyWith(monochromeMode: v));
                },
              ),
              _divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Акцентный цвет',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 15,
                      ),
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
                                  ? Border.all(color: Colors.white, width: 2.5)
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

          // ========== СЕРИИ ==========
          _sectionTitle('Серии'),
          _card(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Режим серии',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    _modeChip(
                      label: 'Строгий',
                      selected: settings.streakMode == 'strict',
                      accent: accent,
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

          // ========== АСТРОЛОГИЯ ==========
          _sectionTitle('Астрология и эзотерика'),
          _card(
            children: [
              _switchTile(
                title: 'Астрология',
                subtitle: 'Фазы Луны и рекомендации',
                value: settings.astrologyEnabled,
                accent: accent,
                onChanged: (v) {
                  notifier.updateSettings(
                    settings.copyWith(astrologyEnabled: v),
                  );
                },
              ),
              if (settings.astrologyEnabled) ...[
                _divider(),
                _switchTile(
                  title: 'Персональная энергия',
                  value: settings.showPersonalEnergy,
                  accent: accent,
                  onChanged: (v) {
                    notifier.updateSettings(
                      settings.copyWith(showPersonalEnergy: v),
                    );
                  },
                ),
                _divider(),
                _switchTile(
                  title: 'Управитель дня',
                  value: settings.showDayRuler,
                  accent: accent,
                  onChanged: (v) {
                    notifier.updateSettings(
                      settings.copyWith(showDayRuler: v),
                    );
                  },
                ),
                _divider(),
                _switchTile(
                  title: 'Аффирмации',
                  value: settings.showAffirmation,
                  accent: accent,
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

          // ========== ЖЕНСКИЕ ФУНКЦИИ ==========
          _sectionTitle('Женские функции'),
          _card(
            children: [
              _switchTile(
                title: 'Женские функции',
                subtitle: 'Цикл, ребёнок и др.',
                value: settings.womenFeaturesEnabled,
                accent: accent,
                onChanged: (v) {
                  notifier.updateSettings(
                    settings.copyWith(womenFeaturesEnabled: v),
                  );
                },
              ),
              if (settings.womenFeaturesEnabled) ...[
                _divider(),
                _switchTile(
                  title: 'Менструальный цикл',
                  value: settings.cycleTrackingEnabled,
                  accent: accent,
                  onChanged: (v) {
                    notifier.updateSettings(
                      settings.copyWith(cycleTrackingEnabled: v),
                    );
                  },
                ),
                _divider(),
                _switchTile(
                  title: 'Привычки ребёнка',
                  value: settings.childHabitsEnabled,
                  accent: accent,
                  onChanged: (v) {
                    notifier.updateSettings(
                      settings.copyWith(childHabitsEnabled: v),
                    );
                  },
                ),
                _divider(),
                _stubTile('Беременность', 'Скоро'),
              ],
            ],
          ),

          const SizedBox(height: 20),

          // ========== УМНЫЕ ПОДСКАЗКИ ==========
          _sectionTitle('Умные подсказки'),
          _card(
            children: [
              _switchTile(
                title: 'Smart Insights',
                subtitle: 'Анализ на основе вашей истории',
                value: settings.smartInsightsEnabled,
                accent: accent,
                onChanged: (v) {
                  notifier.updateSettings(
                    settings.copyWith(smartInsightsEnabled: v),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ========== СКОРО ==========
          _sectionTitle('Скоро'),
          _card(
            children: [
              _stubTile('Виджеты', 'Скоро'),
              _divider(),
              _stubTile('Уведомления', 'Скоро'),
              _divider(),
              _stubTile('Голосовой ввод', 'Скоро'),
              _divider(),
              _stubTile('Health интеграция', 'Скоро'),
              _divider(),
              _stubTile('Привычки-цепочки', 'Скоро'),
            ],
          ),

          const SizedBox(height: 20),

          // ========== ССЫЛКИ ==========
          _sectionTitle('Ссылки'),
          _card(
            children: [
              _linkTile(
                title: 'Нейросети',
                subtitle: 'Заглушка',
                onTap: () {
                  // TODO: открыть заглушку нейросетей
                },
              ),
              _divider(),
              _linkTile(
                title: 'Мессенджер Дыхание',
                subtitle: 'dyhanie.su',
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
              style: TextStyle(
                color: Colors.white.withOpacity(0.25),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- вспомогательные виджеты ----------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.white.withOpacity(0.06),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _switchTile({
    required String title,
    String? subtitle,
    required bool value,
    required Color accent,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            )
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? accent : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _stubTile(String title, String badge) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontSize: 15,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          badge,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _linkTile({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.white.withOpacity(0.3),
      ),
      onTap: onTap,
    );
  }
}
