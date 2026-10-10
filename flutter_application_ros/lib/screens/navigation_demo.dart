import 'package:flutter/material.dart';                                    // Material Design: базовые UI-компоненты

class NavigationDemoScreen extends StatelessWidget {                       // Экран демонстрации навигации
  const NavigationDemoScreen({super.key});                                 // Конструктор с ключом

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {
    return DefaultTabController(                                           // Обёртка: связывает TabBar и TabBarView без ручного контроллера
      length: 2,                                                           //    Количество вкладок
      child: Scaffold(                                                     //    Каркас Material-экрана
        appBar: AppBar(                                                    //    Верхняя панель приложения
          title: const Text('Навигация (Navigation)'),                     //    Заголовок экрана
          bottom: const TabBar(                                            //    TabBar под заголовком: переключатель вкладок
            tabs: [
              Tab(icon: Icon(Icons.directions_car), text: 'Вкладка 1'),    //    Первая вкладка (иконка машины)
              Tab(icon: Icon(Icons.directions_transit), text: 'Вкладка 2'),//    Вторая вкладка (иконка поезда)
            ],
          ),
        ),
        drawer: Drawer(                                                    //    Боковое выезжающее меню (слева)
          child: ListView(                                                 //    Прокручиваемый список пунктов
            padding: EdgeInsets.zero,                                      //    Убираем стандартные отступы списка
            children: [
              const DrawerHeader(                                          //    Шапка бокового меню
                decoration: BoxDecoration(color: Colors.blue),           //    Синий фон
                child: Text('Это Drawer (Боковое меню)', style: TextStyle(color: Colors.white, fontSize: 24)), // Текст шапки
              ),
              ListTile(                                                    //    Пункт меню: "На главную"
                leading: const Icon(Icons.home),                           //    Иконка слева
                title: const Text('На главную'),                           //    Текст пункта
                onTap: () {                                                //    Обработчик клика
                  Navigator.pop(context);                                  //    Закрываем Drawer (pop, т.к. он как модалка)
                },
              ),
              ListTile(                                                    //    Пункт меню: "Настройки"
                leading: const Icon(Icons.settings),                       //    Иконка слева
                title: const Text('Настройки'),                            //    Текст пункта
                onTap: () {                                                //    Обработчик клика
                  Navigator.pop(context);                                  //    Закрываем меню
                },
              ),
            ],
          ),
        ),
        body: TabBarView(                                                  //    Содержимое вкладок
          children: [
            Center(                                                        //    Содержимое первой вкладки
              child: ElevatedButton(                                       //    Кнопка перехода
                onPressed: () async {                                      //    Асинхронный обработчик (ждём результат)
                  final result = await Navigator.pushNamed(context, '/result_screen'); // Переход по маршруту + ожидание результата
                  if (!context.mounted) return;
                  if (result != null) {                                    //    Если вернулись с результатом
                    ScaffoldMessenger.of(context).showSnackBar(            //    Показываем SnackBar
                      SnackBar(content: Text('Вернулся результат: $result')), // Текст уведомления
                    );
                  }
                },
                child: const Text('Перейти на экран с возвратом результата'), // Текст кнопки
              ),
            ),
            const Center(child: Text('Здесь содержимое второй вкладки')),  //    Содержимое второй вкладки
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {                               // Отдельный экран для возврата данных назад
  const ResultScreen({super.key});                                         // Конструктор с ключом

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {
    return Scaffold(                                                       // Каркас Material-экрана
      appBar: AppBar(title: const Text('Экран результата')),               // Верхняя панель с заголовком
      body: Center(                                                        // Центрируем содержимое
        child: Column(                                                     // Вертикальный столбец
          mainAxisAlignment: MainAxisAlignment.center,                     // Выравнивание по центру главной оси
          children: [
            const Text('Нажмите кнопку, чтобы вернуться с данными'),       // Подсказка пользователю
            const SizedBox(height: 20),                                    // Распорка-отступ
            ElevatedButton(                                                // Кнопка возврата
              onPressed: () {                                              //    Обработчик клика
                Navigator.pop(context, 'Секретный код 42');                //    Возвращаемся назад и передаём данные
              },
              child: const Text('Вернуться назад с ответом'),              //    Текст кнопки
            ),
          ],
        ),
      ),
    );
  }
}