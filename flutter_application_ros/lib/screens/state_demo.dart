import 'package:flutter/material.dart';                                    // Material Design: базовые UI-компоненты

class StateDemoScreen extends StatefulWidget {                             // 1. StatefulWidget — виджет, который МОЖЕТ менять свое состояние
  const StateDemoScreen({super.key});                                      //    Конструктор с ключом (для идентификации в дереве)

  @override                                                                //    Создание объекта состояния
  State<StateDemoScreen> createState() => _StateDemoScreenState();         //    Возвращаем класс состояния _StateDemoScreenState
}

class _StateDemoScreenState extends State<StateDemoScreen> {               // State — класс, который хранит состояние для StateDemoScreen
  int _counter = 0;                                                        // Локальное состояние: счетчик

  void _incrementCounter() {                                               // Функция-callback: передаётся вниз, чтобы дочерние виджеты могли её вызвать
    setState(() {                                                          // setState говорит Flutter: "состояние изменилось, вызови build ещё раз"
      _counter++;                                                          // Увеличиваем счётчик
    });
  }

  void _updateCounterFromChild(int newValue) {                             // Функция для получения данных "снизу вверх"
    setState(() {                                                          // Сообщаем Flutter об изменении состояния
      _counter = newValue;                                                 // Устанавливаем новое значение
    });
  }

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {
    return Scaffold(                                                       // Каркас Material-экрана
      appBar: AppBar(title: const Text('Состояние (State)')),              // Верхняя панель с заголовком
      body: Center(                                                        // Центрируем содержимое по экрану
        child: Column(                                                     // Вертикальный столбец
          mainAxisAlignment: MainAxisAlignment.center,                     // Выравнивание по центру главной оси
          children: [
            Text('Счетчик: $_counter', style: const TextStyle(fontSize: 24)), // Отображаем текущее значение счётчика
            const SizedBox(height: 20),                                    // Распорка-отступ
            MyStatelessWidget(counterValue: _counter),                     // 2. Передача данных ВНИЗ (через конструктор)
            const SizedBox(height: 20),                                    // Распорка-отступ
            MyStatefulChildWidget(                                         // 3. Передача данных ВВЕРХ (через callback)
              onIncrement: _incrementCounter,                              //    Передаём функцию инкремента
              onUpdate: _updateCounterFromChild,                           //    Передаём функцию обновления значения
              currentValue: _counter,                                      //    Также передаём данные вниз
            ),
          ],
        ),
      ),
    );
  }
}

class MyStatelessWidget extends StatelessWidget {                          // 4. StatelessWidget — "глупый" виджет, только отрисовывает то, что дали
  final int counterValue;                                                  // Поле, в которое получаем данные при создании виджета (сверху вниз)

  const MyStatelessWidget({super.key, required this.counterValue}); // Конструктор

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {
    return Container(                                                      // Контейнер с фоном и отступами
      padding: const EdgeInsets.all(8),                                    // Внутренние отступы
      color: Colors.green[100],                                          // Светло-зелёный фон
      child: Text('Stateless Child: получил значение $counterValue'),      // Отображаем полученное значение
    );
  }
}

class MyStatefulChildWidget extends StatefulWidget {                       // 5. Дочерний StatefulWidget: демонстрирует widget.xxx и вызов callback'ов
  final int currentValue;                                                  // Данные, переданные сверху (ВНИЗ)
  final VoidCallback onIncrement;                                          // Callback без аргументов (отправить сигнал ВВЕРХ)
  final Function(int) onUpdate;                                            // Callback с аргументом int (передать значение ВВЕРХ)

  const MyStatefulChildWidget({                                            // Конструктор с обязательными параметрами
    super.key,                                                             //    Ключ
    required this.currentValue,                                            //    Текущее значение
    required this.onIncrement,                                             //    Функция инкремента
    required this.onUpdate,                                                //    Функция обновления
  });                                                                      //    Прокидываем ключ в базовый класс

  @override                                                                // Создание объекта состояния
  State<MyStatefulChildWidget> createState() => _MyStatefulChildWidgetState(); // Возвращаем класс состояния
}

class _MyStatefulChildWidgetState extends State<MyStatefulChildWidget> {   // Состояние дочернего виджета
  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {
    return Container(                                                      // Контейнер с фоном и отступами
      padding: const EdgeInsets.all(8),                                    // Внутренние отступы
      color: Colors.orange[100],                                         // Светло-оранжевый фон
      child: Column(                                                       // Вертикальный столбец
        children: [
          Text('Stateful Child видит: ${widget.currentValue}'),            // 6. Использование widget.xxx для доступа к полям родителя
          ElevatedButton(                                                  // Кнопка "Сказать родителю +1"
            onPressed: widget.onIncrement,                                 //    Вызываем callback родителя (сигнал ВВЕРХ)
            child: const Text('Сказать родителю +1'),                      //    Текст кнопки
          ),
          ElevatedButton(                                                  // Кнопка "Передать число 42 наверх"
            onPressed: () {                                                //    Обработчик клика
              widget.onUpdate(42);                                         //    Передаём число 42 родителю (данные ВВЕРХ)
            },
            child: const Text('Передать число 42 наверх'),                 //    Текст кнопки
          ),
        ],
      ),
    );
  }
}