import 'package:equatable/equatable.dart';               // Сравнение состояний BLoC для оптимизации перерисовки UI
import '../../../data/models/post.dart';                 // Модель публикации

enum PostListStatus {                                    // Перечисление основных состояний экрана списка постов
  initial,                                               // Начальное состояние до запуска каких-либо операций
  loading,                                               // Состояние активной первичной загрузки данных
  cached,                                                // Состояние отображения кэша (пока идет фоновый запрос или при офлайне)
  success,                                               // Состояние успешного получения актуальных данных с сервера
  empty,                                                 // Состояние отсутствия данных (пустой список или ничего не найдено)
  error,                                                 // Состояние ошибки загрузки с сервера
}                                                        // Конец перечисления PostListStatus

class PostListState extends Equatable {                  // Класс состояния списка постов
  final PostListStatus status;                           // Текущий статус работы BLoC
  final List<Post> posts;                                // Исходный список постов, загруженный с сервера/кэша
  final List<Post> displayedPosts;                       // Отфильтрованный и отсортированный список для отображения в UI
  final int page;                                        // Текущий номер страницы пагинации (начиная с 1)
  final bool hasReachedMax;                              // Флаг достижения конца списка (нет больше страниц)
  final bool isLoadingMore;                              // Флаг активного процесса подгрузки следующей страницы
  final String? paginationError;                         // Ошибка при подгрузке следующей страницы (для кнопки «Повторить»)
  final bool isCached;                                   // Флаг: отображаются ли сейчас локально кэшированные данные
  final String? errorMessage;                            // Текст ошибки основного экрана для пользователя
  final int? selectedUserId;                             // Выбранный ID автора для фильтрации (или null для всех)
  final String searchQuery;                              // Текущий текст поиска по заголовку
  final bool sortAscending;                              // Направление сортировки по ID (true = по возрастанию)

  const PostListState({                                  // Конструктор состояния списка постов со значениями по умолчанию
    this.status = PostListStatus.initial,                // По умолчанию состояние initial
    this.posts = const [],                               // По умолчанию исходный список пуст
    this.displayedPosts = const [],                      // По умолчанию отображаемый список пуст
    this.page = 1,                                       // По умолчанию 1-я страница
    this.hasReachedMax = false,                          // По умолчанию конец списка не достигнут
    this.isLoadingMore = false,                          // По умолчанию подгрузка не активна
    this.paginationError,                                // Ошибки пагинации нет
    this.isCached = false,                               // По умолчанию данные не из кэша
    this.errorMessage,                                   // Ошибки экрана нет
    this.selectedUserId,                                 // Фильтр автора выключен
    this.searchQuery = '',                               // Строка поиска пуста
    this.sortAscending = true,                           // Сортировка по возрастанию ID
  });                                                    // Завершение конструктора

  PostListState copyWith({                               // Метод копирования состояния с выборочной модификацией полей
    PostListStatus? status,                              // Новый статус
    List<Post>? posts,                                   // Новый исходный список постов
    List<Post>? displayedPosts,                          // Новый отображаемый список постов
    int? page,                                           // Новая страница
    bool? hasReachedMax,                                 // Новый флаг конца списка
    bool? isLoadingMore,                                 // Новый флаг загрузки страницы
    String? paginationError,                             // Новая ошибка пагинации (или null при сбросе)
    bool clearPaginationError = false,                   // Признак необходимости принудительно занулить ошибку пагинации
    bool? isCached,                                      // Новый флаг кэшированности
    String? errorMessage,                                // Новое сообщение об ошибке
    bool clearErrorMessage = false,                      // Признак принудительного сброса ошибки экрана
    int? selectedUserId,                                 // Новый ID автора
    bool clearSelectedUser = false,                      // Принудительный сброс фильтра по автору
    String? searchQuery,                                 // Новая поисковая строка
    bool? sortAscending,                                 // Новое направление сортировки
  }) {                                                   // Начало тела copyWith
    return PostListState(                                // Возвращаем новый неизменяемый объект состояния
      status: status ?? this.status,                     // Сохраняем или обновляем статус
      posts: posts ?? this.posts,                         // Сохраняем или обновляем исходные посты
      displayedPosts: displayedPosts ?? this.displayedPosts, // Сохраняем или обновляем отфильтрованные посты
      page: page ?? this.page,                           // Сохраняем или обновляем номер страницы
      hasReachedMax: hasReachedMax ?? this.hasReachedMax, // Флаг конца списка
      isLoadingMore: isLoadingMore ?? this.isLoadingMore, // Флаг фоновой пагинации
      paginationError: clearPaginationError              // Проверка сброса ошибки пагинации
          ? null                                         // Обнуляем ошибку при явном флаге
          : (paginationError ?? this.paginationError),   // Иначе берем новое или старое значение
      isCached: isCached ?? this.isCached,               // Обновляем признак кэша
      errorMessage: clearErrorMessage                    // Проверка сброса текста ошибки
          ? null                                         // Обнуляем текст ошибки
          : (errorMessage ?? this.errorMessage),         // Иначе обновляем
      selectedUserId: clearSelectedUser                  // Проверка сброса автора
          ? null                                         // Сбрасываем выбранного автора
          : (selectedUserId ?? this.selectedUserId),     // Иначе устанавливаем выбранного автора
      searchQuery: searchQuery ?? this.searchQuery,      // Обновляем поисковый запрос
      sortAscending: sortAscending ?? this.sortAscending, // Обновляем порядок сортировки
    );                                                   // Завершение создания копии
  }                                                      // Конец метода copyWith

  @override                                              // Свойства Equatable для сравнения состояний
  List<Object?> get props => [                           // Список параметров равенства
        status,                                          // Статус
        posts,                                           // Исходные посты
        displayedPosts,                                  // Отображаемые посты
        page,                                            // Страница
        hasReachedMax,                                   // Конец пагинации
        isLoadingMore,                                   // Загрузка следующей страницы
        paginationError,                                 // Ошибка пагинации
        isCached,                                        // Признак кэша
        errorMessage,                                    // Текст ошибки
        selectedUserId,                                  // Выбранный автор
        searchQuery,                                     // Поисковая фраза
        sortAscending,                                   // Направление сортировки
      ];                                                 // Завершение props
}                                                        // Конец класса PostListState
