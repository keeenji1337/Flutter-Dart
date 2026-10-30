import 'package:flutter/material.dart';                  // Базовые UI-компоненты Material Design
import '../../data/models/post.dart';                    // Модель отображаемой публикации

class PostCard extends StatelessWidget {                 // Карточка поста в ленте публикаций
  final Post post;                                       // Данные публикации
  final VoidCallback onTap;                              // Действие при клике на карточку (переход к деталям)

  const PostCard({                                       // Конструктор карточки поста
    super.key,                                           // Ключ виджета
    required this.post,                                  // Обязательный объект поста
    required this.onTap,                                 // Обязательный колбэк нажатия
  });                                                    // Завершение конструктора

  @override                                              // Построение интерфейса карточки
  Widget build(BuildContext context) {                   // Метод сборки
    return Card(                                         // Виджет карточки Material Design со скруглением и тенью
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Внешние отступы между карточками
      elevation: 1.5,                                    // Мягкая ненавязчивая тень
      shape: RoundedRectangleBorder(                     // Скругленные границы карточки
        borderRadius: BorderRadius.circular(14),         // Радиус скругления углов 14px
      ),                                                 // Завершение shape
      child: InkWell(                                    // Виджет кликабельности с анимацией расхождения волны
        borderRadius: BorderRadius.circular(14),         // Скругление эффекта нажатия
        onTap: onTap,                                    // Нажатие переводит на экран деталей
        child: Padding(                                  // Внутренние отступы внутри карточки
          padding: const EdgeInsets.all(16.0),           // Отступ 16px со всех сторон
          child: Column(                                 // Вертикальное размещение элементов публикации
            crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание контента по левому краю
            children: [                                  // Список дочерних виджетов
              Row(                                       // Верхняя строка: номер поста, автор и бейдж
                children: [                              // Элементы строки
                  Container(                             // Плашка с номером поста
                    padding: const EdgeInsets.symmetric( // Внутренний отступ плашки номера
                      horizontal: 8,                     // Горизонтальный отступ 8px
                      vertical: 3,                       // Вертикальный отступ 3px
                    ),                                   // Завершение padding
                    decoration: BoxDecoration(           // Декорация плашки
                      color: Colors.blue.shade50,        // Светло-голубой фон
                      borderRadius: BorderRadius.circular(6), // Скругление 6px
                    ),                                   // Завершение BoxDecoration
                    child: Text(                         // Текст номера поста
                      '#${post.id ?? "new"}',            // Номер поста или "new" для локального
                      style: TextStyle(                  // Стиль номера
                        color: Colors.blue.shade800,     // Синий цвет текста
                        fontWeight: FontWeight.bold,     // Жирный шрифт
                        fontSize: 12,                    // Размер 12px
                      ),                                 // Завершение TextStyle
                    ),                                   // Завершение Text номера
                  ),                                     // Завершение Container номера
                  const SizedBox(width: 8),              // Промежуток
                  Text(                                  // Индикатор автора
                    'Автор: ID ${post.userId}',          // Текст с идентификатором автора
                    style: TextStyle(                    // Стилизация текста автора
                      color: Colors.grey.shade600,       // Серый цвет
                      fontSize: 12,                      // Размер 12px
                    ),                                   // Завершение TextStyle
                  ),                                     // Завершение Text автора
                  const Spacer(),                        // Занимаем свободное пространство справа
                  if (post.isLocal)                      // Проверка требования ТЗ Задание F: пометка «создан локально»
                    Container(                           // Зеленый бейдж локально созданного поста
                      padding: const EdgeInsets.symmetric( // Отступы бейджа
                        horizontal: 8,                   // Горизонтальный отступ 8px
                        vertical: 3,                     // Вертикальный отступ 3px
                      ),                                 // Завершение padding
                      decoration: BoxDecoration(         // Декорация бейджа
                        color: Colors.green.shade100,    // Светло-зеленый фон
                        borderRadius: BorderRadius.circular(6), // Радиус 6px
                        border: Border.all(color: Colors.green.shade600), // Зеленая граница
                      ),                                 // Завершение BoxDecoration
                      child: Text(                       // Текст бейджа
                        'создан локально',               // Точный текст пометки из ТЗ
                        style: TextStyle(                // Стиль пометки
                          color: Colors.green.shade900,  // Темно-зеленый цвет
                          fontSize: 11,                  // Мелкий размер 11px
                          fontWeight: FontWeight.w600,   // Полужирный
                        ),                               // Завершение TextStyle
                      ),                                 // Завершение Text
                    ),                                   // Завершение Container бейджа
                ],                                       // Завершение children Row
              ),                                         // Завершение Row
              const SizedBox(height: 10),                // Отступ между заголовком и метаданными
              Text(                                      // Заголовок публикации
                post.title,                              // Текст заголовка
                maxLines: 2,                             // Ограничение максимум 2 строками
                overflow: TextOverflow.ellipsis,         // Троеточие при превышении длины
                style: const TextStyle(                  // Стилизация заголовка
                  fontSize: 16,                          // Размер 16px
                  fontWeight: FontWeight.bold,           // Полужирный шрифт
                  height: 1.25,                          // Межстрочный интервал
                ),                                       // Завершение TextStyle
              ),                                         // Завершение Text заголовка
              const SizedBox(height: 6),                 // Отступ между заголовком и текстом
              Text(                                      // Текст превью публикации
                post.body,                               // Содержимое поста
                maxLines: 3,                             // Максимум 3 строки превью
                overflow: TextOverflow.ellipsis,         // Троеточие в конце превью
                style: TextStyle(                        // Стилизация превью
                  fontSize: 13,                          // Размер 13px
                  color: Colors.grey.shade700,           // Нейтральный серый цвет
                  height: 1.35,                          // Межстрочный интервал
                ),                                       // Завершение TextStyle
              ),                                         // Завершение Text превью
            ],                                           // Завершение children Column
          ),                                             // Завершение Column
        ),                                               // Завершение Padding
      ),                                                 // Завершение InkWell
    );                                                   // Завершение Card
  }                                                      // Конец build
}                                                        // Конец класса PostCard
