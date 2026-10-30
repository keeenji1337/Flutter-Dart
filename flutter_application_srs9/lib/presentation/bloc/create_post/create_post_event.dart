import 'package:equatable/equatable.dart';               // Сравнение объектов событий

abstract class CreatePostEvent extends Equatable {       // Базовое событие экрана создания публикации
  const CreatePostEvent();                               // Базовый конструктор

  @override                                              // Свойства Equatable
  List<Object?> get props => [];                         // Пустой список свойств
}                                                        // Конец базового события

class CreatePostUsersRequested extends CreatePostEvent { // Событие загрузки списка авторов для выбора в выпадающем списке
  const CreatePostUsersRequested();                      // Константный конструктор
}                                                        // Конец события CreatePostUsersRequested

class CreatePostSubmitted extends CreatePostEvent {      // Событие отправки формы создания поста на сервер
  final String title;                                    // Заголовок поста (от 5 до 100 символов)
  final String body;                                     // Текст публикации (от 10 до 1000 символов)
  final int userId;                                      // Идентификатор выбранного автора

  const CreatePostSubmitted({                            // Конструктор события отправки формы
    required this.title,                                 // Обязательный заголовок
    required this.body,                                  // Обязательный текст
    required this.userId,                                // Обязательный автор
  });                                                    // Завершение конструктора

  @override                                              // Свойства для сравнения
  List<Object?> get props => [title, body, userId];      // Равенство по всем полям формы
}                                                        // Конец события CreatePostSubmitted
