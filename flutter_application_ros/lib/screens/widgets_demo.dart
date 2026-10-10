import 'package:flutter/material.dart';                                    // Material Design: базовые UI-компоненты

class WidgetsDemoScreen extends StatefulWidget {                           // Экран демо виджетов значения (StatefulWidget: UI меняется)
  const WidgetsDemoScreen({super.key});                                    // Конструктор с ключом (для идентификации в дереве)

  @override                                                                // Создание объекта состояния
  State<WidgetsDemoScreen> createState() => _WidgetsDemoScreenState();     // Возвращаем класс состояния _WidgetsDemoScreenState
}

class _WidgetsDemoScreenState extends State<WidgetsDemoScreen> {           // Состояние экрана: хранит данные и обновляет UI
  final TextEditingController _textController = TextEditingController();   // Контроллер для чтения и управления текстом в TextField
  bool _isChecked = false;                                                 // Состояние чекбокса (нажат / не нажат)
  int _radioValue = 1;                                                     // Выбранное значение радио-группы

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {                                     // Метод build: вызывается при каждой перерисовке (в т.ч. по setState)
    return Scaffold(                                                       // Каркас Material-экрана: AppBar, body и т.д.
      appBar: AppBar(                                                      // Верхняя панель приложения
        title: const Text('Виджеты значения'),                             // Заголовок экрана
      ),
      body: ListView(                                                      // Прокручиваемый список (если контент не влезает)
        padding: const EdgeInsets.all(16.0),                               // Внутренние отступы вокруг содержимого
        children: [                                                        // Список дочерних виджетов
          const Text('Это простой Text виджет'),                           // 1. Text — простой текст
          const SizedBox(height: 16),                                      //    Распорка-отступ
          const Icon(Icons.star, color: Colors.orange, size: 40),        // 2. Icon — иконка Material
          const SizedBox(height: 16),                                      //    Распорка-отступ
          Image.network(                                                   // 3. Image.network — картинка из интернета
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
            height: 100,                                                   //    Высота картинки
            fit: BoxFit.cover,                                             //    Как вписывать в размеры
          ),
          const SizedBox(height: 16),                                      //    Распорка-отступ
          Image.asset(                                                     // 4. Image.asset — картинка из локальных ассетов
            'assets/images/dash.gif',                                      //    Путь к файлу
            height: 100,                                                   //    Высота картинки
          ),
          const SizedBox(height: 16),                                      //    Распорка-отступ
          TextField(                                                       // 5. TextField — поле ввода текста
            controller: _textController,                                   //    Привязанный контроллер
            keyboardType: TextInputType.emailAddress,                      //    Тип клавиатуры (покажет @)
            obscureText: false,                                            //    Скрывать символы (для паролей — true)
            decoration: const InputDecoration(                             //    Оформление внешнего вида поля
              labelText: 'Введите email (TextField)',                      //    Подпись над полем
              border: OutlineInputBorder(),                                //    Рамка вокруг поля
              prefixIcon: Icon(Icons.email),                               //    Иконка слева внутри поля
            ),
          ),
          const SizedBox(height: 16),                                      //    Распорка-отступ
          Row(                                                             // 6. Row — горизонтальный ряд
            children: [
              Checkbox(                                                    //    Чекбокс (галочка выбора)
                value: _isChecked,                                         //    Текущее значение
                onChanged: (bool? value) {                                 //    Обработчик клика
                  setState(() {                                            //    Сообщаем Flutter: состояние изменилось
                    _isChecked = value ?? false;                           //    Обновляем переменную состояния
                  });
                },
              ),
              const Text('Checkbox'),                                      //    Подпись рядом с чекбоксом
            ],
          ),
          Row(                                                             // 7. Row — горизонтальный ряд
            children: [
              // ignore: deprecated_member_use
              Radio<int>(                                                  //    Радио-кнопка №1
                value: 1,                                                  //    Значение именно этой кнопки
                // ignore: deprecated_member_use
                groupValue: _radioValue,                                   //    Выбранное значение всей группы
                // ignore: deprecated_member_use
                onChanged: (int? value) {                                  //    Обработчик клика
                  setState(() { _radioValue = value!; });                  //    Обновляем состояние
                },
              ),
              const Text('Опция 1'),                                       //    Подпись
              // ignore: deprecated_member_use
              Radio<int>(                                                  //    Радио-кнопка №2
                value: 2,                                                  //    Значение именно этой кнопки
                // ignore: deprecated_member_use
                groupValue: _radioValue,                                   //    Та же группа
                // ignore: deprecated_member_use
                onChanged: (int? value) {                                  //    Обработчик клика
                  setState(() { _radioValue = value!; });                  //    Обновляем состояние
                },
              ),
              const Text('Опция 2'),                                       //    Подпись
            ],
          ),
          const SizedBox(height: 16),                                      //    Распорка-отступ
          ElevatedButton(                                                  // 8. Кнопка: диалог выбора даты (DatePicker)
            onPressed: () async {                                          //    Асинхронный обработчик
              final date = await showDatePicker(                           //    Диалог выбора даты (асинхронный)
                context: context,                                          //    Контекст
                initialDate: DateTime.now(),                               //    Начальная дата (сегодня)
                firstDate: DateTime(2000),                                 //    Минимальная дата
                lastDate: DateTime(2100),                                  //    Максимальная дата
              );
              if (date != null) {                                          //    Если пользователь выбрал дату
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(                //    Показываем SnackBar
                  SnackBar(content: Text('Выбрана дата: ${date.toLocal()}')), // Текст уведомления
                );
              }
            },
            child: const Text('Выбрать дату (DatePicker)'),                //    Текст кнопки
          ),
          ElevatedButton(                                                  // 9. Кнопка: диалог выбора времени (TimePicker)
            onPressed: () async {                                          //    Асинхронный обработчик
              final time = await showTimePicker(                           //    Диалог выбора времени (асинхронный)
                context: context,                                          //    Контекст
                initialTime: TimeOfDay.now(),                              //    Текущее время
              );
              if (time != null) {                                          //    Если пользователь выбрал время
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(                //    Показываем SnackBar
                  SnackBar(content: Text('Выбрано время: ${time.format(context)}')), // Текст уведомления
                );
              }
            },
            child: const Text('Выбрать время (TimePicker)'),               //    Текст кнопки
          ),
          const SizedBox(height: 16),                                      //    Распорка-отступ
          RichText(                                                        // 10. RichText — текст с разными стилями в одной строке
            text: const TextSpan(                                          //     Кусок текста (может содержать вложенные TextSpan)
              style: TextStyle(color: Colors.black, fontSize: 18),       //     Базовый стиль
              children: <TextSpan>[
                TextSpan(text: 'Это '),                                    //     Обычный текст
                TextSpan(                                                  //     Вложенный TextSpan
                  text: 'RichText',                                        //     Выделенное слово
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue), // Жирный, синий
                ),
                TextSpan(text: ' со стилями.'),                            //     Обычный текст
              ],
            ),
          ),
          const SizedBox(height: 16),                                      //    Распорка-отступ
          const Tooltip(                                                   // 11. Tooltip — подсказка при долгом нажатии / наведении
            message: 'Это подсказка (Tooltip)!',                           //     Текст подсказки
            child: Icon(Icons.info, size: 50, color: Colors.blueGrey),   //     Виджет, на который вешается подсказка
          ),
        ],
      ),
    );
  }

  @override                                                                // Переопределяем метод жизненного цикла
  void dispose() {                                                         // Вызывается при уничтожении виджета
    _textController.dispose();                                             // Освобождаем контроллер (иначе утечка)
    super.dispose();                                                       // Вызов базовой реализации
  }
}