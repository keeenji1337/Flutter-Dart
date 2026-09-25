import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ==================== ТЕКСТОВЫЕ СТИЛИ ПРИЛОЖЕНИЯ ====================
// Класс AppTextStyles содержит константы для стилей текста.
// Мы используем .sp (ScreenUtil) для того, чтобы размер шрифта адаптировался под размер экрана пользователя.
class AppTextStyles {
  // Заголовок (на главном экране)
  static TextStyle get title => TextStyle(
    fontSize: 24.sp,                                       // Адаптивный размер 24
    fontWeight: FontWeight.bold,                           // Жирное начертание
  );

  // Основной текст (для описаний, текста в карточках)
  static TextStyle get body => TextStyle(
    fontSize: 16.sp,                                       // Адаптивный размер 16
    fontWeight: FontWeight.normal,                         // Обычное начертание
  );

  // Второстепенный текст (для подписей, мелких деталей)
  static TextStyle get caption => TextStyle(
    fontSize: 14.sp,                                       // Адаптивный размер 14
    fontWeight: FontWeight.w300,                           // Тонкое начертание
  );

  // Специфичный стиль для цены товара
  static TextStyle get price => TextStyle(
    fontSize: 18.sp,                                       // Адаптивный размер 18
    fontWeight: FontWeight.w600,                           // Полужирное начертание
  );
}
