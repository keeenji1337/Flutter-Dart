import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../pages/home_page.dart';
import '../pages/catalog_page.dart';
import '../pages/favorites_page.dart';
import '../pages/profile_page.dart';
import '../generated/locale_keys.g.dart';

// ==================== КАСТОМНАЯ НИЖНЯЯ ПАНЕЛЬ НАВИГАЦИИ ====================
// Stateful виджет, так как нам нужно хранить и изменять состояние выбранной вкладки
class CustomBottomBar extends StatefulWidget {
  const CustomBottomBar({super.key});

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  // Индекс текущей выбранной вкладки (по умолчанию 0 - Главная)
  int _currentIndex = 0;

  // Список всех страниц приложения, которые будут отображаться при переключении
  final List<Widget> _pages = const [
    HomePage(),       // 0 индекс
    CatalogPage(),    // 1 индекс
    FavoritesPage(),  // 2 индекс
    ProfilePage(),    // 3 индекс
  ];

  // Метод для обновления состояния при нажатии на элемент меню
  void _onTap(int index) {
    setState(() {
      _currentIndex = index; // Записываем новый индекс
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AnimatedSwitcher обеспечивает плавную анимацию переключения между страницами (Задание 6)
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300), // Длительность анимации 300 мс
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Используем анимацию появления (Fade transition)
          return FadeTransition(opacity: animation, child: child);
        },
        // Ключ нужен для того, чтобы AnimatedSwitcher понимал, что виджет изменился
        child: Container(
          key: ValueKey<int>(_currentIndex), 
          child: _pages[_currentIndex],               // Отображаем страницу по текущему индексу
        ),
      ),
      // Стандартный виджет нижней панели навигации
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,                  // Подсвечиваем текущую вкладку
        onTap: _onTap,                                // Обработчик нажатий
        type: BottomNavigationBarType.fixed,          // Fixed нужен, если вкладок больше 3, чтобы они не скакали
        items: [
          // Вкладка "Главная"
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),    // Иконка
            activeIcon: const Icon(Icons.home),       // Иконка при выборе
            label: LocaleKeys.home.tr(),                       // Локализованный текст (используем .tr() из easy_localization)
          ),
          // Вкладка "Каталог"
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag_outlined),
            activeIcon: const Icon(Icons.shopping_bag),
            label: LocaleKeys.catalog.tr(),
          ),
          // Вкладка "Избранное"
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_outline),
            activeIcon: const Icon(Icons.favorite),
            label: LocaleKeys.favorites.tr(),
          ),
          // Вкладка "Профиль"
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: LocaleKeys.profile.tr(),
          ),
        ],
      ),
    );
  }
}
