import 'package:flutter/material.dart';                                    // Material Design: базовые UI-компоненты

class MyInheritedData extends InheritedWidget {                            // 1. InheritedWidget: передаёт данные глубоко вниз, минуя промежуточные виджеты
  final String secretData;                                                 // Данные, которые расшариваем (например, строка)

  const MyInheritedData({                                                  // Конструктор: обязателен child — виджет, который оборачиваем
    super.key,                                                             //    Ключ
    required this.secretData,                                              //    Обязательные данные
    required super.child,                                                  //    Обязательный дочерний виджет
  });                                                                     //    Прокидываем key и child в базовый класс

  static MyInheritedData? of(BuildContext context) {                       // 2. Статический метод of — удобный доступ к данным из потомков
    return context.dependOnInheritedWidgetOfExactType<MyInheritedData>();  // Ищем ближайший MyInheritedData вверх и подписываемся на изменения
  }

  @override                                                                // 3. Решаем, перерисовывать ли потомков при пересоздании
  bool updateShouldNotify(MyInheritedData oldWidget) {
    return secretData != oldWidget.secretData;                             // Если данные изменились — true (перерисовать потомков)
  }
}

class InheritedDemoScreen extends StatefulWidget {                         // 4. Демонстрационный экран
  const InheritedDemoScreen({super.key});                                 // Конструктор с ключом

  @override                                                                // Создание объекта состояния
  State<InheritedDemoScreen> createState() => _InheritedDemoScreenState(); // Возвращаем класс состояния
}

class _InheritedDemoScreenState extends State<InheritedDemoScreen> {       // Состояние экрана
  String _data = "Начальные данные (Inherited)";                           // Локальное состояние экрана

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {
    return Scaffold(                                                       // Каркас Material-экрана
      appBar: AppBar(title: const Text('InheritedWidget Demo')),           // Верхняя панель с заголовком
      body: Center(                                                        // Центрируем содержимое
        child: MyInheritedData(                                            // Оборачиваем часть дерева в MyInheritedData
          secretData: _data,                                               //    Передаём данные
          child: Column(                                                   //    Вертикальный столбец
            mainAxisAlignment: MainAxisAlignment.center,                   //    Выравнивание по центру главной оси
            children: [
              ElevatedButton(                                              //    Кнопка "Обновить данные"
                onPressed: () {                                            //    Обработчик клика
                  setState(() {                                            //    Перерисовываем InheritedDemoScreen
                    _data = "Обновленные данные: ${DateTime.now().second}"; // Новое значение данных
                  });
                },
                child: const Text('Обновить данные'),                      //    Текст кнопки
              ),
              const SizedBox(height: 30),                                  //    Распорка-отступ
              const IntermediateWidget(),                                  //    Промежуточный виджет (не знает о данных)
            ],
          ),
        ),
      ),
    );
  }
}

class IntermediateWidget extends StatelessWidget {                         // Промежуточный виджет: доказывает, что не нужно прокидывать данные через конструкторы
  const IntermediateWidget({super.key});                                   // Конструктор с ключом

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {
    return Container(                                                      // Контейнер с фоном и отступами
      padding: const EdgeInsets.all(16),                                   //    Внутренние отступы
      color: Colors.blue[100],                                           //    Светло-синий фон
      child: const Column(                                                 //    Вертикальный столбец
        children: [
          Text('Я просто промежуточный виджет, я ничего не знаю о данных.'), // Подпись
          SizedBox(height: 10),                                              //    Распорка-отступ
          TargetWidget(),                                                    //    Целевой виджет, который использует данные
        ],
      ),
    );
  }
}

class TargetWidget extends StatelessWidget {                               // Целевой виджет: хочет получить данные
  const TargetWidget({super.key});                                         // Конструктор с ключом

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {
    final inheritedData = MyInheritedData.of(context);                     // 5. Получаем данные через of() — это подписывает на изменения
    return Container(                                                      // Контейнер с фоном и отступами
      padding: const EdgeInsets.all(16),                                   //    Внутренние отступы
      color: Colors.green[200],                                          //    Светло-зелёный фон
      child: Text(                                                         //    Отображаем данные
        'Данные из InheritedWidget:\n${inheritedData?.secretData ?? "Нет данных"}', // Текст с данными (или дефолт)
        textAlign: TextAlign.center,                                       //    Выравнивание по центру
        style: const TextStyle(fontWeight: FontWeight.bold),               //    Жирный шрифт
      ),
    );
  }
}