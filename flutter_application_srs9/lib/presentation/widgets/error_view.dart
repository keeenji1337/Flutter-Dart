import 'package:flutter/material.dart';                  // UI-элементы Material Design

class ErrorView extends StatelessWidget {                 // Виджет отображения экрана ошибки с кнопкой повтора
  final String message;                                  // Сообщение об ошибке для пользователя
  final VoidCallback onRetry;                            // Действие при нажатии кнопки «Повторить попытку»

  const ErrorView({                                      // Конструктор виджета ошибки
    super.key,                                           // Ключ виджета
    required this.message,                               // Обязательный текст ошибки
    required this.onRetry,                               // Обязательный колбэк повтора
  });                                                    // Завершение конструктора

  @override                                              // Построение интерфейса
  Widget build(BuildContext context) {                   // Метод сборки
    return Center(                                       // Центрируем контент по центру экрана
      child: Padding(                                    // Внутренние отступы по краям
        padding: const EdgeInsets.all(24.0),             // Отступ 24px со всех сторон
        child: Column(                                   // Вертикальное размещение иконки, текста и кнопки
          mainAxisAlignment: MainAxisAlignment.center,   // Выравнивание по центру вертикали
          children: [                                    // Дочерние элементы колонки
            Container(                                   // Круглая фоновая подложка для иконки
              padding: const EdgeInsets.all(20),         // Отступ вокруг иконки
              decoration: BoxDecoration(                 // Декорация подложки
                color: Colors.red.shade50,               // Светло-красный цвет фона
                shape: BoxShape.circle,                  // Круглая форма
              ),                                         // Завершение BoxDecoration
              child: Icon(                               // Иконка сетевой или серверной ошибки
                Icons.error_outline_rounded,             // Символ восклицательного знака в круге
                size: 54,                                // Размер иконки 54px
                color: Colors.red.shade700,              // Насыщенный красный цвет
              ),                                         // Завершение Icon
            ),                                           // Завершение Container
            const SizedBox(height: 20),                  // Отступ между иконкой и текстом
            const Text(                                  // Заголовок ошибки
              'Произошла ошибка',                        // Текст заголовка
              style: TextStyle(                          // Стиль заголовка
                fontSize: 18,                            // Размер шрифта 18px
                fontWeight: FontWeight.bold,             // Полужирное начертание
              ),                                         // Завершение TextStyle
            ),                                           // Завершение Text
            const SizedBox(height: 8),                   // Отступ между заголовком и описанием
            Text(                                        // Текст ошибки для пользователя
              message,                                   // Динамический текст ошибки
              textAlign: TextAlign.center,               // Выравнивание текста по центру
              style: TextStyle(                          // Стилизация описания ошибки
                fontSize: 14,                            // Размер шрифта 14px
                color: Colors.grey.shade700,             // Серый нейтральный цвет
              ),                                         // Завершение TextStyle
            ),                                           // Завершение Text
            const SizedBox(height: 24),                  // Отступ перед кнопкой
            FilledButton.icon(                           // Современная кнопка действия Material 3
              onPressed: onRetry,                        // Вызов колбэка повтора
              icon: const Icon(Icons.refresh_rounded),   // Иконка обновления
              label: const Text('Повторить попытку'),    // Текст на кнопке
              style: FilledButton.styleFrom(             // Стили кнопки
                padding: const EdgeInsets.symmetric(     // Внутренние отступы кнопки
                  horizontal: 24,                        // Горизонтальный отступ
                  vertical: 12,                          // Вертикальный отступ
                ),                                       // Завершение отступов
                shape: RoundedRectangleBorder(           // Скругление кнопки
                  borderRadius: BorderRadius.circular(10), // Радиус 10px
                ),                                       // Завершение формы
              ),                                         // Завершение styleFrom
            ),                                           // Завершение FilledButton
          ],                                             // Завершение children
        ),                                               // Завершение Column
      ),                                                 // Завершение Padding
    );                                                   // Завершение Center
  }                                                      // Конец build
}                                                        // Конец класса ErrorView
