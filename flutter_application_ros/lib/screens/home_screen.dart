import 'package:flutter/material.dart';                                    // Material Design: базовые UI-компоненты

class HomeScreen extends StatelessWidget {                                 // Главное меню: список переходов ко всем демо-разделам
  const HomeScreen({super.key});                                           // Конструктор с ключом

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {
    return Scaffold(                                                       // Каркас Material-экрана
      appBar: AppBar(                                                      // Верхняя панель приложения
        title: const Text('Главное меню (Flutter Showcase)'),              // Заголовок экрана
      ),
      body: ListView(                                                      // Прокручиваемый список карточек-кнопок
        padding: const EdgeInsets.all(16.0),                               // Внутренние отступы списка
        children: [
          _buildMenuButton(context, '1. Виджеты значения', '/widgets_demo', Icons.text_fields),   // Раздел 1
          _buildMenuButton(context, '2. Вёрстка', '/layout_demo', Icons.dashboard),               // Раздел 2
          _buildMenuButton(context, '3. Навигация', '/navigation_demo', Icons.navigation),        // Раздел 3
          _buildMenuButton(context, '4. Диалоги и уведомления', '/dialogs_demo', Icons.message),  // Раздел 4
          _buildMenuButton(context, '5. Жесты и кнопки', '/gestures_demo', Icons.touch_app),      // Раздел 5
          _buildMenuButton(context, '6. Состояние (Stateful/Stateless)', '/state_demo', Icons.sync), // Раздел 6
          const Divider(height: 40, thickness: 2),                         // Визуальный разделитель
          const Text('Менеджмент состояния (State Management)',            // Заголовок секции State Management
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),   //    Стиль текста
            textAlign: TextAlign.center,                                   //    Выравнивание по центру
          ),
          const SizedBox(height: 10),                                      // Распорка-отступ
          _buildMenuButton(context, '7. BLoC (Основной)', '/bloc_demo', Icons.business_center, color: Colors.blue[100]),       // BLoC
          _buildMenuButton(context, '8. InheritedWidget', '/inherited_demo', Icons.account_tree, color: Colors.green[100]),    // InheritedWidget
          _buildMenuButton(context, '9. Hooks (flutter_hooks)', '/hooks_demo', Icons.build, color: Colors.orange[100]),        // Hooks
          _buildMenuButton(context, '10. Redux', '/redux_demo', Icons.store, color: Colors.purple[100]),                        // Redux
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, String route, IconData icon, {Color? color}) { // Вспомогательный метод: однотипная кнопка меню
    return Card(                                                           // Карточка-обёртка
      color: color,                                                        //    Цвет карточки (если передан)
      margin: const EdgeInsets.only(bottom: 12.0),                         //    Отступ снизу между карточками
      child: ListTile(                                                     //    Плитка с иконкой, текстом и стрелкой
        leading: Icon(icon, size: 30),                                     //    Иконка слева
        title: Text(title, style: const TextStyle(fontSize: 16)),          //    Текст пункта
        trailing: const Icon(Icons.arrow_forward_ios),                     //    Стрелка справа
        onTap: () {                                                        //    Обработчик клика
          Navigator.pushNamed(context, route);                             //    Переход по указанному маршруту
        },
      ),
    );
  }
}