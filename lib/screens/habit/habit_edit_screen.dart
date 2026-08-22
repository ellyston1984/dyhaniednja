import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/habit.dart';
import '../../providers/habits_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/theme_provider.dart';

class HabitEditScreen extends ConsumerStatefulWidget {
  final Habit? habit;

  const HabitEditScreen({super.key, this.habit});

  @override
  ConsumerState<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends ConsumerState<HabitEditScreen> {
  final _titleController = TextEditingController();
  final _uuid = const Uuid();

  late int _selectedColor;
  late String _selectedCategoryId;
  late List<int> _selectedDays;
  late int _targetCount;

  final List<int> _presetColors = [
    0xFF4A9B9B,
    0xFF7C9A72,
    0xFFD4A373,
    0xFFC77DFF,
    0xFFFF6B6B,
    0xFF4D96FF,
    0xFFFFB347,
    0xFF95D5B2,
  ];

  final List<String> _weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    if (h != null) {
      _titleController.text = h.title;
      _selectedColor = h.colorValue;
      _selectedCategoryId = h.categoryId;
      _selectedDays = List.from(h.daysOfWeek);
      _targetCount = h.targetCount;
    } else {
      _selectedColor = _presetColors[0];
      _selectedCategoryId = 'health';
      _selectedDays = [1, 2, 3, 4, 5, 6, 7];
      _targetCount = 1;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название привычки')),
      );
      return;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите хотя бы один день')),
      );
      return;
    }

    final habitsNotifier = ref.read(habitsProvider.notifier);

    if (widget.habit == null) {
      final newHabit = Habit(
        id: _uuid.v4(),
        title: title,
        colorValue: _selectedColor,
        categoryId: _selectedCategoryId,
        daysOfWeek: _selectedDays,
        targetCount: _targetCount,
        order: ref.read(habitsProvider).habits.length,
      );
      await habitsNotifier.addHabit(newHabit);
    } else {
      final updated = Habit(
        id: widget.habit!.id,
        title: title,
        colorValue: _selectedColor,
        categoryId: _selectedCategoryId,
        daysOfWeek: _selectedDays,
        targetCount: _targetCount,
        order: widget.habit!.order,
        createdAt: widget.habit!.createdAt,
      );
      await habitsNotifier.updateHabit(updated);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (widget.habit == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final bg = ref.read(backgroundColorProvider);
        final text = ref.read(textColorProvider);
        final secondary = ref.read(secondaryTextColorProvider);

        return AlertDialog(
          backgroundColor: bg,
          title: Text('Удалить привычку?', style: TextStyle(color: text)),
          content: Text(
            'Это действие нельзя отменить',
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

    if (confirm == true) {
      await ref.read(habitsProvider.notifier).deleteHabit(widget.habit!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(accentColorProvider);
    final categories = ref.watch(categoriesProvider);
    final isEdit = widget.habit != null;

    final bg = ref.watch(backgroundColorProvider);
    final text = ref.watch(textColorProvider);
    final secondary = ref.watch(secondaryTextColorProvider);
    final card = ref.watch(cardColorProvider);

    if (categories.isNotEmpty &&
        !categories.any((c) => c.id == _selectedCategoryId)) {
      _selectedCategoryId = categories.first.id;
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Редактировать' : 'Новая привычка',
          style: TextStyle(color: text, fontSize: 18),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _sectionTitle('Название', secondary),
          TextField(
            controller: _titleController,
            style: TextStyle(color: text, fontSize: 16),
            cursorColor: accent,
            decoration: InputDecoration(
              hintText: 'Например: Пить воду',
              hintStyle: TextStyle(color: secondary),
              filled: true,
              fillColor: card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 28),

          _sectionTitle('Цвет', secondary),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _presetColors.map((c) {
              final selected = c == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: text, width: 3)
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          _sectionTitle('Категория', secondary),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: categories.isEmpty ? null : _selectedCategoryId,
                isExpanded: true,
                dropdownColor: card,
                style: TextStyle(color: text, fontSize: 16),
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategoryId = v);
                },
              ),
            ),
          ),

          const SizedBox(height: 28),

          _sectionTitle('Дни недели', secondary),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = i + 1;
              final selected = _selectedDays.contains(day);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedDays.remove(day);
                    } else {
                      _selectedDays.add(day);
                    }
                    _selectedDays.sort();
                  });
                },
                child: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? accent : card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _weekDays[i],
                    style: TextStyle(
                      color: selected ? Colors.black : text.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 28),

          _sectionTitle('Сколько раз в день', secondary),
          Row(
            children: [
              _roundButton(
                icon: Icons.remove,
                card: card,
                text: text,
                onTap: () {
                  if (_targetCount > 1) setState(() => _targetCount--);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '$_targetCount',
                  style: TextStyle(
                    color: text,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _roundButton(
                icon: Icons.add,
                card: card,
                text: text,
                onTap: () {
                  if (_targetCount < 50) setState(() => _targetCount++);
                },
              ),
            ],
          ),

          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                isEdit ? 'Сохранить' : 'Создать привычку',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _roundButton({
    required IconData icon,
    required Color card,
    required Color text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: card,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: text.withOpacity(0.7), size: 22),
      ),
    );
  }
}