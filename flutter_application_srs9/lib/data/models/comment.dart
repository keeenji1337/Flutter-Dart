import 'package:equatable/equatable.dart';               // Библиотека Equatable для корректного сравнения моделей
import 'package:json_annotation/json_annotation.dart';     // Аннотации json_serializable для автогенерации кода

part 'comment.g.dart';                                   // Файл генерации сериализатора для модели Comment

@JsonSerializable()                                      // Аннотация: генерировать _$CommentFromJson и _$CommentToJson
class Comment extends Equatable {                        // Модель комментария к посту
  final int id;                                          // Идентификатор комментария
  final int postId;                                      // Идентификатор поста, к которому оставлен комментарий
  final String name;                                     // Заголовок или имя автора комментария
  final String email;                                    // Email автора комментария
  final String body;                                     // Текст комментария

  const Comment({                                        // Конструктор модели Comment
    required this.id,                                    // Обязательный ID комментария
    required this.postId,                                // Обязательный ID поста
    required this.name,                                  // Обязательное имя/заголовок
    required this.email,                                 // Обязательный email
    required this.body,                                  // Обязательное тело комментария
  });                                                    // Завершение конструктора

  factory Comment.fromJson(Map<String, dynamic> json) {  // Безопасный парсинг комментария из JSON
    try {                                                // Перехват непредвиденных исключений формата
      return _$CommentFromJson(json);                    // Вызов сгенерированного парсера
    } catch (_) {                                        // Обработка отсутствующих или неверных типов
      return Comment(                                    // Возврат безопасного объекта по умолчанию
        id: json['id'] is int ? json['id'] as int : 0,   // Чтение ID или 0
        postId: json['postId'] is int ? json['postId'] as int : 0, // Чтение postId или 0
        name: json['name']?.toString() ?? 'Без названия', // Fallback для имени
        email: json['email']?.toString() ?? '',          // Fallback для почты
        body: json['body']?.toString() ?? '',            // Fallback для текста
      );                                                 // Завершение создания fallback Comment
    }                                                    // Конец блока catch
  }                                                      // Конец Comment.fromJson

  Map<String, dynamic> toJson() => _$CommentToJson(this); // Преобразование модели Comment в JSON Map

  @override                                              // Свойства для сравнения двух комментариев на равенство
  List<Object?> get props => [id, postId, name, email, body]; // Равенство по всем полям
}                                                        // Конец класса Comment
