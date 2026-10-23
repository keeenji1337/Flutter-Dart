import 'package:flutter/material.dart';                  // Базовые компоненты Material

class LoadingIndicator extends StatelessWidget {          // Виджет красивого центрированного индикатора загрузки
  final String? message;                                 // Опциональный поясняющий текст (например, «Загрузка постов...»)

  const LoadingIndicator({super.key, this.message});     // Конструктор виджета загрузки

  @override                                              // Построение UI
  Widget build(BuildContext context) {                   // Метод сборки
    return Center(                                       // Центрирование элемента
      child: Column(                                     // Вертикальный стек кругового лоадера и текста
        mainAxisAlignment: MainAxisAlignment.center,     // Центрирование по вертикали
        mainAxisSize: MainAxisSize.min,                  // Минимальный размер по высоте
        children: [                                      // Дочерние виджеты
          const CircularProgressIndicator(),             // Стандартный круговой индикатор прогресса Flutter
          if (message != null) ...[                      // Если передан текст сообщения
            const SizedBox(height: 16),                  // Отступ перед текстом
            Text(                                        // Текст статуса загрузки
              message!,                                  // Значение сообщения
              style: TextStyle(                          // Стиль текста
                fontSize: 14,                            // Размер 14px
                color: Colors.grey.shade600,             // Серый цвет
              ),                                         // Завершение TextStyle
            ),                                           // Завершение Text
          ],                                             // Конец условия if
        ],                                               // Завершение children
      ),                                                 // Завершение Column
    );                                                   // Завершение Center
  }                                                      // Конец build
}                                                        // Конец LoadingIndicator
