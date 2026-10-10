import 'package:flutter/material.dart';                                    // Material Design: базовые UI-компоненты

class DialogsDemoScreen extends StatelessWidget {                          // Экран демонстрации диалогов и уведомлений
  const DialogsDemoScreen({super.key});                                   // Конструктор с ключом

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {
    return Scaffold(                                                       // Каркас Material-экрана
      appBar: AppBar(title: const Text('Диалоги и уведомления')),          // Верхняя панель с заголовком
      body: Center(                                                        // Центрируем содержимое
        child: Column(                                                     // Вертикальный столбец
          mainAxisAlignment: MainAxisAlignment.center,                     // Выравнивание по центру главной оси
          children: [
            ElevatedButton(                                                // Кнопка "Показать AlertDialog"
              onPressed: () {                                              //    Обработчик клика
                showDialog(                                                //    showDialog: показ всплывающего окна
                  context: context,                                        //    Контекст
                  builder: (BuildContext dialogContext) {                  //    Билдер содержимого диалога
                    return AlertDialog(                                    //    AlertDialog: стандартный диалог Material
                      title: const Text('Внимание!'),                      //    Заголовок диалога
                      content: const Text('Это AlertDialog. Вы уверены, что хотите продолжить?'), // Основной текст
                      actions: [
                        TextButton(                                    //    Кнопка "Отмена"
                          onPressed: () {                              //    Обработчик клика
                            Navigator.pop(dialogContext);              //    Закрываем диалог (pop)
                          },
                          child: const Text('Отмена'),                 //    Текст кнопки
                        ),
                        TextButton(                                    //    Кнопка "ОК"
                          onPressed: () {                              //    Обработчик клика
                            Navigator.pop(dialogContext);              //    Закрываем диалог
                            ScaffoldMessenger.of(context).showSnackBar( // Показываем SnackBar после закрытия
                              const SnackBar(content: Text('Действие подтверждено!')), // Текст уведомления
                            );
                          },
                          child: const Text('ОК'),                     //    Текст кнопки
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Показать AlertDialog'),                   //    Текст кнопки
            ),
            const SizedBox(height: 20),                                    //    Распорка-отступ
            ElevatedButton(                                                //    Кнопка "Показать SnackBar"
              onPressed: () {                                              //    Обработчик клика
                ScaffoldMessenger.of(context).showSnackBar(                //    ScaffoldMessenger: показ SnackBar поверх контента
                  SnackBar(                                                //    SnackBar: уведомление снизу экрана
                    content: const Text('Это простое уведомление (SnackBar)'), // Текст внутри
                    duration: const Duration(seconds: 2),                  //    Как долго показывать (2 сек)
                    action: SnackBarAction(                                //    Кнопка действия внутри SnackBar
                      label: 'Понятно',                                    //    Текст кнопки
                      onPressed: () {                                      //    Обработчик клика по кнопке
                      },
                    ),
                  ),
                );
              },
              child: const Text('Показать SnackBar'),                      //    Текст кнопки
            ),
          ],
        ),
      ),
    );
  }
}