// ==================== ГЛАВНЫЙ ФАЙЛ ПРИЛОЖЕНИЯ ====================
// Точка входа. Здесь стартует Flutter и строится корневой виджет MyApp.

import 'package:flutter/material.dart';                         // material.dart — зонтик над widgets.dart + Material-дизайн
import 'pages/registration_page.dart';                          // Своя страница регистрации (модуль 1)

void main() {                                                   // main — зарезервированное имя, его Dart вызывает сам
  runApp(const MyApp());                                        // runApp создаёт WidgetsBinding, цепляет дерево к экрану и запускает кадры
}

class MyApp extends StatelessWidget {                           // StatelessWidget — состояние не меняется, setState не нужен
  const MyApp({super.key});                                     // const-конструктор + super.key = короткая передача key родителю

  @override                                                     // @override — переопределяю build у StatelessWidget
  Widget build(BuildContext context) {                          // build возвращает описание UI, context — ссылка на место в дереве
    return MaterialApp(                                         // MaterialApp — контейнер: навигация, тема, локализация, оверлеи
      title: 'Flutter Registration Form',                       // Имя приложения для ОС, НЕ заголовок AppBar
      debugShowCheckedModeBanner: false,                        // Убираем красный баннер "DEBUG" в углу (косметика)
      theme: ThemeData(
        primarySwatch: Colors.blue,                             // primarySwatch — палитра из 10 оттенков, не один цвет
      ),
      home: const RegistrationPage(),                           // home — стартовый экран, эквивалент routes: {'/': ...}
    );
  }
}