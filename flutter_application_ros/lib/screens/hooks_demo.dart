// Для debugPrint
import 'package:flutter/material.dart';                                    // Material Design: базовые UI-компоненты
import 'package:flutter_hooks/flutter_hooks.dart';                         // flutter_hooks: хуки для Flutter

class HooksDemoScreen extends HookWidget {                                 // Для хуков виджет наследуется от HookWidget (не Stateless/Stateful)
  const HooksDemoScreen({super.key});                                      // Конструктор с ключом

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {                                     // Внутри build можно вызывать хуки (функции use...)
    final counter = useState(0);                                           // 1. useState: локальное состояние (замена StatefulWidget + setState). Начало = 0
    final textController = useTextEditingController(text: 'Начальный текст'); // 2. useTextEditingController: создаёт и авто-dispose контроллера
    useEffect(() {                                                         // 3. useEffect: побочные эффекты (аналог initState + dispose)
      debugPrint('HooksDemoScreen смонтирован');                           //    Код выполнится один раз при монтировании
      return () {                                                          //    Возвращаемая функция — при размонтировании
        debugPrint('HooksDemoScreen размонтирован');                       //    Логируем размонтирование
      };
    }, const []);                                                          //    Пустой список зависимостей = эффект выполнится один раз

    return Scaffold(                                                       // Каркас Material-экрана
      appBar: AppBar(title: const Text('Hooks Demo (flutter_hooks)')),     // Верхняя панель с заголовком
      body: Padding(                                                       // Внутренние отступы вокруг содержимого
        padding: const EdgeInsets.all(16.0),                               //    Значение отступов
        child: Column(                                                     //    Вертикальный столбец
          mainAxisAlignment: MainAxisAlignment.center,                     //    Выравнивание по центру главной оси
          children: [
            Text('Счетчик (useState): ${counter.value}', style: const TextStyle(fontSize: 24)), // Читаем значение через .value
            const SizedBox(height: 20),                                    //    Распорка-отступ
            ElevatedButton(                                                //    Кнопка "Увеличить счетчик"
              onPressed: () {                                              //    Обработчик клика
                counter.value++;                                           //    Меняем .value — перерисовка происходит автоматически, без setState
              },
              child: const Text('Увеличить счетчик'),                      //    Текст кнопки
            ),
            const SizedBox(height: 40),                                    //    Распорка-отступ
            TextField(                                                     //    Поле ввода с контроллером из хука
              controller: textController,                                  //    Привязанный контроллер
              decoration: const InputDecoration(                           //    Оформление поля
                labelText: 'Текстовое поле (useTextEditingController)',    //    Подпись
                border: OutlineInputBorder(),                              //    Рамка
              ),
            ),
            const SizedBox(height: 10),                                    //    Распорка-отступ
            ElevatedButton(                                                //    Кнопка "Очистить текст"
              onPressed: () {                                              //    Обработчик клика
                textController.clear();                                    //    Очищаем поле (контроллер работает как обычно)
              },
              child: const Text('Очистить текст'),                         //    Текст кнопки
            ),
          ],
        ),
      ),
    );
  }
}