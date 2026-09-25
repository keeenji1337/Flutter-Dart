import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../generated/locale_keys.g.dart';

// ==================== ГЛАВНАЯ СТРАНИЦА ====================
// StatelessWidget, так как страница не имеет сложного внутреннего состояния
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Верхняя панель (App Bar) с названием страницы
      appBar: AppBar(
        title: Text(LocaleKeys.home.tr()),                          // Локализованный заголовок
        centerTitle: true,                                 // Выравнивание по центру
      ),
      // SafeArea гарантирует, что контент не перекроется системными элементами (челка, статус бар)
      body: SafeArea(
        child: Padding(
          // Адаптивные отступы со всех сторон по 16 пикселей
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,  // Выравнивание элементов по левому краю
            children: [
              // Приветственный текст
              Text(
                LocaleKeys.welcome.tr(),                            // Текст из файла локализации
                style: AppTextStyles.title,                // Применение глобального стиля
              ),
              // Адаптивный отступ по высоте на 20 пикселей
              SizedBox(height: 20.h),
              
              // Главный баннер / карточка с иконкой
              Container(
                width: double.infinity,                    // Растянуть на всю ширину
                padding: EdgeInsets.all(20.w),             // Внутренние адаптивные отступы
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), // Цвет фона с прозрачностью
                  borderRadius: BorderRadius.circular(16.r),// Адаптивное скругление углов
                ),
                child: Row(
                  children: [
                    // Большая адаптивная иконка
                    Icon(Icons.flutter_dash, size: 64.w, color: AppColors.primary),
                    SizedBox(width: 16.w),                 // Отступ между иконкой и текстом
                    // Expanded нужен, чтобы текст занимал оставшееся свободное место и переносился
                    Expanded(
                      child: Text(
                        "Flutter ScreenUtil\n& EasyLocalization",
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Ряд из двух карточек с информацией (Используем Expanded для равного деления ширины)
              Row(
                children: [
                  Expanded(child: _buildInfoCard(context, Icons.phone_android, "Responsive")),
                  SizedBox(width: 16.w),
                  Expanded(child: _buildInfoCard(context, Icons.language, "Localized")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Вспомогательный метод для создания карточки (позволяет избежать дублирования кода)
  Widget _buildInfoCard(BuildContext context, IconData icon, String title) {
    return Container(
      padding: EdgeInsets.all(16.w),                       // Адаптивные внутренние отступы
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,      // Цвет карточки в зависимости от темы
        borderRadius: BorderRadius.circular(12.r),         // Адаптивное скругление углов
        boxShadow: [                                       // Небольшая тень для объема
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40.w, color: AppColors.primary), // Адаптивная иконка
          SizedBox(height: 8.h),                           // Отступ
          Text(title, style: AppTextStyles.body),          // Текст
        ],
      ),
    );
  }
}
