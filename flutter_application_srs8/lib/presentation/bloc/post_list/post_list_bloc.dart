import 'package:flutter_bloc/flutter_bloc.dart';            // Библиотека Bloc для реактивного управления состоянием
import '../../../core/error/app_exception.dart';             // Доменные исключения для разбора ошибок
import '../../../data/models/post.dart';                 // Модель публикации
import '../../../data/repositories/post_repository.dart'; // Репозиторий постов
import 'post_list_event.dart';                           // События BLoC списка постов
import 'post_list_state.dart';                           // Состояния BLoC списка постов

class PostListBloc extends Bloc<PostListEvent, PostListState> { // BLoC управления списком постов, пагинацией и поиском
  static const int _pageSize = 10;                       // Константа: размер одной страницы (10 элементов согласно ТЗ)
  final PostRepository postRepository;                  // Экземпляр репозитория для выполнения запросов и работы с кэшем

  PostListBloc({required this.postRepository})           // Конструктор с инъекцией репозитория
      : super(const PostListState()) {                   // Инициализируем BLoC с начальным пустым состоянием
    on<PostListStarted>(_onStarted);                     // Регистрируем обработчик события старта экрана
    on<PostListRefreshed>(_onRefreshed);                 // Регистрируем обработчик pull-to-refresh
    on<PostListNextPageRequested>(_onNextPageRequested); // Регистрируем обработчик пагинации (следующая страница)
    on<PostListAuthorFilterChanged>(_onAuthorFilterChanged); // Обработчик выбора автора в фильтре
    on<PostListSearchQueryChanged>(_onSearchQueryChanged); // Обработчик ввода текста в поисковую строку
    on<PostListSortToggleRequested>(_onSortToggleRequested); // Обработчик смены направления сортировки
    on<PostListFiltersResetRequested>(_onFiltersResetRequested); // Обработчик сброса всех примененных фильтров
    on<PostListLocalPostAdded>(_onLocalPostAdded);       // Обработчик добавления локально созданного поста
  }                                                      // Конец конструктора

  PostRepository get _postRepository => postRepository;  // Геттер репозитория для совместимости

  Future<void> _onStarted(                               // Метод обработки первичного запуска экрана
    PostListStarted event,                               // Объект входящего события старта
    Emitter<PostListState> emit,                         // Функция отправки новых состояний в UI
  ) async {                                              // Начало асинхронного метода
    final hasCache = await _postRepository.hasCachedPosts(); // Проверяем, сохранены ли посты на диске устройства
    if (hasCache) {                                      // Если локальный кэш найден на устройстве
      final cachedPosts = await _postRepository.getCachedPosts(); // Быстро считываем посты из SharedPreferences
      if (cachedPosts.isNotEmpty) {                      // Если в кэше действительно есть элементы
        emit(state.copyWith(                             // Мгновенно отображаем кэш пользователю без ожидания сети
          status: PostListStatus.cached,                 // Устанавливаем статус «отображается кэш»
          posts: cachedPosts,                            // Записываем список постов из кэша
          displayedPosts: _filterAndSort(                // Применяем текущие поисковые фильтры и сортировку
            cachedPosts,                                 // Исходный список из кэша
            state.searchQuery,                           // Текущая поисковая строка
            state.sortAscending,                         // Текущий порядок сортировки
          ),                                             // Завершение фильтрации
          isCached: true,                                // Выставляем флаг «данные взяты из кэша»
          page: 1,                                       // Начинаем с 1-й страницы
        ));                                              // Завершение отправки состояния кэша
      }                                                  // Конец проверки непустого кэша
    } else {                                             // Если кэша еще нет (первый запуск приложения)
      emit(state.copyWith(status: PostListStatus.loading)); // Показываем полноэкранный индикатор загрузки
    }                                                    // Конец проверки наличия кэша

    try {                                                // Параллельно или следом запрашиваем актуальные данные с сервера
      final serverPosts = await _postRepository.getPostsFromServer( // Выполняем сетевой Retrofit запрос
        page: 1,                                         // Запрашиваем первую страницу
        limit: _pageSize,                                // Лимит 10 постов
      );                                                 // Завершение запроса к серверу

      if (serverPosts.isEmpty) {                         // Если сервер вернул пустой список
        emit(state.copyWith(                             // Отправляем состояние пустого списка
          status: PostListStatus.empty,                  // Статус «нет данных»
          posts: const [],                               // Очищаем список
          displayedPosts: const [],                      // Очищаем видимый список
          isCached: false,                               // Данные свежие (не кэш)
          page: 1,                                       // Страница 1
          hasReachedMax: true,                           // Пагинировать больше нечего
        ));                                              // Завершение отправки пустого состояния
      } else {                                           // Если посты успешно получены с сервера
        emit(state.copyWith(                             // Отправляем успешное состояние со свежими данными
          status: PostListStatus.success,                // Статус «успех»
          posts: serverPosts,                            // Сохраняем свежие посты
          displayedPosts: _filterAndSort(                // Применяем локальный фильтр и сортировку
            serverPosts,                                 // Серверные посты
            state.searchQuery,                           // Поисковая строка
            state.sortAscending,                         // Направление сортировки
          ),                                             // Завершение фильтрации
          isCached: false,                               // Флаг: теперь отображаются актуальные серверные данные
          page: 1,                                       // Сбрасываем счетчик страниц на 1
          hasReachedMax: serverPosts.length < _pageSize, // Проверяем, есть ли следующая страница
          clearErrorMessage: true,                       // Очищаем старые ошибки
        ));                                              // Завершение отправки успешного состояния
      }                                                  // Конец ветки полученных постов
    } catch (e) {                                        // Перехват сетевых и прочих ошибок при первом запросе
      final message = e is AppException                  // Определяем текст ошибки для пользователя
          ? e.message                                    // Сообщение из типизированного AppException
          : 'Не удалось обновить данные с сервера';      // Дефолтное сообщение об ошибке
      if (state.posts.isNotEmpty) {                      // Если у нас уже отображаются кэшированные посты
        emit(state.copyWith(                             // Не удаляем кэш при сетевой ошибке (требование ТЗ)
          status: PostListStatus.cached,                 // Сохраняем статус кэша
          isCached: true,                                // Подтверждаем кэш
          errorMessage: 'Офлайн режим: показан кэш. $message', // Информируем пользователя о работе в офлайне
        ));                                              // Завершение отправки состояния
      } else {                                           // Если кэша не было и сеть недоступна
        emit(state.copyWith(                             // Отправляем состояние ошибки
          status: PostListStatus.error,                  // Статус «ошибка»
          errorMessage: message,                         // Передаем текст ошибки на экран
        ));                                              // Завершение отправки ошибки
      }                                                  // Конец проверки наличия постов
    }                                                    // Конец блока catch
  }                                                      // Конец метода _onStarted

  Future<void> _onRefreshed(                             // Метод ручного обновления (pull-to-refresh)
    PostListRefreshed event,                             // Событие обновления списка
    Emitter<PostListState> emit,                         // Функция отправки состояния
  ) async {                                              // Начало асинхронного метода
    try {                                                // Блок безопасного запроса свежих данных
      final serverPosts = await _postRepository.getPostsFromServer( // Запрос первой страницы с учетом автора
        page: 1,                                         // Первая страница
        limit: _pageSize,                                // Лимит страницы
        userId: state.selectedUserId,                    // Учитываем текущий фильтр по автору
      );                                                 // Завершение сетевого вызова

      emit(state.copyWith(                               // Обновляем список свежими данными
        status: serverPosts.isEmpty                      // Проверка на пустоту ответа
            ? PostListStatus.empty                       // Если пусто — статус empty
            : PostListStatus.success,                    // Иначе статус success
        posts: serverPosts,                              // Сохраняем новые посты
        displayedPosts: _filterAndSort(                  // Фильтруем и сортируем обновленный список
          serverPosts,                                   // Список постов
          state.searchQuery,                             // Текущий поиск
          state.sortAscending,                           // Порядок сортировки
        ),                                               // Завершение фильтрации
        page: 1,                                         // Сброс страницы на 1
        hasReachedMax: serverPosts.length < _pageSize,   // Проверка конца каталога
        isCached: false,                                 // Данные актуальные с сервера
        clearErrorMessage: true,                         // Сброс сообщений об ошибках
        clearPaginationError: true,                      // Сброс ошибок пагинации
      ));                                                // Завершение отправки состояния
    } catch (e) {                                        // Обработка ошибки при pull-to-refresh
      final msg = e is AppException ? e.message : 'Ошибка обновления: $e'; // Формируем сообщение
      emit(state.copyWith(                               // Сохраняем старые данные, но передаем сообщение об ошибке
        errorMessage: msg,                               // Показываем текст ошибки
      ));                                                // Завершение emit
    }                                                    // Конец catch
  }                                                      // Конец метода _onRefreshed

  Future<void> _onNextPageRequested(                     // Метод подгрузки следующей страницы (пагинация)
    PostListNextPageRequested event,                     // Событие запроса следующей порции постов
    Emitter<PostListState> emit,                         // Функция отправки состояния
  ) async {                                              // Начало метода пагинации
    if (state.hasReachedMax ||                           // Защита №1: достигнут конец списка постов
        state.isLoadingMore ||                           // Защита №2: запрос следующей страницы уже в процессе выполнения
        state.status == PostListStatus.loading) {        // Защита №3: экран еще выполняет первичную загрузку
      return;                                            // Предотвращаем дублирующий запрос (требование Задания C и Теста 6)
    }                                                    // Конец блока защит

    emit(state.copyWith(                                 // Выставляем флаг фоновой подгрузки для UI индикатора
      isLoadingMore: true,                               // Активируем индикатор подгрузки внизу списка
      clearPaginationError: true,                        // Очищаем предыдущую ошибку пагинации
    ));                                                  // Завершение emit

    final nextPage = state.page + 1;                     // Вычисляем номер следующей страницы
    try {                                                // Блок запроса следующей страницы
      final newPosts = await _postRepository.getPostsFromServer( // Запрашиваем порцию постов с сервера
        page: nextPage,                                  // Номер следующей страницы
        limit: _pageSize,                                // 10 элементов
        userId: state.selectedUserId,                    // Выбранный автор (если задан)
      );                                                 // Завершение запроса к серверу

      if (newPosts.isEmpty) {                            // Если сервер вернул пустой массив
        emit(state.copyWith(                             // Фиксируем конец доступных данных
          isLoadingMore: false,                          // Выключаем индикатор внизу списка
          hasReachedMax: true,                           // Помечаем, что больше страниц нет
        ));                                              // Завершение emit
        return;                                          // Завершаем обработку
      }                                                  // Конец проверки пустого списка

      final existingIds = state.posts.map((p) => p.id).toSet(); // Собираем набор уже существующих идентификаторов
      final uniqueNewPosts = newPosts                    // Фильтруем дубликаты для предотвращения смешивания данных
          .where((post) => post.id == null || !existingIds.contains(post.id)) // Оставляем только уникальные посты
          .toList();                                     // Преобразуем в список

      final updatedPosts = List<Post>.from(state.posts)..addAll(uniqueNewPosts); // Объединяем старые посты с новыми
      final hasReached = newPosts.length < _pageSize;    // Если пришло меньше лимита страницы — данных больше нет

      emit(state.copyWith(                               // Отправляем обновленный объединенный список
        isLoadingMore: false,                            // Выключаем флаг подгрузки
        posts: updatedPosts,                             // Сохраняем расширенный список постов
        displayedPosts: _filterAndSort(                  // Применяем поиск и сортировку к обновленному списку
          updatedPosts,                                  // Полный список
          state.searchQuery,                             // Текущий поиск
          state.sortAscending,                           // Порядок сортировки
        ),                                               // Завершение фильтрации
        page: nextPage,                                  // Обновляем текущий номер страницы
        hasReachedMax: hasReached,                       // Обновляем флаг конца данных
      ));                                                // Завершение emit
    } catch (e) {                                        // Обработка ошибки загрузки страницы пагинации
      final msg = e is AppException ? e.message : 'Не удалось загрузить следующую страницу: $e'; // Текст ошибки
      emit(state.copyWith(                               // Сохраняем состояние с ошибкой пагинации для кнопки «Повторить»
        isLoadingMore: false,                            // Отключаем лоадер подгрузки
        paginationError: msg,                            // Сохраняем текст ошибки пагинации
      ));                                                // Завершение emit
    }                                                    // Конец catch
  }                                                      // Конец метода _onNextPageRequested

  Future<void> _onAuthorFilterChanged(                   // Обработчик переключения фильтра по автору (userId)
    PostListAuthorFilterChanged event,                   // Событие смены автора
    Emitter<PostListState> emit,                         // Функция отправки состояния
  ) async {                                              // Начало метода фильтрации
    if (state.selectedUserId == event.userId) return;    // Если выбран тот же самый автор, ничего не делаем

    emit(state.copyWith(                                 // Сбрасываем список и пагинацию: старые результаты не смешиваются
      status: PostListStatus.loading,                    // Переходим в статус загрузки нового фильтра
      selectedUserId: event.userId,                      // Сохраняем новый ID автора
      posts: const [],                                   // Очищаем старые посты (требование Задания C)
      displayedPosts: const [],                          // Очищаем отображаемые посты
      page: 1,                                           // Сбрасываем страницу на 1
      hasReachedMax: false,                              // Сбрасываем флаг конца страниц
      clearPaginationError: true,                        // Сбрасываем ошибки пагинации
      clearErrorMessage: true,                           // Сбрасываем ошибки экрана
    ));                                                  // Завершение сброса состояния

    try {                                                // Запрашиваем посты выбранного автора
      final posts = await _postRepository.getPostsFromServer( // Вызов репозитория с фильтром по userId
        page: 1,                                         // Первая страница для автора
        limit: _pageSize,                                // Лимит 10 постов
        userId: event.userId,                            // ID выбранного автора
      );                                                 // Завершение запроса

      emit(state.copyWith(                               // Отправляем результат фильтрации
        status: posts.isEmpty                            // Проверка на отсутствие постов автора
            ? PostListStatus.empty                       // Статус empty если автор не имеет постов
            : PostListStatus.success,                    // Иначе успех
        posts: posts,                                    // Посты автора
        displayedPosts: _filterAndSort(                  // Применяем поиск и сортировку
          posts,                                         // Посты
          state.searchQuery,                             // Текущий поиск
          state.sortAscending,                           // Порядок сортировки
        ),                                               // Завершение фильтрации
        hasReachedMax: posts.length < _pageSize,         // Проверка конца каталога автора
      ));                                                // Завершение emit
    } catch (e) {                                        // Обработка ошибки загрузки по автору
      final msg = e is AppException ? e.message : 'Ошибка фильтрации: $e'; // Формируем сообщение
      emit(state.copyWith(                               // Отправляем состояние ошибки фильтрации
        status: PostListStatus.error,                    // Статус «ошибка»
        errorMessage: msg,                               // Текст ошибки
      ));                                                // Завершение emit
    }                                                    // Конец catch
  }                                                      // Конец метода _onAuthorFilterChanged

  void _onSearchQueryChanged(                            // Обработчик локального поиска по заголовку
    PostListSearchQueryChanged event,                    // Событие ввода строки поиска
    Emitter<PostListState> emit,                         // Функция отправки состояния
  ) {                                                    // Начало метода поиска
    final filtered = _filterAndSort(                     // Применяем поисковый фильтр к уже загруженным данным
      state.posts,                                       // Исходные посты
      event.query,                                       // Новая строка поиска
      state.sortAscending,                               // Текущий порядок сортировки
    );                                                   // Завершение фильтрации

    emit(state.copyWith(                                 // Обновляем состояние поиска
      searchQuery: event.query,                          // Запоминаем поисковый запрос
      displayedPosts: filtered,                          // Обновляем список постов на экране
      status: filtered.isEmpty && state.posts.isNotEmpty // Если поиск ничего не нашел среди постов
          ? PostListStatus.empty                         // Устанавливаем статус «ничего не найдено»
          : (state.posts.isEmpty ? state.status : PostListStatus.success), // Иначе успех
    ));                                                  // Завершение emit
  }                                                      // Конец метода _onSearchQueryChanged

  void _onSortToggleRequested(                           // Обработчик переключения сортировки по ID
    PostListSortToggleRequested event,                   // Событие переключения сортировки
    Emitter<PostListState> emit,                         // Функция отправки состояния
  ) {                                                    // Начало метода сортировки
    final newOrder = !state.sortAscending;               // Инвертируем порядок (возрастание / убывание)
    final sorted = _filterAndSort(                       // Пересортировываем текущий список
      state.posts,                                       // Исходные посты
      state.searchQuery,                                 // Текущая поисковая строка
      newOrder,                                          // Новый порядок сортировки
    );                                                   // Завершение сортировки

    emit(state.copyWith(                                 // Отправляем обновленное состояние сортировки
      sortAscending: newOrder,                           // Сохраняем флаг порядка сортировки
      displayedPosts: sorted,                            // Отображаем пересортированный список
    ));                                                  // Завершение emit
  }                                                      // Конец метода _onSortToggleRequested

  Future<void> _onFiltersResetRequested(                 // Обработчик сброса всех фильтров и поисковых параметров
    PostListFiltersResetRequested event,                 // Событие сброса фильтра
    Emitter<PostListState> emit,                         // Функция отправки состояния
  ) async {                                              // Начало метода сброса
    emit(state.copyWith(                                 // Сбрасываем все параметры к исходным значениям
      clearSelectedUser: true,                           // Сбрасываем выбранного автора на null
      searchQuery: '',                                   // Очищаем поисковую строку
      sortAscending: true,                               // Возвращаем сортировку по возрастанию ID
      page: 1,                                           // Сбрасываем пагинацию на 1
      hasReachedMax: false,                              // Сбрасываем флаг конца списка
      status: PostListStatus.loading,                    // Переводим в состояние загрузки общего каталога
    ));                                                  // Завершение сброса состояния

    add(const PostListRefreshed());                      // Запускаем загрузку общего списка постов заново
  }                                                      // Конец метода _onFiltersResetRequested

  void _onLocalPostAdded(                                // Обработчик добавления локально созданного поста
    PostListLocalPostAdded event,                        // Событие с объектом созданного поста
    Emitter<PostListState> emit,                         // Функция отправки состояния
  ) {                                                    // Начало метода добавления
    final updatedList = [event.post, ...state.posts];    // Добавляем новый пост на самую первую позицию (наверх)
    final filtered = _filterAndSort(                     // Применяем фильтрацию и сортировку
      updatedList,                                       // Обновленный список
      state.searchQuery,                                 // Текущий поиск
      state.sortAscending,                               // Порядок сортировки
    );                                                   // Завершение фильтрации

    emit(state.copyWith(                                 // Отправляем обновленное состояние
      posts: updatedList,                                // Сохраняем список с добавленным постом
      displayedPosts: filtered,                          // Обновляем экран
      status: PostListStatus.success,                    // Устанавливаем статус успеха
    ));                                                  // Завершение emit
  }                                                      // Конец метода _onLocalPostAdded

  static List<Post> _filterAndSort(                      // Чистая вспомогательная функция фильтрации и сортировки постов
    List<Post> posts,                                    // Исходный список публикаций
    String query,                                        // Текст поискового запроса по заголовку
    bool ascending,                                      // Направление сортировки по ID
  ) {                                                    // Начало тела вспомогательной функции
    var result = List<Post>.from(posts);                 // Создаем копию списка для безопасной модификации
    if (query.trim().isNotEmpty) {                       // Если введен непустой поисковый запрос
      final lowerQuery = query.trim().toLowerCase();     // Приводим поисковый текст к нижнему регистру
      result = result                                    // Фильтруем публикации
          .where((post) => post.title.toLowerCase().contains(lowerQuery)) // По совпадению подстроки в заголовке
          .toList();                                     // Собираем отфильтрованный список
    }                                                    // Конец проверки поиска

    result.sort((a, b) {                                 // Сортируем публикации по числовому значению идентификатора
      final idA = a.id ?? 0;                             // Извлекаем ID первого поста или 0 при null
      final idB = b.id ?? 0;                             // Извлекаем ID второго поста или 0 при null
      return ascending                                   // Проверяем направление сортировки
          ? idA.compareTo(idB)                           // По возрастанию (1, 2, 3...)
          : idB.compareTo(idA);                          // По убыванию (...3, 2, 1)
    });                                                  // Завершение сортировки
    return result;                                       // Возвращаем итоговый отсортированный и отфильтрованный список
  }                                                      // Конец вспомогательной функции _filterAndSort
}                                                        // Конец класса PostListBloc
