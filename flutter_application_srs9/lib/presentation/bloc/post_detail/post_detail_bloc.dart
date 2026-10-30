import 'package:flutter_bloc/flutter_bloc.dart';            // Библиотека Bloc для управления состоянием экрана деталей
import '../../../core/error/app_exception.dart';             // Доменные исключения для разбора ошибок
import '../../../data/models/comment.dart';              // Модель комментария
import '../../../data/models/post.dart';                 // Модель публикации
import '../../../data/models/user.dart';                 // Модель автора
import '../../../data/repositories/post_repository.dart'; // Репозиторий данных
import 'post_detail_event.dart';                         // События экрана деталей
import 'post_detail_state.dart';                         // Состояния экрана деталей

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> { // BLoC детальной страницы публикации
  final PostRepository postRepository;                  // Экземпляр репозитория

  PostDetailBloc({required this.postRepository})         // Конструктор с инъекцией репозитория
      : super(const PostDetailState()) {                 // Начальное состояние
    on<PostDetailRequested>(_onDetailRequested);         // Регистрация обработчика события запроса данных
  }                                                      // Конец конструктора

  PostRepository get _postRepository => postRepository;  // Геттер репозитория для совместимости

  Future<void> _onDetailRequested(                       // Метод загрузки поста, его комментариев и автора
    PostDetailRequested event,                           // Объект входящего события
    Emitter<PostDetailState> emit,                       // Эмиттер новых состояний
  ) async {                                              // Начало асинхронного метода
    emit(state.copyWith(                                 // Переходим в статус загрузки
      status: PostDetailStatus.loading,                  // Статус «загрузка»
      post: event.initialPost,                           // Отображаем имеющиеся данные поста сразу (если переданы)
      clearError: true,                                  // Очищаем прошлые ошибки
    ));                                                  // Завершение первичного emit

    try {                                                // Блок параллельной/последовательной загрузки данных
      Post post = event.initialPost ??                   // Берем переданный пост или запрашиваем его с сервера
          await _postRepository.getPostById(event.postId); // Запрос Retrofit GET /posts/{id}

      List<Comment> comments = const [];                 // Инициализируем пустой список комментариев
      try {                                              // Запрос комментариев поста
        comments = await _postRepository.getCommentsByPostId(event.postId); // Retrofit GET /posts/{id}/comments
      } catch (_) {                                      // Если комментарии не загрузились, не роняем весь экран
        comments = const [];                             // Оставляем пустым
      }                                                  // Конец catch комментариев

      User? author;                                      // Переменная для сохранения автора
      try {                                              // Запрос сведений об авторе
        author = await _postRepository.getUserById(post.userId); // Retrofit GET /users/{id}
      } catch (_) {                                      // Если автор не загрузился
        author = null;                                   // Оставляем null
      }                                                  // Конец catch автора

      emit(state.copyWith(                               // Отправляем успешное состояние со всеми загруженными данными
        status: PostDetailStatus.success,                // Статус «успешно»
        post: post,                                      // Полный объект поста
        comments: comments,                              // Список полученных комментариев
        author: author,                                  // Объект автора с компанией и адресом
      ));                                                // Завершение отправки состояния
    } catch (e) {                                        // Обработка общей критической ошибки загрузки
      final message = e is AppException                  // Извлекаем человекочитаемый текст
          ? e.message                                    // Текст из AppException
          : 'Не удалось загрузить подробности поста: $e'; // Текст по умолчанию
      emit(state.copyWith(                               // Отправляем состояние ошибки
        status: PostDetailStatus.error,                  // Статус «ошибка»
        errorMessage: message,                           // Текст ошибки для пользователя
      ));                                                // Завершение emit ошибки
    }                                                    // Конец catch
  }                                                      // Конец метода _onDetailRequested
}                                                        // Конец класса PostDetailBloc
