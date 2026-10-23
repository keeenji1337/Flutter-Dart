import 'package:flutter/material.dart';                  // Основные UI-компоненты Material Design Flutter
import 'package:flutter_bloc/flutter_bloc.dart';            // Пакет flutter_bloc для управления состоянием экрана
import '../../data/models/post.dart';                        // Модель публикации
import '../bloc/post_list/post_list_bloc.dart';             // BLoC экрана списка постов
import '../bloc/post_list/post_list_event.dart';            // События BLoC списка постов
import '../bloc/post_list/post_list_state.dart';            // Состояния BLoC списка постов
import '../widgets/cached_banner.dart';                     // Баннер отображения кэшированных данных
import '../widgets/error_view.dart';                         // Виджет ошибки с кнопкой повтора
import '../widgets/loading_indicator.dart';                  // Индикатор первичной загрузки
import '../widgets/post_card.dart';                         // Карточка публикации в списке
import 'create_post_screen.dart';                            // Экран создания новой публикации
import 'post_detail_screen.dart';                            // Экран детального просмотра поста

class PostListScreen extends StatefulWidget {             // Экран каталога постов (StatefulWidget для ScrollController и поиска)
  const PostListScreen({super.key});                     // Конструктор главного экрана списка

  @override                                              // Создание объекта состояния экрана
  State<PostListScreen> createState() => _PostListScreenState(); // Связываем класс состояния
}                                                        // Конец StatefulWidget

class _PostListScreenState extends State<PostListScreen> { // Класс состояния экрана со скроллом и поиском
  final ScrollController _scrollController = ScrollController(); // Контроллер прокрутки для отслеживания пагинации
  final TextEditingController _searchController = TextEditingController(); // Контроллер строки поиска по заголовкам

  @override                                              // Инициализация состояния виджета
  void initState() {                                     // Метод initState
    super.initState();                                   // Вызов родительской инициализации
    _scrollController.addListener(_onScroll);            // Подписываемся на скролл для автоматической подгрузки страниц
  }                                                      // Конец initState

  @override                                              // Освобождение ресурсов при закрытии экрана
  void dispose() {                                       // Метод dispose
    _scrollController.dispose();                         // Удаляем слушатель и освобождаем ScrollController
    _searchController.dispose();                         // Очищаем память контроллера поиска
    super.dispose();                                     // Вызов родительского dispose
  }                                                      // Конец dispose

  void _onScroll() {                                     // Метод проверки необходимости подгрузки следующей страницы
    if (!_scrollController.hasClients) return;           // Проверяем, привязан ли скроллер к списку на экране
    final maxScroll = _scrollController.position.maxScrollExtent; // Максимальная глубина прокрутки списка
    final currentScroll = _scrollController.position.pixels;      // Текущая позиция скролла пользователя
    if (currentScroll >= (maxScroll - 250)) {            // Если до конца списка осталось менее 250 пикселей
      context.read<PostListBloc>().add(const PostListNextPageRequested()); // Отправляем событие загрузки следующей страницы
    }                                                    // Конец проверки порога скролла
  }                                                      // Конец метода _onScroll

  @override                                              // Построение пользовательского интерфейса
  Widget build(BuildContext context) {                   // Метод build
    return Scaffold(                                     // Корневой каркас экрана
      appBar: AppBar(                                    // Верхняя панель приложения
        title: const Text(                               // Заголовок экрана
          'Post Explorer',                               // Название приложения согласно ТЗ
          style: TextStyle(fontWeight: FontWeight.bold), // Жирное начертание шрифта
        ),                                               // Завершение Text
        elevation: 1,                                    // Небольшая тень AppBar
        actions: [                                       // Дополнительные кнопки действий в панели
          IconButton(                                    // Кнопка ручного обновления данных
            icon: const Icon(Icons.refresh_rounded),     // Иконка обновления
            tooltip: 'Обновить список',                  // Подсказка при наведении
            onPressed: () => context.read<PostListBloc>().add(const PostListRefreshed()), // Запуск pull-to-refresh
          ),                                             // Завершение IconButton
        ],                                               // Завершение actions
      ),                                                 // Завершение AppBar
      body: BlocConsumer<PostListBloc, PostListState>(   // Слушатель и строитель состояния списка
        listener: (context, state) {                     // Обработка фоновых уведомлений
          if (state.errorMessage != null && state.posts.isNotEmpty) { // Если возникла ошибка при уже загруженных данных
            ScaffoldMessenger.of(context).showSnackBar(  // Показываем плавающее уведомление
              SnackBar(                                  // Виджет SnackBar
                content: Text(state.errorMessage!),      // Текст ошибки
                behavior: SnackBarBehavior.floating,     // Плавающий стиль
                duration: const Duration(seconds: 4),    // Длительность показа 4 секунды
              ),                                         // Завершение SnackBar
            );                                           // Завершение showSnackBar
          }                                              // Конец проверки ошибки
        },                                               // Конец listener
        builder: (context, state) {                      // Функция построения интерфейса
          return Column(                                 // Вертикальное размещение: поиск, фильтры, баннер и список
            children: [                                  // Список дочерних виджетов колонки
              _buildSearchBar(context, state),           // Секция поиска с бейджем локального поиска
              _buildFilterChips(context, state),         // Горизонтальная лента кнопок фильтрации и сортировки
              if (state.isCached)                        // Если данные загружены из локального кэша
                CachedBanner(                            // Отображаем плашку-предупреждение о кэше (ТЗ Задание E)
                  onRefresh: () => context.read<PostListBloc>().add(const PostListRefreshed()), // Обновление
                ),                                       // Завершение CachedBanner
              Expanded(                                  // Занимаем все оставшееся место под список постов
                child: _buildBodyContent(context, state), // Метод выбора виджета в зависимости от состояния BLoC
              ),                                         // Завершение Expanded
            ],                                           // Завершение children Column
          );                                             // Завершение Column
        },                                               // Конец builder BlocConsumer
      ),                                                 // Завершение BlocConsumer
      floatingActionButton: FloatingActionButton.extended( // Плавающая кнопка создания поста в правом нижнем углу
        onPressed: () async {                            // Обработка клика по кнопке создания поста
          final newPost = await Navigator.push<Post>(    // Открываем экран создания и ждем результат
            context,                                     // Контекст навигации
            MaterialPageRoute(builder: (_) => const CreatePostScreen()), // Переход на CreatePostScreen
          );                                             // Завершение Navigator.push
          if (newPost != null && context.mounted) {      // Если пост успешно создан и возвращен
            context.read<PostListBloc>().add(PostListLocalPostAdded(newPost)); // Добавляем пост в список BLoC
          }                                              // Конец проверки
        },                                               // Конец onPressed
        icon: const Icon(Icons.add),                     // Иконка плюса
        label: const Text('Создать пост'),               // Текст на кнопке
      ),                                                 // Завершение FloatingActionButton
    );                                                   // Завершение Scaffold
  }                                                      // Конец build

  Widget _buildSearchBar(BuildContext context, PostListState state) { // Поле поиска с поясняющим бейджем
    return Container(                                    // Контейнер с отступами и фоном
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4), // Отступы вокруг строки поиска
      child: Column(                                     // Колонка: поле ввода + индикатор области поиска
        crossAxisAlignment: CrossAxisAlignment.start,    // Выравнивание по левому краю
        children: [                                      // Дочерние элементы
          TextField(                                     // Поле ввода текста поиска
            controller: _searchController,               // Контроллер текста
            decoration: InputDecoration(                 // Оформление поисковой строки
              hintText: 'Поиск по заголовку публикации...', // Текст подсказки внутри поля
              prefixIcon: const Icon(Icons.search),      // Иконка лупы слева
              suffixIcon: state.searchQuery.isNotEmpty   // Если поиск не пуст — показываем крестик очистки
                  ? IconButton(                          // Кнопка очистки
                      icon: const Icon(Icons.clear),     // Иконка крестика
                      onPressed: () {                    // Нажатие на крестик
                        _searchController.clear();       // Очищаем текстовый контроллер
                        context.read<PostListBloc>().add(const PostListSearchQueryChanged('')); // Сбрасываем поиск
                      },                                 // Конец onPressed
                    )                                    // Завершение IconButton
                  : null,                                // Иначе суффикс отсутствует
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16), // Высота поля
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // Скругленная рамка
              filled: true,                              // Включаем фоновую заливку поля
              fillColor: Colors.grey.shade100,           // Светло-серый цвет фона поля
            ),                                           // Завершение InputDecoration
            onChanged: (query) => context.read<PostListBloc>().add(PostListSearchQueryChanged(query)), // Поиск на ввод
          ),                                             // Завершение TextField
          const SizedBox(height: 4),                     // Небольшой отступ
          Row(                                           // Строка с бейджем области поиска (ТЗ Задание D)
            children: [                                  // Элементы строки
              Icon(Icons.info_outline, size: 13, color: Colors.blue.shade700), // Мини-иконка информации
              const SizedBox(width: 4),                  // Промежуток
              Text(                                      // Текст явного обозначения области поиска
                'Поиск выполняется среди загруженных постов', // Явное указание области согласно ТЗ Задание D
                style: TextStyle(fontSize: 11, color: Colors.blue.shade800, fontWeight: FontWeight.w500), // Стиль
              ),                                         // Завершение Text
            ],                                           // Завершение children
          ),                                             // Завершение Row
        ],                                               // Завершение children Column
      ),                                                 // Завершение Column
    );                                                   // Завершение Container
  }                                                      // Конец _buildSearchBar

  Widget _buildFilterChips(BuildContext context, PostListState state) { // Лента фильтров и кнопок сортировки
    final hasActiveFilter = state.selectedUserId != null || state.searchQuery.isNotEmpty; // Есть ли активные фильтры

    return SingleChildScrollView(                        // Горизонтальная прокрутка чипов
      scrollDirection: Axis.horizontal,                  // Направление прокрутки по горизонтали
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Отступы полосы чипов
      child: Row(                                        // Горизонтальный ряд чипов
        children: [                                      // Список элементов
          ActionChip(                                    // Чип переключения направления сортировки по ID
            avatar: Icon(                                // Иконка со стрелкой сортировки
              state.sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, // Направление стрелки
              size: 16,                                  // Размер иконки
            ),                                           // Завершение avatar
            label: Text('ID: ${state.sortAscending ? "по возр." : "по убыв."}'), // Текст порядка сортировки
            onPressed: () => context.read<PostListBloc>().add(const PostListSortToggleRequested()), // Смена порядка
          ),                                             // Завершение ActionChip
          const SizedBox(width: 8),                      // Промежуток
          FilterChip(                                    // Чип фильтрации по автору (userId)
            selected: state.selectedUserId != null,      // Выделен, если выбран конкретный автор
            avatar: const Icon(Icons.person_outline, size: 16), // Иконка автора
            label: Text(                                 // Текст на чипе
              state.selectedUserId == null               // Проверка выбранного автора
                  ? 'Все авторы'                         // Если автор не выбран
                  : 'Автор ID: ${state.selectedUserId}', // Если выбран автор
            ),                                           // Завершение Text
            onSelected: (_) => _showAuthorPicker(context, state), // Открытие выбора автора
          ),                                             // Завершение FilterChip
          if (hasActiveFilter) ...[                      // Если активен фильтр или поиск — показываем кнопку сброса
            const SizedBox(width: 8),                    // Промежуток
            ActionChip(                                  // Кнопка сброса всех примененных фильтров
              avatar: const Icon(Icons.close_rounded, size: 16, color: Colors.red), // Красный крестик
              label: const Text('Сбросить', style: TextStyle(color: Colors.red)), // Текст сброса
              onPressed: () {                            // Нажатие сброса
                _searchController.clear();               // Очищаем поисковую строку
                context.read<PostListBloc>().add(const PostListFiltersResetRequested()); // Сброс в BLoC
              },                                         // Конец onPressed
            ),                                           // Завершение ActionChip
          ],                                             // Конец if
        ],                                               // Завершение children Row
      ),                                                 // Завершение Row
    );                                                   // Завершение SingleChildScrollView
  }                                                      // Конец _buildFilterChips

  void _showAuthorPicker(BuildContext context, PostListState state) { // Модальное окно выбора автора
    showModalBottomSheet(                                // Открываем нижнее модальное окно выбора
      context: context,                                  // Контекст
      shape: const RoundedRectangleBorder(               // Скругление верхних краев окна
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // 20px скругление
      ),                                                 // Завершение shape
      builder: (sheetCtx) => SafeArea(                   // Безопасная зона экрана
        child: Column(                                   // Колонка выбора авторов
          mainAxisSize: MainAxisSize.min,                // Высота по содержимому
          children: [                                    // Элементы
            const Padding(                               // Заголовок модального окна
              padding: EdgeInsets.all(16.0),             // Отступ 16px
              child: Text(                               // Текст заголовка
                'Фильтрация по автору (userId)',         // Заголовок
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Полужирный 16px
              ),                                         // Завершение Text
            ),                                           // Завершение Padding
            const Divider(height: 1),                    // Тонкий разделитель
            ListTile(                                    // Пункт «Все авторы» (сброс фильтра)
              leading: const Icon(Icons.people_outline), // Иконка группы людей
              title: const Text('Все авторы'),           // Текст пункта
              trailing: state.selectedUserId == null     // Галочка если выбран этот пункт
                  ? const Icon(Icons.check, color: Colors.blue) // Синяя галочка
                  : null,                                // Иначе пусто
              onTap: () {                                // Клик по «Все авторы»
                Navigator.pop(sheetCtx);                 // Закрываем модальное окно
                context.read<PostListBloc>().add(const PostListAuthorFilterChanged(null)); // Сбрасываем фильтр автора
              },                                         // Конец onTap
            ),                                           // Завершение ListTile
            Expanded(                                    // Прокручиваемый список авторов с ID 1 по 10
              child: ListView.builder(                   // Список авторов
                itemCount: 10,                           // 10 тестовых авторов JSONPlaceholder
                itemBuilder: (ctx, index) {              // Сборка строки автора
                  final userId = index + 1;              // ID автора от 1 до 10
                  final isSelected = state.selectedUserId == userId; // Проверка выбора
                  return ListTile(                       // Строка автора
                    leading: CircleAvatar(               // Аватарка с ID
                      radius: 14,                        // Радиус 14px
                      backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200, // Цвет фона
                      child: Text(                       // Номер автора
                        '$userId',                       // ID
                        style: TextStyle(                // Стиль
                          color: isSelected ? Colors.white : Colors.black87, // Цвет цифры
                          fontSize: 12,                  // Размер 12px
                        ),                               // Завершение TextStyle
                      ),                                 // Завершение Text
                    ),                                   // Завершение CircleAvatar
                    title: Text('Автор ID: $userId'),    // Название автора
                    trailing: isSelected                 // Отображение галочки
                        ? const Icon(Icons.check, color: Colors.blue) // Галочка
                        : null,                          // Пусто
                    onTap: () {                          // Выбор автора
                      Navigator.pop(sheetCtx);           // Закрытие окна
                      context.read<PostListBloc>().add(PostListAuthorFilterChanged(userId)); // Установка фильтра автора
                    },                                   // Конец onTap
                  );                                     // Завершение ListTile
                },                                       // Конец itemBuilder
              ),                                         // Завершение ListView.builder
            ),                                           // Завершение Expanded
          ],                                             // Завершение children Column
        ),                                               // Завершение Column
      ),                                                 // Завершение SafeArea
    );                                                   // Завершение showModalBottomSheet
  }                                                      // Конец _showAuthorPicker

  Widget _buildBodyContent(BuildContext context, PostListState state) { // Определение центрального виджета экрана
    if (state.status == PostListStatus.loading && state.posts.isEmpty) { // Если идет первичная загрузка и список пуст
      return const LoadingIndicator(message: 'Загрузка публикаций с сервера...'); // Полноэкранный индикатор загрузки
    }                                                    // Конец проверки загрузки

    if (state.status == PostListStatus.error && state.posts.isEmpty) { // Если ошибка и нет кэшированных данных
      return ErrorView(                                  // Экран ошибки с кнопкой повтора
        message: state.errorMessage ?? 'Не удалось загрузить публикации', // Текст ошибки
        onRetry: () => context.read<PostListBloc>().add(const PostListRefreshed()), // Повторный запрос
      );                                                 // Завершение ErrorView
    }                                                    // Конец проверки ошибки

    if (state.status == PostListStatus.empty || state.displayedPosts.isEmpty) { // Если данных нет или поиск ничего не нашел
      return Center(                                     // Центрированный блок пустого состояния
        child: Padding(                                  // Отступы
          padding: const EdgeInsets.all(24.0),           // 24px
          child: Column(                                 // Колонка с иконкой и текстом
            mainAxisAlignment: MainAxisAlignment.center, // По центру вертикали
            children: [                                  // Элементы
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400), // Большая иконка пустого ящика
              const SizedBox(height: 16),                // Отступ
              const Text(                                // Заголовок пустого списка
                'Публикации не найдены',                 // Текст заголовка
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Полужирный стиль
              ),                                         // Завершение Text
              const SizedBox(height: 8),                 // Отступ
              Text(                                      // Описание причины
                state.searchQuery.isNotEmpty             // Проверка наличия поиска
                    ? 'По запросу «${state.searchQuery}» ничего не найдено.' // Текст если был поиск
                    : 'По заданным параметрам публикации отсутствуют.', // Текст если был фильтр
                textAlign: TextAlign.center,             // По центру
                style: TextStyle(color: Colors.grey.shade600), // Серый стиль
              ),                                         // Завершение Text
              const SizedBox(height: 16),                // Отступ
              FilledButton.tonal(                        // Кнопка сброса параметров
                onPressed: () {                          // Обработка сброса
                  _searchController.clear();             // Очистка строки
                  context.read<PostListBloc>().add(const PostListFiltersResetRequested()); // Сброс фильтров
                },                                       // Конец onPressed
                child: const Text('Сбросить фильтры'),   // Текст кнопки
              ),                                         // Завершение FilledButton
            ],                                           // Завершение children
          ),                                             // Завершение Column
        ),                                               // Завершение Padding
      );                                                 // Завершение Center
    }                                                    // Конец проверки пустого списка

    return RefreshIndicator(                             // Жест смахивания вниз для обновления данных (pull-to-refresh)
      onRefresh: () async {                              // Асинхронный колбэк обновления
        context.read<PostListBloc>().add(const PostListRefreshed()); // Отправляем событие pull-to-refresh
      },                                                 // Конец onRefresh
      child: ListView.builder(                           // Оптимизированный построитель прокручиваемого списка
        controller: _scrollController,                   // Связываем с нашим ScrollController для пагинации
        padding: const EdgeInsets.only(top: 6, bottom: 80), // Отступы списка (снизу место под FAB)
        itemCount: state.displayedPosts.length + 1,      // Количество постов + 1 нижний элемент (индикатор пагинации)
        itemBuilder: (context, index) {                  // Сборка элемента по индексу
          if (index < state.displayedPosts.length) {     // Если индекс в пределах списка постов
            final post = state.displayedPosts[index];    // Получаем текущую публикацию
            return PostCard(                             // Возвращаем карточку поста
              post: post,                                // Объект публикации
              onTap: () {                                // Обработка клика по карточке
                if (post.id != null) {                   // Проверяем наличие идентификатора
                  Navigator.push(                        // Переходим на детальный экран
                    context,                             // Контекст
                    MaterialPageRoute(                   // Маршрут MaterialPageRoute
                      builder: (_) => PostDetailScreen(  // Создаем экран деталей
                        postId: post.id!,                // Передаем ID поста
                        initialPost: post,               // Передаем имеющийся пост для быстрого старта
                      ),                                 // Завершение PostDetailScreen
                    ),                                   // Завершение MaterialPageRoute
                  );                                     // Завершение push
                }                                        // Конец проверки id
              },                                         // Конец onTap
            );                                           // Завершение PostCard
          } else {                                       // Иначе строим нижний элемент списка (пагинация/конец)
            return _buildBottomPaginationWidget(context, state); // Нижний виджет пагинации
          }                                              // Конец ветвления индекса
        },                                               // Конец itemBuilder
      ),                                                 // Завершение ListView.builder
    );                                                   // Завершение RefreshIndicator
  }                                                      // Конец _buildBodyContent

  Widget _buildBottomPaginationWidget(BuildContext context, PostListState state) { // Нижний виджет подгрузки страниц
    if (state.isLoadingMore) {                           // Если идет активная загрузка следующей страницы
      return const Padding(                              // Отступ вокруг индикатора
        padding: EdgeInsets.symmetric(vertical: 20.0),   // 20px вертикальный отступ
        child: Center(                                   // Центрирование индикатора
          child: CircularProgressIndicator(),            // Индикатор подгрузки следующей страницы внизу списка
        ),                                               // Завершение Center
      );                                                 // Завершение Padding
    }                                                    // Конец проверки isLoadingMore

    if (state.paginationError != null) {                 // Если произошла ошибка при загрузке следующей страницы (ТЗ Задание C)
      return Padding(                                    // Отступы блока ошибки пагинации
        padding: const EdgeInsets.all(16.0),             // 16px
        child: Column(                                   // Колонка: текст ошибки + кнопка повтора
          children: [                                    // Элементы
            Text(                                        // Текст сообщения об ошибке подгрузки
              state.paginationError!,                    // Текст
              textAlign: TextAlign.center,               // По центру
              style: TextStyle(color: Colors.red.shade700, fontSize: 13), // Красный стиль
            ),                                           // Завершение Text
            const SizedBox(height: 8),                   // Отступ
            OutlinedButton.icon(                         // Кнопка повторной попытки загрузки страницы
              onPressed: () => context.read<PostListBloc>().add(const PostListNextPageRequested()), // Повтор запроса
              icon: const Icon(Icons.refresh, size: 16), // Иконка повтора
              label: const Text('Повторить попытку'),    // Текст кнопки
            ),                                           // Завершение OutlinedButton
          ],                                             // Завершение children
        ),                                               // Завершение Column
      );                                                 // Завершение Padding
    }                                                    // Конец проверки ошибки пагинации

    if (state.hasReachedMax && state.displayedPosts.length >= 10) { // Если все страницы загружены до конца
      return Padding(                                    // Отступ
        padding: const EdgeInsets.symmetric(vertical: 18.0), // 18px вертикальный отступ
        child: Center(                                   // Центрирование
          child: Text(                                   // Текст завершения каталога
            'Все публикации загружены',                  // Сообщение о конце списка
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12), // Серый неброский стиль
          ),                                             // Завершение Text
        ),                                               // Завершение Center
      );                                                 // Завершение Padding
    }                                                    // Конец проверки конца списка

    return const SizedBox(height: 20);                   // Пустой отступ по умолчанию
  }                                                      // Конец _buildBottomPaginationWidget
}                                                        // Конец _PostListScreenState
