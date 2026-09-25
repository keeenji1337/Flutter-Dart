import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/theme_manager.dart';
import 'widgets/bottom_bar.dart';

// Глобальный экземпляр менеджера тем, чтобы к нему можно было обратиться из любого места (для переключения темы)
final themeManager = ThemeManager();

// ==================== ТОЧКА ВХОДА ====================
void main() async {
  // Гарантируем, что движок Flutter инициализирован до вызова асинхронных методов
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализируем EasyLocalization (чтение локализаций)
  await EasyLocalization.ensureInitialized();

  // Запускаем приложение, обернув его в провайдер локализации
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ru'), Locale('en'), Locale('kk')], // Поддерживаемые языки: Русский, Английский, Казахский
      path: 'assets/translations',                          // Путь к файлам с переводами
      fallbackLocale: const Locale('ru'),                   // Язык по умолчанию, если системный не найден
      // MyApp - корневой виджет нашего приложения
      child: const MyApp(),
    ),
  );
}

// ==================== КОРНЕВОЙ ВИДЖЕТ ПРИЛОЖЕНИЯ ====================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder слушает изменения в themeManager (при переключении темы будет перерисовывать приложение)
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, child) {
        // ScreenUtilInit - инициализация пакета flutter_screenutil для адаптивного дизайна
        return ScreenUtilInit(
          // Базовый размер дизайна (обычно берется из макета Figma, например 360x690 для стандартного телефона)
          designSize: const Size(360, 690),
          minTextAdapt: true,                               // Минимальная адаптация текста включена
          splitScreenMode: true,                            // Поддержка режима разделенного экрана
          builder: (context, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,            // Убирает красную ленточку "DEBUG" в правом верхнем углу
              title: 'Лабораторная работа №3',              // Название приложения
              
              // Настройки локализации
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,                       // Текущий выбранный язык
              
              // Настройки тем (берем из нашего themeManager)
              theme: ThemeManager.lightTheme,               // Светлая тема
              darkTheme: ThemeManager.darkTheme,            // Тёмная тема
              themeMode: themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light, // Какой режим включен сейчас
              
              // Главный экран, который будет отображаться при запуске
              home: const CustomBottomBar(),                // Мы используем нашу панель навигации в качестве основы
            );
          },
        );
      },
    );
  }
}
