import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';

final categoriesProvider = Provider<List<Category>>((ref) {
  return [
    Category(id: 'health', name: 'Здоровье', isCustom: false),
    Category(id: 'sport', name: 'Спорт', isCustom: false),
    Category(id: 'mind', name: 'Разум', isCustom: false),
    Category(id: 'home', name: 'Дом', isCustom: false),
    Category(id: 'work', name: 'Работа', isCustom: false),
    Category(id: 'other', name: 'Другое', isCustom: false),
  ];
});