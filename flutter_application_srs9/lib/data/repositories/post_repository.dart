import 'package:dio/dio.dart';                           // Библиотека Dio для перехвата сетевых ошибок
import '../../core/error/app_exception.dart';             // Доменная модель исключений приложения
import '../local/post_cache.dart';                       // Локальное кэш-хранилище постов
import '../models/comment.dart';                         // Модель комментария
import '../models/post.dart';                            // Модель поста
import '../models/user.dart';                            // Модель автора
import '../remote/post_api.dart';                         // Retrofit REST-клиент

class PostRepository {                                   // Репозиторий: координирует работу удаленного API и локального кэша
  final PostApi postApi;                                 // Удаленный источник данных (Retrofit)
  final PostCache postCache;                             // Локальный источник данных (SharedPreferences)

  PostRepository({                                       // Конструктор репозитория с возможностью внедрения зависимостей (DI)
    required this.postApi,                               // Внедрение настроенного Retrofit API
    required this.postCache,                             // Внедрение локального кэша
  });                                                    // Завершение конструктора

  PostApi get _postApi => postApi;                       // Приватный геттер для внутреннего использования
  PostCache get _postCache => postCache;                 // Приватный геттер для кэша

  Future<List<Post>> getCachedPosts() async {            // Метод мгновенного чтения кэшированных постов с устройства
    try {                                                // Безопасное чтение из кэша
      return await _postCache.getCachedPosts();          // Возвращаем список ранее сохраненных постов
    } catch (e) {                                        // Обработка непредвиденных сбоев при чтении диска
      return [];                                         // Возврат пустого списка при любой локальной ошибке
    }                                                    // Конец catch
  }                                                      // Конец getCachedPosts

  Future<bool> hasCachedPosts() async {                  // Проверка наличия закэшированных данных
    return await _postCache.hasCachedPosts();            // Делегируем вызов сервису кэша
  }                                                      // Конец hasCachedPosts

  Future<DateTime?> getLastCacheUpdate() async {         // Получение времени последней синхронизации кэша
    return await _postCache.getLastUpdated();            // Делегируем сервису кэширования
  }                                                      // Конец getLastCacheUpdate

  Future<List<Post>> getPostsFromServer({                // Метод загрузки постов с удаленного сервера с пагинацией
    required int page,                                   // Номер загружаемой страницы
    required int limit,                                  // Количество элементов на странице
    int? userId,                                         // Необязательный фильтр по автору
  }) async {                                             // Начало асинхронного метода
    try {                                                // Перехват исключений при сетевом обращении
      List<Post> posts;                                  // Объявляем список для сохранения полученных постов
      if (userId != null) {                              // Если задан фильтр по автору поста
        posts = await _postApi.getPostsByUserId(         // Выполняем GET-запрос с фильтром по userId
          userId,                                        // Идентификатор выбранного автора
          page,                                          // Страница для автора
          limit,                                         // Лимит на страницу
        );                                               // Завершение getPostsByUserId
      } else {                                           // Если запрашивается общий список постов всех пользователей
        posts = await _postApi.getPosts(page, limit);    // Выполняем GET-запрос получения постов с пагинацией
      }                                                  // Конец ветки условия фильтра

      if (page == 1 && userId == null && posts.isNotEmpty) { // Если успешно загрузили первую страницу общего каталога
        await _postCache.savePosts(posts);               // Обновляем локальный кэш свежими серверными данными
      }                                                  // Конец сохранения в кэш

      return posts;                                      // Возвращаем загруженный список постов в вызывающий слой
    } on DioException catch (dioError) {                 // Перехват сетевых ошибок библиотеки Dio
      if (dioError.error is AppException) {              // Если ошибка уже преобразована нашим интерцептором
        throw dioError.error as AppException;            // Пробрасываем типизированный AppException
      }                                                  // Конец проверки
      throw AppException.fromDioException(dioError);     // Преобразуем непредвиденный DioException в AppException
    } catch (e) {                                        // Перехват любых прочих ошибок
      throw UnknownException(                            // Оборачиваем в неизвестную ошибку
        message: 'Не удалось загрузить публикации: $e',  // Пользовательское пояснение
        originalError: e,                                // Исходная ошибка
      );                                                 // Завершение UnknownException
    }                                                    // Конец catch
  }                                                      // Конец метода getPostsFromServer

  Future<Post> getPostById(int id) async {               // Получение детальной информации о посте по его идентификатору
    try {                                                // Сетевой запрос одного поста
      return await _postApi.getPostById(id);             // Вызов Retrofit GET /posts/{id}
    } on DioException catch (dioError) {                 // Перехват сетевой ошибки
      if (dioError.error is AppException) {              // Проверка наличия AppException
        throw dioError.error as AppException;            // Проброс AppException
      }                                                  // Конец проверки
      throw AppException.fromDioException(dioError);     // Преобразование в AppException
    } catch (e) {                                        // Обработка остальных сбоев
      throw UnknownException(                            // Оборачивание в UnknownException
        message: 'Не удалось загрузить публикацию #$id: $e', // Описание ошибки
        originalError: e,                                // Исходный сбой
      );                                                 // Завершение throw
    }                                                    // Конец catch
  }                                                      // Конец getPostById

  Future<List<Comment>> getCommentsByPostId(int postId) async { // Получение комментариев к посту
    try {                                                // Запрос комментариев
      return await _postApi.getCommentsByPostId(postId); // Вызов Retrofit GET /posts/{id}/comments
    } on DioException catch (dioError) {                 // Обработка DioException
      if (dioError.error is AppException) {              // Проверка типа ошибки
        throw dioError.error as AppException;            // Проброс
      }                                                  // Конец if
      throw AppException.fromDioException(dioError);     // Преобразование ошибки
    } catch (e) {                                        // Обработка прочих ошибок
      throw UnknownException(                            // Оборачивание в кастомное исключение
        message: 'Не удалось загрузить комментарии: $e', // Понятный текст
        originalError: e,                                // Исходная ошибка
      );                                                 // Завершение throw
    }                                                    // Конец catch
  }                                                      // Конец getCommentsByPostId

  Future<List<User>> getUsers() async {                  // Запрос списка всех авторов (пользователей)
    try {                                                // Сетевой вызов
      return await _postApi.getUsers();                  // Вызов Retrofit GET /users
    } on DioException catch (dioError) {                 // Обработка DioException
      if (dioError.error is AppException) {              // Проверка
        throw dioError.error as AppException;            // Проброс
      }                                                  // Конец if
      throw AppException.fromDioException(dioError);     // Преобразование ошибки
    } catch (e) {                                        // Прочие ошибки
      throw UnknownException(                            // Неизвестная ошибка
        message: 'Не удалось загрузить список авторов: $e', // Текст ошибки
        originalError: e,                                // Исходный сбой
      );                                                 // Завершение throw
    }                                                    // Конец catch
  }                                                      // Конец getUsers

  Future<User> getUserById(int id) async {               // Получение информации об авторе по ID
    try {                                                // Сетевой запрос
      return await _postApi.getUserById(id);             // Вызов Retrofit GET /users/{id}
    } on DioException catch (dioError) {                 // Ошибка Dio
      if (dioError.error is AppException) {              // Проверка
        throw dioError.error as AppException;            // Проброс
      }                                                  // Конец if
      throw AppException.fromDioException(dioError);     // Преобразование
    } catch (e) {                                        // Другие сбои
      throw UnknownException(                            // Неизвестная ошибка
        message: 'Не удалось загрузить автора #$id: $e', // Описание
        originalError: e,                                // Ссылка на сбой
      );                                                 // Завершение throw
    }                                                    // Конец catch
  }                                                      // Конец getUserById

  Future<Post> createPost({                              // Создание поста с отправкой POST на сервер
    required String title,                               // Заголовок публикации (5-100 символов)
    required String body,                                // Текст публикации (10-1000 символов)
    required int userId,                                 // Выбранный автор публикации
  }) async {                                             // Начало асинхронного метода создания
    try {                                                // Блок отправки запроса создания
      final payload = {                                  // Формируем словарь полезной нагрузки для POST-запроса
        'title': title,                                  // Поле заголовка
        'body': body,                                    // Поле содержимого
        'userId': userId,                                // Поле идентификатора автора
      };                                                 // Завершение формирования JSON payload
      final serverPost = await _postApi.createPost(payload); // Отправляем Retrofit POST /posts
      return serverPost.copyWith(isLocal: true);         // Помечаем пост флагом «создан локально»
    } on DioException catch (dioError) {                 // Обработка ошибки отправки
      if (dioError.error is AppException) {              // Проверка AppException
        throw dioError.error as AppException;            // Проброс
      }                                                  // Конец if
      throw AppException.fromDioException(dioError);     // Преобразование в AppException
    } catch (e) {                                        // Обработка прочих ошибок
      throw UnknownException(                            // Оборачивание
        message: 'Не удалось создать публикацию: $e',    // Сообщение об ошибке отправки
        originalError: e,                                // Исходная ошибка
      );                                                 // Завершение throw
    }                                                    // Конец catch
  }                                                      // Конец createPost
}                                                        // Конец класса PostRepository
