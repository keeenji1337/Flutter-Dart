import 'package:flutter/material.dart';                                    // Material Design: базовые UI-компоненты
import 'package:flutter/cupertino.dart';                                   // Cupertino (iOS): CupertinoButton

class GesturesDemoScreen extends StatefulWidget {                          // Экран демонстрации жестов и кнопок
  const GesturesDemoScreen({super.key});                                   // Конструктор с ключом

  @override                                                                // Создание объекта состояния
  State<GesturesDemoScreen> createState() => _GesturesDemoScreenState();   // Возвращаем класс состояния
}

class _GesturesDemoScreenState extends State<GesturesDemoScreen> {         // Состояние экрана
  String _gestureText = 'Нажми на меня';                                   // Текст, который меняется при жестах
  double _scale = 1.0;                                                     // Масштаб (для жеста scale)
  final List<String> _items = List.generate(5, (index) => 'Элемент $index'); // Список для демонстрации Dismissible

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {
    return Scaffold(                                                       // Каркас Material-экрана
      appBar: AppBar(title: const Text('Жесты и кнопки')),                 // Верхняя панель с заголовком
      body: ListView(                                                      // Прокручиваемый список (чтобы всё поместилось)
        padding: const EdgeInsets.all(16.0),                               //    Внутренние отступы
        children: [
          const Text('1. GestureDetector', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // Заголовок секции 1
          const SizedBox(height: 10),                                      //    Распорка-отступ
          GestureDetector(                                                 //    GestureDetector: ловит жесты на виджете
            onTap: () {                                                    //    Обычное короткое нажатие
              setState(() { _gestureText = 'Tap (Короткое нажатие)'; });   //    Обновляем текст
            },
            onDoubleTap: () {                                                   //    Двойное нажатие
              setState(() { _gestureText = 'Double Tap (Двойное нажатие)'; });  // Обновляем текст
            },
            onLongPress: () {                                                   //    Долгое нажатие
              setState(() { _gestureText = 'Long Press (Долгое нажатие)'; });   // Обновляем текст
            },
            onScaleUpdate: (ScaleUpdateDetails details) {                  //    Жест щипка (изменение масштаба)
              setState(() {                                                //    Обновляем состояние
                _scale = details.scale.clamp(0.5, 3.0);                    //    Ограничиваем масштаб 0.5–3.0
                _gestureText = 'Scale (Масштабирование): ${_scale.toStringAsFixed(2)}'; // Текст с масштабом
              });
            },
            child: Container(                                              //    Виджет, на котором слушаем жесты
              height: 150,                                                 //    Высота
              color: Colors.blueAccent,                                  //    Синий фон
              alignment: Alignment.center,                                 //    Центрируем содержимое
              child: Transform.scale(                                      //    Применяем масштаб
                scale: _scale,                                             //    Текущий масштаб
                child: Text(                                               //    Текст внутри
                  _gestureText,
                  style: const TextStyle(color: Colors.white, fontSize: 16), // Белый, 16
                  textAlign: TextAlign.center,                             //    По центру
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),                                      //    Распорка-отступ
          const Text('2. Dismissible (Свайп для удаления)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // Заголовок секции 2
          const SizedBox(height: 10),                                      //    Распорка-отступ
          ListView.builder(                                                //    Вложенный список: элементы, которые можно смахнуть
            shrinkWrap: true,                                              //    Занимает только нужную высоту
            physics: const NeverScrollableScrollPhysics(),                 //    Отключаем прокрутку (внешний список уже крутится)
            itemCount: _items.length,                                      //    Количество элементов
            itemBuilder: (context, index) {                                //    Билдер элемента
              final item = _items[index];                                  //    Текущий элемент
              return Dismissible(                                          //    Dismissible: свайп для удаления
                key: Key(item),                                            //    Уникальный ключ (обязателен)
                onDismissed: (direction) {                                 //    Обработчик смахивания
                  setState(() {                                            //    Обновляем состояние
                    _items.removeAt(index);                                //    Удаляем из списка
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$item удален'))); // Уведомление
                },
                background: Container(                                     //    Фон под элементом при смахивании
                  color: Colors.red,                                     //    Красный
                  alignment: Alignment.centerRight,                        //    Иконка справа
                  padding: const EdgeInsets.only(right: 20.0),             //    Отступ справа
                  child: const Icon(Icons.delete, color: Colors.white),  //    Иконка удаления
                ),
                child: ListTile(title: Text(item)),                        //    Сам элемент
              );
            },
          ),
          const SizedBox(height: 20),                                      //    Распорка-отступ
          const Text('3. Кнопки', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // Заголовок секции 3
          const SizedBox(height: 10),                                      //    Распорка-отступ
          Wrap(                                                            //    Wrap: переносит элементы на новую строку
            spacing: 10,                                                   //    Отступ между элементами по горизонтали
            runSpacing: 10,                                                //    Отступ между строками
            children: [
              ElevatedButton(                                              //    ElevatedButton: замена RaisedButton
                onPressed: () {},                                          //    Обработчик (пустой)
                child: const Text('ElevatedButton (Raised)'),              //    Текст кнопки
              ),
              TextButton(                                                  //    TextButton: замена FlatButton
                onPressed: () {},                                          //    Обработчик (пустой)
                child: const Text('TextButton (Flat)'),                    //    Текст кнопки
              ),
              IconButton(                                                  //    IconButton: кнопка-иконка без текста
                onPressed: () {},                                          //    Обработчик (пустой)
                icon: const Icon(Icons.thumb_up),                          //    Иконка
                color: Colors.green,                                     //    Цвет иконки
                tooltip: 'IconButton',                                     //    Подсказка
              ),
              CupertinoButton(                                             //    CupertinoButton: кнопка в стиле iOS
                color: CupertinoColors.activeBlue,                       //    Цвет фона
                onPressed: () {},                                          //    Обработчик (пустой)
                child: const Text('CupertinoButton'),                      //    Текст кнопки
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(                          // Плавающая кнопка действия (правый нижний угол)
        onPressed: () {                                                    //    Обработчик клика
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нажат FAB!'))); // Уведомление
        },
        child: const Icon(Icons.add),                                      //    Иконка внутри (плюсик)
      ),
    );
  }
}