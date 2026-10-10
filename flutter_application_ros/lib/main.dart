import 'package:flutter/material.dart';                          // Material Design: базовые UI-компоненты
import 'package:flutter_bloc/flutter_bloc.dart';                 // flutter_bloc: провайдер BLoC для всего приложения

import 'bloc/app_bloc.dart';                                     // Импорт нашего BLoC

import 'screens/home_screen.dart';                               // Главное меню
import 'screens/widgets_demo.dart';                              // Демо: виджеты значения
import 'screens/layout_demo.dart';                               // Демо: вёрстка
import 'screens/navigation_demo.dart';                           // Демо: навигация
import 'screens/dialogs_demo.dart';                              // Демо: диалоги и уведомления
import 'screens/gestures_demo.dart';                             // Демо: жесты и кнопки
import 'screens/state_demo.dart';                                // Демо: состояние (setState)
import 'screens/bloc_demo.dart';                                 // Демо: BLoC
import 'screens/inherited_demo.dart';                            // Демо: InheritedWidget
import 'screens/hooks_demo.dart';                                // Демо: Hooks
import 'screens/redux_demo.dart';                                // Демо: Redux

void main() {                                                    // Точка входа в Dart-приложение
  runApp(const MyApp());                                         // Запуск Flutter: создаёт корневой виджет
}

class MyApp extends StatelessWidget {                            // Корневой виджет приложения
  const MyApp({super.key});                                      // Конструктор с ключом

  @override                                                      // Построение интерфейса
  Widget build(BuildContext context) {
    return BlocProvider(                                         // Провайдер BLoC: делает AppBloc доступным всему дереву
      create: (context) => AppBloc(),                            // Создание экземпляра AppBloc
      child: MaterialApp(                                        // Корневой Material-виджет: тема, маршруты, заголовок
        title: 'Flutter Showcase',                               // Заголовок приложения (в переключателе задач ОС)
        theme: ThemeData(                                        // Настройки глобальной темы
          primarySwatch: Colors.blue,                          // Основной цвет приложения (синий)
          visualDensity: VisualDensity.adaptivePlatformDensity,  // Плотность UI под платформу
        ),
        initialRoute: '/',                                       // Стартовый маршрут при запуске
        routes: {                                                // Таблица маршрутов: имя → билдер экрана
          '/': (context) => const HomeScreen(),                  // Главное меню
          '/widgets_demo': (context) => const WidgetsDemoScreen(),      // Виджеты значения
          '/layout_demo': (context) => const LayoutDemoScreen(),        // Вёрстка
          '/navigation_demo': (context) => const NavigationDemoScreen(),// Навигация
          '/dialogs_demo': (context) => const DialogsDemoScreen(),      // Диалоги
          '/gestures_demo': (context) => const GesturesDemoScreen(),    // Жесты
          '/state_demo': (context) => const StateDemoScreen(),          // Состояние
          '/bloc_demo': (context) => const BlocDemoScreen(),            // BLoC
          '/inherited_demo': (context) => const InheritedDemoScreen(),  // InheritedWidget
          '/hooks_demo': (context) => const HooksDemoScreen(),          // Hooks
          '/redux_demo': (context) => ReduxDemoScreen(),                // Redux
          '/result_screen': (context) => const ResultScreen(),          // Возврат результата из навигации
        },
      ),
    );
  }
}