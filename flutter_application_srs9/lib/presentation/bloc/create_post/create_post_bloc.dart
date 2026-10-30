import 'package:flutter_bloc/flutter_bloc.dart';            // Библиотека Bloc для управления созданием публикации
import '../../../core/error/app_exception.dart';             // Доменные ошибки
import '../../../data/repositories/post_repository.dart'; // Репозиторий постов
import 'create_post_event.dart';                           // События создания поста
import 'create_post_state.dart';                           // Состояния создания поста

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> { // BLoC экрана создания публикации
  final PostRepository postRepository;                  // Экземпляр репозитория

  CreatePostBloc({required this.postRepository})         // Конструктор с инъекцией репозитория
      : super(const CreatePostState()) {                 // Начальное состояние формы
    on<CreatePostUsersRequested>(_onUsersRequested);     // Обработчик загрузки авторов
    on<CreatePostSubmitted>(_onSubmitted);               // Обработчик валидации и отправки формы
  }                                                      // Конец конструктора

  PostRepository get _postRepository => postRepository;  // Геттер репозитория для совместимости

  Future<void> _onUsersRequested(                        // Метод получения списка пользователей для селектора
    CreatePostUsersRequested event,                      // Событие запроса авторов
    Emitter<CreatePostState> emit,                       // Эмиттер состояния
  ) async {                                              // Начало асинхронного метода
    emit(state.copyWith(isLoadingUsers: true));          // Включаем флаг загрузки пользователей
    try {                                                // Запрос списка авторов
      final users = await _postRepository.getUsers();    // Вызов Retrofit GET /users
      emit(state.copyWith(                               // Сохраняем авторов в состояние
        isLoadingUsers: false,                           // Выключаем флаг загрузки
        users: users,                                    // Сохраняем полученных пользователей
      ));                                                // Завершение emit
    } catch (_) {                                        // Если авторы не загрузились
      emit(state.copyWith(isLoadingUsers: false));       // Просто отключаем лоадер
    }                                                    // Конец catch
  }                                                      // Конец метода _onUsersRequested

  Future<void> _onSubmitted(                             // Метод валидации данных и отправки POST-запроса
    CreatePostSubmitted event,                           // Данные введенной формы
    Emitter<CreatePostState> emit,                       // Эмиттер состояния
  ) async {                                              // Начало метода отправки
    if (state.isSubmitting) return;                      // Защита от повторного нажатия во время отправки (ТЗ Задание F)

    final title = event.title.trim();                    // Обрезаем лишние пробелы в заголовке
    final body = event.body.trim();                      // Обрезаем лишние пробелы в теле публикации

    if (title.length < 5 || title.length > 100) {        // Валидация заголовка: от 5 до 100 символов (ТЗ Задание F)
      emit(state.copyWith(                               // Выводим ошибку валидации заголовка
        status: CreatePostStatus.failure,                // Статус сбоя
        errorMessage: 'Заголовок должен содержать от 5 до 100 символов (сейчас: ${title.length})', // Текст ошибки
      ));                                                // Завершение emit ошибки
      return;                                            // Прерываем отправку
    }                                                    // Конец валидации title

    if (body.length < 10 || body.length > 1000) {        // Валидация текста: от 10 до 1000 символов (ТЗ Задание F)
      emit(state.copyWith(                               // Выводим ошибку валидации текста
        status: CreatePostStatus.failure,                // Статус сбоя
        errorMessage: 'Текст поста должен содержать от 10 до 1000 символов (сейчас: ${body.length})', // Текст
      ));                                                // Завершение emit ошибки
      return;                                            // Прерываем отправку
    }                                                    // Конец валидации body

    if (event.userId <= 0) {                             // Валидация выбора автора публикации
      emit(state.copyWith(                               // Ошибка отсутствия автора
        status: CreatePostStatus.failure,                // Статус сбоя
        errorMessage: 'Пожалуйста, выберите автора публикации из списка', // Сообщение
      ));                                                // Завершение emit
      return;                                            // Прерываем отправку
    }                                                    // Конец проверки автора

    emit(state.copyWith(                                 // Переходим в статус отправки запроса
      status: CreatePostStatus.submitting,               // Блокируем кнопку отправки
      clearError: true,                                  // Очищаем старые ошибки
    ));                                                  // Завершение первичного emit

    try {                                                // Блок выполнения сетевого запроса создания
      final newPost = await _postRepository.createPost(  // Отправляем POST через Retrofit
        title: title,                                    // Валидированный заголовок
        body: body,                                      // Валидированный текст
        userId: event.userId,                            // ID выбранного автора
      );                                                 // Завершение вызова createPost

      emit(state.copyWith(                               // Успешный результат создания публикации
        status: CreatePostStatus.success,                // Статус «успешно создан»
        createdPost: newPost,                            // Сохраняем созданный объект поста
      ));                                                // Завершение отправки состояния успеха
    } catch (e) {                                        // Обработка сетевой или серверной ошибки
      final msg = e is AppException                      // Формируем текст ошибки
          ? e.message                                    // Сообщение из AppException
          : 'Не удалось отправить публикацию на сервер: $e'; // Общее сообщение
      emit(state.copyWith(                               // Отправляем ошибку
        status: CreatePostStatus.failure,                // Статус сбоя
        errorMessage: msg,                               // Текст ошибки для пользователя
      ));                                                // Завершение emit ошибки
    }                                                    // Конец catch
  }                                                      // Конец метода _onSubmitted
}                                                        // Конец класса CreatePostBloc
