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

    // Если функция выключена
    if (!settings.womenFeaturesEnabled || !settings.childHabitsEnabled) {
     
    final bg = ref.watch(backgroundColorProvider);
    final text = ref.watch(textColorProvider);
    final secondary = ref.watch(secondaryTextColorProvider);
    final card = ref.watch(cardColorProvider);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Привычки ребёнка',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        body: const Center(
          child: Text(
            'Функция выключена в настройках',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    }

    final profiles = childState.profiles;
    final selectedProfile = childState.selectedProfile;
    final habits = childState.habitsForSelected;

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
          'Привычки ребёнка',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1, color: accent),
            onPressed: () => _showAddChildDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // ---------- Список профилей детей ----------
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
                      ref.read(childHabitsProvider.notifier).selectProfile(profile.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accent.withOpacity(0.25)
                            : Colors.white.withOpacity(0.06),
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
                              int.tryParse(profile.avatarColor ?? '0xFF4A9B9B') ?? 0xFF4A9B9B,
                            ),
                            child: Text(
                              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
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
                              color: isSelected ? accent : Colors.white70,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

          // ---------- Список привычек ----------
          Expanded(
            child: profiles.isEmpty
                ? _EmptyProfiles(accent: accent, onAdd: () => _showAddChildDialog(context, ref))
                : habits.isEmpty
                    ? _EmptyHabits(
                        accent: accent,
                        childName: selectedProfile?.name ?? '',
                        onAdd: () {
                          if (selectedProfile == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HabitEditScreen(
                                // Можно позже передать childProfileId
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          return _ChildHabitCard(
                            habit: habit,
                            accent: accent,
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
                if (selectedProfile == null) return;
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

  Future<void> _showAddChildDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1E),
          title: const Text(
            'Добавить ребёнка',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Имя',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) Navigator.pop(ctx, name);
              },
              child: const Text('Добавить'),
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

// ======================================================
// Виджеты
// ======================================================

class _ChildHabitCard extends StatelessWidget {
  final Habit habit;
  final Color accent;
  final VoidCallback onToggle;

  const _ChildHabitCard({
    required this.habit,
    required this.accent,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
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
              style: const TextStyle(
                color: Colors.white,
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
  final VoidCallback onAdd;

  const _EmptyProfiles({required this.accent, required this.onAdd});

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
            const Text(
              'Добавьте ребёнка',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Чтобы отслеживать его привычки',
              style: TextStyle(color: Colors.white.withOpacity(0.4)),
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
  final String childName;
  final VoidCallback onAdd;

  const _EmptyHabits({
    required this.accent,
    required this.childName,
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
            Icon(Icons.add_task, size: 56, color: accent.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Нет привычек у $childName',
              style: const TextStyle(color: Colors.white, fontSize: 17),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Нажмите + чтобы добавить',
              style: TextStyle(color: Colors.white.withOpacity(0.4)),
            ),
          ],
        ),
      ),
    );
  }
}