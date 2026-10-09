import 'package:flutter/material.dart';                  // Material Design: базовые UI-компоненты
import 'package:flutter_application_srs6/post/view/post_page.dart'; // Импорт стартового экрана приложения

void main() {                                            // Точка входа в Dart-приложение
  runApp(const MyApp());                                 // Запуск Flutter: создает корневой виджет и запускает движок
}

class MyApp extends StatefulWidget {                     // Корневой виджет (StatefulWidget, чтобы можно было менять глобальное состояние, например тему)
  const MyApp({super.key});                              // Конструктор с ключом (для идентификации в дереве)

  @override                                              // Создание объекта состояния
  State<MyApp> createState() => _MyAppState();           // Возвращаем класс состояния _MyAppState
}

class _MyAppState extends State<MyApp> {                 // Состояние корневого виджета
  @override                                              // Построение интерфейса
  Widget build(BuildContext context) {
    return MaterialApp(                                  // Корневой виджет Material: настраивает тему, маршрутизацию и заголовок
      title: 'Post Page',                                // Заголовок приложения (отображается в переключателе задач ОС)
      theme: ThemeData(                                  // Настройки глобальной темы
        primarySwatch: Colors.blue,                      // Основной цвет приложения (синий)
      ),
      home: const PostPage(),                            // Стартовый экран (открывается при запуске приложения)
    );
  }
}