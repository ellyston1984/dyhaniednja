import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/child_profile.dart';
import '../../models/habit.dart';
import '../../providers/settings_provider.dart';
import '../../providers/child_habits_provider.dart';
import '../../providers/theme_provider.dart';
import '../habit/habit_edit_screen.dart';

class ChildHabitsScreen extends ConsumerWidget {
  const ChildHabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = ref.watch(accentColorProvider);
    final childState = ref.watch(childHabitsProvider);

    final bg = ref.watch(backgroundColorProvider);
    final text = ref.watch(textColorProvider);
    final secondary = ref.watch(secondaryTextColorProvider);
    final card = ref.watch(cardColorProvider);

    if (!settings.womenFeaturesEnabled || !settings.childHabitsEnabled) {
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
            'Привычки ребёнка',
            style: TextStyle(color: text, fontSize: 18),
          ),
        ),
        body: Center(
          child: Text(
            'Функция выключена в настройках',
            style: TextStyle(color: secondary, fontSize: 16),
          ),
        ),
      );
    }

    final profiles = childState.profiles;
    final selectedProfile = childState.selectedProfile;
    final habits = childState.habitsForSelected;

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
          'Привычки ребёнка',
          style: TextStyle(color: text, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1, color: accent),
            onPressed: () => _showAddChildDialog(
              context,
              ref,
              bg,
              text,
              secondary,
              card,
              accent,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (profiles.isNotEmpty)
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: profiles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  final isSelected = selectedProfile?.id == profile.id;

                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(childHabitsProvider.notifier)
                          .selectProfile(profile.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accent.withOpacity(0.25)
                            : card,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? Border.all(color: accent, width: 1.5)
                            : null,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Color(
                              int.tryParse(profile.avatarColor ?? '0xFF4A9B9B') ??
                                  0xFF4A9B9B,
                            ),
                            child: Text(
                              profile.name.isNotEmpty
                                  ? profile.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            profile.name,
                            style: TextStyle(
                              color: isSelected ? accent : text.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 12),

          Expanded(
            child: profiles.isEmpty
                ? _EmptyProfiles(
                    accent: accent,
                    text: text,
                    secondary: secondary,
                    onAdd: () => _showAddChildDialog(
                      context,
                      ref,
                      bg,
                      text,
                      secondary,
                      card,
                      accent,
                    ),
                  )
                : habits.isEmpty
                    ? _EmptyHabits(
                        accent: accent,
                        text: text,
                        secondary: secondary,
                        childName: selectedProfile?.name ?? '',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          return _ChildHabitCard(
                            habit: habit,
                            card: card,
                            text: text,
                            onToggle: () {
                              ref
                                  .read(childHabitsProvider.notifier)
                                  .toggleCompletion(habit.id);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: profiles.isEmpty
          ? null
          : FloatingActionButton(
              backgroundColor: accent,
              foregroundColor: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HabitEditScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  Future<void> _showAddChildDialog(
    BuildContext context,
    WidgetRef ref,
    Color bg,
    Color text,
    Color secondary,
    Color card,
    Color accent,
  ) async {
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: bg,
          title: Text('Добавить ребёнка', style: TextStyle(color: text)),
          content: TextField(
            controller: nameController,
            style: TextStyle(color: text),
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Имя',
              hintStyle: TextStyle(color: secondary),
              filled: true,
              fillColor: card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Отмена', style: TextStyle(color: secondary)),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) Navigator.pop(ctx, name);
              },
              child: Text('Добавить', style: TextStyle(color: accent)),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      final profile = ChildProfile(
        id: const Uuid().v4(),
        name: result,
        avatarColor: '0xFF4A9B9B',
        createdAt: DateTime.now(),
      );
      await ref.read(childHabitsProvider.notifier).addProfile(profile);
    }
  }
}

class _ChildHabitCard extends StatelessWidget {
  final Habit habit;
  final Color card;
  final Color text;
  final VoidCallback onToggle;

  const _ChildHabitCard({
    required this.habit,
    required this.card,
    required this.text,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
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
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.7), width: 2),
              ),
              child: Icon(Icons.check, size: 16, color: color.withOpacity(0)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProfiles extends StatelessWidget {
  final Color accent;
  final Color text;
  final Color secondary;
  final VoidCallback onAdd;

  const _EmptyProfiles({
    required this.accent,
    required this.text,
    required this.secondary,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 64, color: accent.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Добавьте ребёнка',
              style: TextStyle(color: text, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Чтобы отслеживать его привычки',
              style: TextStyle(color: secondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHabits extends StatelessWidget {
  final Color accent;
  final Color text;
  final Color secondary;
  final String childName;

  const _EmptyHabits({
    required this.accent,
    required this.text,
    required this.secondary,
    required this.childName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_task, size: 56, color: accent.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Нет привычек у $childName',
              style: TextStyle(color: text, fontSize: 17),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Нажмите + чтобы добавить',
              style: TextStyle(color: secondary),
            ),
          ],
        ),
      ),
    );
  }
}