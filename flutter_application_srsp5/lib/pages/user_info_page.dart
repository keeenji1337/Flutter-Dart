// ==================== СТРАНИЦА ИНФОРМАЦИИ О ПОЛЬЗОВАТЕЛЕ ====================
// Показывает данные, сохранённые при регистрации.

import 'package:flutter/material.dart';                         // Базовые виджеты + Material-дизайн
import '../services/shared_prefs_service.dart';                 // Сервис чтения из хранилища (модуль 2)

// StatefulWidget — потому что данные приходят асинхронно и меняются после setState.
class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});                              // const-конструктор + короткая передача key

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();    // Фреймворк сам вызывает это, чтобы получить объект состояния
}

// Отдельный класс State — здесь живут изменяемые поля и логика.
// _ подчёркивание = приватный, доступен только внутри этого файла.
class _UserInfoPageState extends State<UserInfoPage> {
  String _name = '';                                            // Поля с _ — приватные; '' вместо null, чтобы Text не падал
  String _phone = '';
  String _email = '';
  String _lifeStory = '';

  @override
  void initState() {                                            // initState вызывается ОДИН раз — при вставке виджета в дерево
    super.initState();                                          // Обязательно: запускает внутреннюю инициализацию State
    _loadData();                                                // Запускаем загрузку — нельзя await здесь, initState синхронный
  }

  Future<void> _loadData() async {                              // Future<void> — асинхронная, ничего не возвращает
    final data = await SharedPrefsService.getUserData();        // Ждём ответ от сервиса (Map<String, String?>)

    setState(() {                                               // setState перестраивает build с новыми значениями
      _name = data['name'] ?? 'Нет данных';                     // ?? — если значение null, подставляем заглушку
      _phone = data['phone'] ?? 'Нет данных';
      _email = data['email'] ?? 'Нет данных';
      _lifeStory = data['lifeStory'] ?? 'Нет данных';
    });
  }

  @override
  Widget build(BuildContext context) {                          // build вызывается заново после каждого setState
    return Scaffold(                                            // Scaffold — каркас экрана: AppBar + body + FAB и т.д.
      appBar: AppBar(
        title: const Text('User Info'),                         // const — текст неизменяем, экономим память
        centerTitle: true,                                      // По умолчанию на Android заголовок слева, здесь — по центру
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),                    // EdgeInsets.all — одинаковый отступ со всех сторон
        child: Column(                                          // Column — вертикальный список детей
          crossAxisAlignment: CrossAxisAlignment.start,         // start = выравнивание по левому краю (не по центру)
          children: [
            Text('Имя: $_name', style: const TextStyle(fontSize: 18)),      // $_name — интерполяция строки
            const SizedBox(height: 10),                                    // SizedBox — невидимый «зазор» фиксированного размера
            Text('Телефон: $_phone', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Email: $_email', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('История: $_lifeStory', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}