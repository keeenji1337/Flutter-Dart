import 'package:flutter/material.dart';

// ==================== ЦВЕТА ПРИЛОЖЕНИЯ ====================
// Класс AppColors хранит все основные цвета, используемые в приложении.
// Это позволяет легко менять цветовую схему в одном месте, не переписывая код по всему проекту.
class AppColors {
  // --- Основные цвета ---
  static const Color primary = Color(0xFF2196F3);          // Основной синий цвет (используется для кнопок, активных иконок)
  static const Color white = Color(0xFFFFFFFF);            // Белый цвет
  static const Color black = Color(0xFF000000);            // Черный цвет
  static const Color error = Color(0xFFD32F2F);            // Цвет ошибки (красный)

  // --- Цвета для Светлой темы ---
  static const Color backgroundLight = Color(0xFFF5F5F5);  // Светло-серый фон
  static const Color surfaceLight = Color(0xFFFFFFFF);     // Белый цвет для карточек
  static const Color textPrimaryLight = Color(0xFF212121); // Темный текст для светлой темы
  static const Color textSecondaryLight = Color(0xFF757575); // Серый текст для второстепенной информации

  // --- Цвета для Тёмной темы ---
  static const Color backgroundDark = Color(0xFF121212);   // Темный фон
  static const Color surfaceDark = Color(0xFF1E1E1E);      // Немного светлее фона для карточек
  static const Color textPrimaryDark = Color(0xFFFFFFFF);  // Светлый текст для темной темы
  static const Color textSecondaryDark = Color(0xB3FFFFFF);// Полупрозрачный белый для второстепенной информации
}
