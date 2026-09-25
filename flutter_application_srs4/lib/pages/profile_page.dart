import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../generated/locale_keys.g.dart';
import '../main.dart'; // Для доступа к themeManager

// ==================== СТРАНИЦА ПРОФИЛЯ ====================
// Здесь находятся настройки приложения (смена языка, смена темы)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.profile.tr()),                       // Название страницы из локализации
        centerTitle: true,
      ),
      body: SingleChildScrollView(                         // Позволяет прокручивать содержимое, если оно не влезает на экран
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Верхняя часть - Аватарка и имя пользователя
            Center(
              child: Column(
                children: [
                  // CircleAvatar создает круглую картинку
                  CircleAvatar(
                    radius: 50.w,                          // Адаптивный радиус
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Icon(Icons.person, size: 50.w, color: AppColors.primary),
                  ),
                  SizedBox(height: 16.h),
                  Text("Абрамов Даниил", style: AppTextStyles.title), // Имя пользователя (демо)
                  Text("abramovdaniil@gmail.com", style: AppTextStyles.caption),
                ],
              ),
            ),
            
            SizedBox(height: 32.h),                        // Отступ между профилем и настройками
            
            // Настройки (Switchers)
            
            // Переключатель Темы (Светлая / Тёмная)
            // ListenableBuilder обновляет ТОЛЬКО этот виджет при смене темы в themeManager
            ListenableBuilder(
              listenable: themeManager,
              builder: (context, child) {
                return _buildSettingTile(
                  context,
                  title: LocaleKeys.change_theme.tr(),              // Текст из локализации
                  icon: themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  trailing: Switch(
                    value: themeManager.isDarkMode,        // Текущее значение
                    onChanged: (val) {
                      themeManager.toggleTheme();          // Вызов функции смены темы
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                );
              },
            ),
            
            SizedBox(height: 12.h),

            // Переключатель Языка
            _buildSettingTile(
              context,
              title: LocaleKeys.change_language.tr(),
              icon: Icons.language,
              trailing: DropdownButton<String>(
                value: context.locale.languageCode,        // Текущий язык ('ru' или 'en')
                items: const [
                  DropdownMenuItem(value: 'ru', child: Text("Русский")),
                  DropdownMenuItem(value: 'en', child: Text("English")),
                  DropdownMenuItem(value: 'kk', child: Text("Қазақша")),
                ],
                onChanged: (String? newLanguage) {
                  if (newLanguage != null) {
                    context.setLocale(Locale(newLanguage));// Смена языка через easy_localization
                  }
                },
                underline: const SizedBox(),               // Убирает стандартную линию подчеркивания
              ),
            ),

            SizedBox(height: 12.h),

            // Информация о приложении
            _buildSettingTile(
              context,
              title: LocaleKeys.app_info.tr(),
              icon: Icons.info_outline,
              trailing: Icon(Icons.arrow_forward_ios, size: 16.w, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Вспомогательный виджет для пунктов меню настроек
  Widget _buildSettingTile(BuildContext context, {required String title, required IconData icon, required Widget trailing}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), // Адаптивные отступы внутри
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,      // Цвет фона (адаптируется к теме)
        borderRadius: BorderRadius.circular(12.r),         // Скругление углов
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),         // Легкая тень
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24.w),// Иконка пункта меню
          SizedBox(width: 16.w),
          Expanded(
            child: Text(title, style: AppTextStyles.body), // Текст пункта меню
          ),
          trailing,                                        // Виджет справа (Switch, Dropdown и т.д.)
        ],
      ),
    );
  }
}
