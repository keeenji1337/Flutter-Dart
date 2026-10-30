import 'package:flutter/material.dart';                  // Базовые UI-компоненты Material Design

class CachedBanner extends StatelessWidget {              // Виджет-баннер: сообщает пользователю об отображении кэшированных данных
  final VoidCallback? onRefresh;                         // Колбэк повторного запроса при нажатии на кнопку обновления

  const CachedBanner({super.key, this.onRefresh});       // Конструктор виджета баннера

  @override                                              // Построение UI баннера
  Widget build(BuildContext context) {                   // Метод сборки виджета
    return Container(                                    // Контейнер с фоновой подсветкой и скруглением
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Внешние отступы вокруг баннера
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // Внутренние отступы внутри плашки
      decoration: BoxDecoration(                         // Декорация плашки баннера
        color: Colors.amber.shade100,                    // Мягкий желтоватый фон предупреждения
        borderRadius: BorderRadius.circular(12),         // Закругленные края 12px
        border: Border.all(color: Colors.amber.shade400), // Тонкая контрастная рамка
      ),                                                 // Завершение декорации
      child: Row(                                        // Горизонтальное размещение иконки, текста и кнопки
        children: [                                      // Дочерние элементы строки
          Icon(                                          // Иконка облака в автономном режиме
            Icons.cloud_off_rounded,                     // Символ отключенного облака
            color: Colors.amber.shade900,                // Темно-янтарный цвет иконки
            size: 24,                                    // Размер иконки 24px
          ),                                             // Завершение Icon
          const SizedBox(width: 12),                     // Промежуток между иконкой и текстом
          Expanded(                                      // Текстовый блок занимает все доступное место
            child: Column(                               // Колонка с основным текстом и подсказкой
              crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание текста по левому краю
              children: [                                // Список текстовых строк
                Text(                                    // Главный заголовок баннера
                  'Отображаются кэшированные данные',    // Текст согласно ТЗ Задание E
                  style: TextStyle(                      // Стилизация заголовка
                    color: Colors.amber.shade900,        // Темно-янтарный цвет
                    fontWeight: FontWeight.bold,         // Жирное начертание
                    fontSize: 13,                        // Размер шрифта 13px
                  ),                                     // Завершение стиля
                ),                                       // Завершение первого Text
                const Text(                              // Поясняющий подзаголовок
                  'Сервер недоступен или идет фоновое обновление', // Подсказка для пользователя
                  style: TextStyle(                      // Стиль подсказки
                    color: Colors.black87,               // Темно-серый цвет
                    fontSize: 11,                        // Мелкий размер 11px
                  ),                                     // Завершение TextStyle
                ),                                       // Завершение второго Text
              ],                                         // Завершение списка строк Column
            ),                                           // Завершение Column
          ),                                             // Завершение Expanded
          if (onRefresh != null)                         // Если передан колбэк обновления
            IconButton(                                  // Кнопка быстрого повторного запроса
              icon: const Icon(Icons.refresh, size: 20), // Иконка обновления
              color: Colors.amber.shade900,              // Цвет иконки обновления
              tooltip: 'Повторить запрос',               // Всплывающая подсказка
              onPressed: onRefresh,                      // Обработка клика на обновление
            ),                                           // Завершение IconButton
        ],                                               // Завершение элементов Row
      ),                                                 // Завершение Row
    );                                                   // Завершение Container
  }                                                      // Конец метода build
}                                                        // Конец класса CachedBanner
