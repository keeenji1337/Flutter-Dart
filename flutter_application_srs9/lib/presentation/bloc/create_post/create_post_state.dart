import 'package:equatable/equatable.dart';               // Сравнение состояний
import '../../../data/models/post.dart';                 // Модель созданного поста
import '../../../data/models/user.dart';                 // Модель автора для списка

enum CreatePostStatus {                                  // Статусы процесса создания публикации
  initial,                                               // Начальное состояние формы
  submitting,                                            // Отправка формы на сервер (кнопка заблокирована)
  success,                                               // Пост успешно создан сервером
  failure,                                               // Ошибка отправки или валидации
}                                                        // Конец перечисления CreatePostStatus

class CreatePostState extends Equatable {                // Состояние экрана создания поста
  final CreatePostStatus status;                         // Статус процесса создания
  final List<User> users;                                // Список пользователей для выпадающего меню автора
  final bool isLoadingUsers;                             // Флаг загрузки списка авторов
  final Post? createdPost;                               // Объект созданного поста, возвращенный сервером
  final String? errorMessage;                            // Сообщение об ошибке валидации или сети

  const CreatePostState({                                // Конструктор состояния создания поста
    this.status = CreatePostStatus.initial,              // Начальный статус
    this.users = const [],                               // Пустой список авторов
    this.isLoadingUsers = false,                         // Загрузка авторов не активна
    this.createdPost,                                    // Созданного поста пока нет
    this.errorMessage,                                   // Ошибки нет
  });                                                    // Завершение конструктора

  bool get isSubmitting => status == CreatePostStatus.submitting; // Геттер: идет ли сейчас активная отправка запроса

  CreatePostState copyWith({                             // Метод создания копии с обновлением полей
    CreatePostStatus? status,                            // Новый статус
    List<User>? users,                                   // Новый список авторов
    bool? isLoadingUsers,                                // Флаг загрузки авторов
    Post? createdPost,                                   // Созданный пост
    String? errorMessage,                                // Текст ошибки
    bool clearError = false,                             // Флаг сброса ошибки
  }) {                                                   // Начало метода copyWith
    return CreatePostState(                              // Возврат нового состояния
      status: status ?? this.status,                     // Обновление статуса
      users: users ?? this.users,                         // Обновление списка авторов
      isLoadingUsers: isLoadingUsers ?? this.isLoadingUsers, // Обновление флага загрузки
      createdPost: createdPost ?? this.createdPost,       // Обновление созданного объекта
      errorMessage: clearError                           // Проверка сброса текста ошибки
          ? null                                         // Обнуляем текст
          : (errorMessage ?? this.errorMessage),         // Или сохраняем переданный
    );                                                   // Завершение создания копии
  }                                                      // Конец метода copyWith

  @override                                              // Свойства Equatable
  List<Object?> get props => [status, users, isLoadingUsers, createdPost, errorMessage]; // Равенство полей
}                                                        // Конец класса CreatePostState
