import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/habit.dart';
import '../../models/category.dart';
import '../../providers/habits_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/theme_provider.dart';

class HabitEditScreen extends ConsumerStatefulWidget {
  final Habit? habit; // null = создание новой

  const HabitEditScreen({super.key, this.habit});

  @override
  ConsumerState<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends ConsumerState<HabitEditScreen> {
  final _titleController = TextEditingController();
  final _uuid = const Uuid();

  late int _selectedColor;
  late String _selectedCategoryId;
  late List<int> _selectedDays; // 1=Пн ... 7=Вс
  late int _targetCount;

  final List<int> _presetColors = [
    0xFF4A9B9B, // бирюзовый
    0xFF7C9A72, // зелёный
    0xFFD4A373, // песочный
    0xFFC77DFF, // фиолетовый
    0xFFFF6B6B, // красный
    0xFF4D96FF, // синий
    0xFFFFB347, // оранжевый
    0xFF95D5B2, // мятный
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
      _selectedCategoryId = 'health'; // будет из категорий
      _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // все дни
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
      // Создание
      final newHabit = Habit(
        id: _uuid.v4(),
        title: title,
        colorValue: _selectedColor,
        categoryId: _selectedCategoryId,
        daysOfWeek: _selectedDays,
        targetCount: _targetCount,
        order: ref.read(habitsProvider).length,
      );
      await habitsNotifier.addHabit(newHabit);
    } else {
      // Редактирование
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
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1E),
        title: const Text('Удалить привычку?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Это действие нельзя отменить',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
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

    // Если категорий ещё нет — подставляем дефолтную
    if (categories.isNotEmpty && 
        !categories.any((c) => c.id == _selectedCategoryId)) {
      _selectedCategoryId = categories.first.id;
    }

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
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Редактировать' : 'Новая привычка',
          style: const TextStyle(color: Colors.white, fontSize: 18),
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
          // ----- Название -----
          _sectionTitle('Название'),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            cursorColor: accent,
            decoration: InputDecoration(
              hintText: 'Например: Пить воду',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 28),

          // ----- Цвет -----
          _sectionTitle('Цвет'),
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
                        ? Border.all(color: Colors.white, width: 3)
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

          // ----- Категория -----
          _sectionTitle('Категория'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: categories.isEmpty ? null : _selectedCategoryId,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A1A1E),
                style: const TextStyle(color: Colors.white, fontSize: 16),
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

          // ----- Дни недели -----
          _sectionTitle('Дни недели'),
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
                    color: selected ? accent : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _weekDays[i],
                    style: TextStyle(
                      color: selected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 28),

          // ----- Цель в день -----
          _sectionTitle('Сколько раз в день'),
          Row(
            children: [
              _roundButton(
                icon: Icons.remove,
                onTap: () {
                  if (_targetCount > 1) {
                    setState(() => _targetCount--);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '$_targetCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _roundButton(
                icon: Icons.add,
                onTap: () {
                  if (_targetCount < 50) {
                    setState(() => _targetCount++);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 48),

          // ----- Кнопка сохранить -----
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

  Widget _roundButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
    );
  }
}