import 'package:equatable/equatable.dart';               // Сравнение состояний BLoC
import '../../../data/models/comment.dart';              // Модель комментария
import '../../../data/models/post.dart';                 // Модель публикации
import '../../../data/models/user.dart';                 // Модель автора

enum PostDetailStatus {                                  // Статусы загрузки детальной информации
  initial,                                               // Начальное состояние
  loading,                                               // Загрузка поста, комментариев и автора
  success,                                               // Все данные успешно загружены
  error,                                                 // Ошибка при получении данных
}                                                        // Конец перечисления PostDetailStatus

class PostDetailState extends Equatable {                // Класс состояния экрана подробностей поста
  final PostDetailStatus status;                         // Текущий статус работы BLoC
  final Post? post;                                      // Объект отображаемой публикации
  final List<Comment> comments;                          // Список комментариев к этой публикации
  final User? author;                                    // Информация об авторе публикации (User)
  final String? errorMessage;                            // Текст ошибки для пользователя

  const PostDetailState({                                // Конструктор состояния детального экрана
    this.status = PostDetailStatus.initial,              // Начальный статус
    this.post,                                           // Пустой пост по умолчанию
    this.comments = const [],                            // Пустой список комментариев по умолчанию
    this.author,                                         // Пустой автор по умолчанию
    this.errorMessage,                                   // Нет ошибок по умолчанию
  });                                                    // Завершение конструктора

  PostDetailState copyWith({                             // Метод копирования состояния с модификацией
    PostDetailStatus? status,                            // Новый статус
    Post? post,                                          // Новый пост
    List<Comment>? comments,                             // Новый список комментариев
    User? author,                                        // Новый автор
    String? errorMessage,                                // Текст ошибки
    bool clearError = false,                             // Принудительный сброс ошибки
  }) {                                                   // Начало copyWith
    return PostDetailState(                              // Возврат обновленного объекта
      status: status ?? this.status,                     // Обновляем статус
      post: post ?? this.post,                           // Обновляем пост
      comments: comments ?? this.comments,               // Обновляем комментарии
      author: author ?? this.author,                     // Обновляем автора
      errorMessage: clearError                           // Проверка сброса ошибки
          ? null                                         // Обнуляем ошибку
          : (errorMessage ?? this.errorMessage),         // Или сохраняем значение
    );                                                   // Завершение создания копии
  }                                                      // Конец copyWith

  @override                                              // Свойства Equatable для сравнения состояний
  List<Object?> get props => [status, post, comments, author, errorMessage]; // Равенство по всем полям
}                                                        // Конец класса PostDetailState
