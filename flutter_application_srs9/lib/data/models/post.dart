import 'package:equatable/equatable.dart';               // Библиотека Equatable для сравнения объектов по значениям
import 'package:json_annotation/json_annotation.dart';     // Аннотации для библиотеки json_serializable

part 'post.g.dart';                                      // Связываем сгенерированный файл логики парсинга JSON

@JsonSerializable()                                      // Аннотация: сгенерировать методы _$PostFromJson и _$PostToJson
class Post extends Equatable {                          // Модель публикации (поста), реализует Equatable
  final int? id;                                         // Идентификатор поста (может быть null до назначения сервером)
  final int userId;                                      // Идентификатор автора (пользователя, создавшего пост)
  final String title;                                    // Заголовок публикации
  final String body;                                     // Текст (содержимое) публикации
  @JsonKey(defaultValue: false)                          // Значение по умолчанию для сериализатора (false)
  final bool isLocal;                                    // Флаг: создан ли пост локально в текущей сессии пользователя

  const Post({                                           // Конструктор модели Post с именованными параметрами
    this.id,                                             // Необязательный ID (для новых локальных постов)
    required this.userId,                                // Обязательный ID автора
    required this.title,                                 // Обязательный заголовок
    required this.body,                                  // Обязательный текст поста
    this.isLocal = false,                                // По умолчанию пост считается серверным (не локальным)
  });                                                    // Завершение конструктора Post

  factory Post.fromJson(Map<String, dynamic> json) {     // Фабричный конструктор десериализации из JSON с защитой от сбоев
    try {                                                // Блок безопасной обработки входного словаря
      return _$PostFromJson(json);                      // Вызов кодогенерированного парсера
    } catch (_) {                                        // Если структура повреждена или типы не совпадают
      return Post(                                       // Возвращаем объект со значениями по умолчанию без сбоя приложения
        id: json['id'] is int ? json['id'] as int : null, // Безопасное приведение ID к числу
        userId: json['userId'] is int ? json['userId'] as int : 1, // Fallback ID автора
        title: json['title']?.toString() ?? 'Без заголовка', // Fallback заголовка
        body: json['body']?.toString() ?? '',            // Fallback текста поста
        isLocal: json['isLocal'] == true,                // Сохранение признака локального поста
      );                                                 // Завершение fallback объекта
    }                                                    // Конец catch
  }                                                      // Конец Post.fromJson

  Map<String, dynamic> toJson() => _$PostToJson(this);   // Преобразование объекта Post в JSON Map для отправки по сети

  Post copyWith({                                        // Метод клонирования объекта с частичной заменой полей
    int? id,                                             // Новый идентификатор
    int? userId,                                         // Новый автор
    String? title,                                       // Новый заголовок
    String? body,                                        // Новый текст
    bool? isLocal,                                       // Новый признак локального поста
  }) {                                                   // Начало метода copyWith
    return Post(                                         // Возврат нового объекта Post с обновленными или старыми полями
      id: id ?? this.id,                                 // Если не передан новый id, берем текущий
      userId: userId ?? this.userId,                     // Если не передан userId, берем текущий
      title: title ?? this.title,                        // Если не передан title, берем текущий
      body: body ?? this.body,                           // Если не передан body, берем текущий
      isLocal: isLocal ?? this.isLocal,                  // Если не передан isLocal, берем текущий
    );                                                   // Завершение создания копии
  }                                                      // Конец метода copyWith

  @override                                              // Свойства Equatable для сравнения объектов поста
  List<Object?> get props => [id, userId, title, body, isLocal]; // Список полей для вычисления равенства
}                                                        // Конец класса Post
