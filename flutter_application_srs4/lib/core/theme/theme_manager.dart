import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

// ==================== МЕНЕДЖЕР ТЕМ ====================
// ThemeManager управляет текущей темой приложения (Светлая / Тёмная).
// Наследуется от ChangeNotifier, чтобы уведомлять виджеты об изменении темы.
class ThemeManager extends ChangeNotifier {
  // Ключ для сохранения настройки темы в SharedPreferences (локальная база данных устройства)
  static const String _themeKey = 'isDarkMode';

  // Внутренняя переменная, хранящая текущее состояние (true - тёмная тема, false - светлая)
  bool _isDarkMode = false;

  // Геттер для получения текущего состояния темы
  bool get isDarkMode => _isDarkMode;

  // Конструктор: при создании загружаем сохраненную тему
  ThemeManager() {
    _loadTheme();
  }

  // Метод для переключения темы
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;                           // Меняем состояние на противоположное
    notifyListeners();                                    // Уведомляем слушателей (интерфейс перерисуется)
    
    // Сохраняем новый выбор пользователя в SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }

  // Приватный метод для загрузки темы при старте приложения
  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Читаем значение по ключу, если его нет (первый запуск), используем false (светлая тема)
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();                                    // Обновляем интерфейс после загрузки
  }

  // --- Настройка Светлой Темы ---
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondaryLight,
    ),
  );

  // --- Настройка Тёмной Темы ---
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.white,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondaryDark,
    ),
  );
}
