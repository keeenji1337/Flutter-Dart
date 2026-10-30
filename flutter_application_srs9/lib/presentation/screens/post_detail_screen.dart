import 'package:flutter/material.dart';                  // Базовые UI-компоненты Material Design
import 'package:flutter_bloc/flutter_bloc.dart';            // Пакет Bloc для управления состоянием
import '../../data/models/comment.dart';                     // Модель комментария к посту
import '../../data/models/post.dart';                        // Модель публикации
import '../../data/models/user.dart';                        // Модель пользователя (автора)
import '../../data/repositories/post_repository.dart';       // Репозиторий данных
import '../bloc/post_detail/post_detail_bloc.dart';         // BLoC экрана подробностей поста
import '../bloc/post_detail/post_detail_event.dart';        // События экрана подробностей поста
import '../bloc/post_detail/post_detail_state.dart';        // Состояния экрана подробностей поста
import '../widgets/error_view.dart';                         // Виджет ошибки с кнопкой повтора
import '../widgets/loading_indicator.dart';                  // Виджет индикатора загрузки

class PostDetailScreen extends StatelessWidget {          // Экран детального просмотра публикации, комментариев и автора
  final int postId;                                      // Идентификатор просматриваемого поста
  final Post? initialPost;                               // Предварительно известный объект поста (для мгновенного отображения)

  const PostDetailScreen({                               // Конструктор детального экрана
    super.key,                                           // Ключ виджета
    required this.postId,                                // Обязательный ID поста
    this.initialPost,                                    // Опциональный объект поста
  });                                                    // Завершение конструктора

  @override                                              // Построение виджета экрана
  Widget build(BuildContext context) {                   // Метод сборки
    return BlocProvider(                                 // Внедряем экземпляр PostDetailBloc в поддерево виджетов
      create: (context) => PostDetailBloc(               // Создаем фабрику BLoC
        postRepository: context.read<PostRepository>(),  // Получаем PostRepository из контекста приложения
      )..add(PostDetailRequested(postId, initialPost: initialPost)), // Сразу отправляем событие загрузки данных
      child: Scaffold(                                   // Базовый каркас экрана Material Design
        appBar: AppBar(                                  // Верхняя панель приложения
          title: Text('Публикация #$postId'),            // Заголовок в AppBar с номером публикации
          elevation: 1,                                  // Легкая тень панели
        ),                                               // Завершение AppBar
        body: BlocBuilder<PostDetailBloc, PostDetailState>( // Подписка на обновление состояния BLoC
          builder: (context, state) {                    // Функция сборки интерфейса по состоянию
            if (state.status == PostDetailStatus.loading && state.post == null) { // Если идет загрузка и данных поста еще нет
              return const LoadingIndicator(message: 'Загрузка публикации...'); // Отображаем круговой индикатор загрузки
            }                                            // Конец проверки загрузки

            if (state.status == PostDetailStatus.error && state.post == null) { // Если произошла критическая ошибка
              return ErrorView(                          // Отображаем экран ошибки
                message: state.errorMessage ?? 'Не удалось загрузить данные', // Текст сообщения об ошибке
                onRetry: () => context.read<PostDetailBloc>().add( // Колбэк повторной попытки загрузки
                      PostDetailRequested(postId, initialPost: initialPost), // Перезапуск события загрузки
                    ),                                   // Завершение колбэка
              );                                         // Завершение ErrorView
            }                                            // Конец проверки ошибки

            final post = state.post ?? initialPost;      // Извлекаем актуальный пост из состояния или fallback
            if (post == null) {                          // Если пост не найден
              return const Center(child: Text('Публикация не найдена')); // Сообщение об отсутствии
            }                                            // Конец проверки null

            return RefreshIndicator(                     // Поддержка обновления экрана жестом смахивания вниз
              onRefresh: () async {                      // Асинхронный колбэк обновления
                context.read<PostDetailBloc>().add(      // Отправляем повторный запрос данных
                      PostDetailRequested(postId, initialPost: post), // Перезагружаем пост и комментарии
                    );                                   // Завершение отправки события
              },                                         // Конец onRefresh
              child: ListView(                           // Прокручиваемый список секций экрана деталей
                padding: const EdgeInsets.all(16.0),     // Отступы по периметру экрана 16px
                children: [                              // Дочерние блоки экрана
                  _buildPostCard(context, post),         // Секция 1: карточка с текстом поста и статусом
                  const SizedBox(height: 16),            // Отступ между секцией поста и автора
                  if (state.author != null)              // Секция 2: если автор загружен
                    _buildAuthorCard(context, state.author!), // Отображаем карточку информации об авторе
                  const SizedBox(height: 20),            // Отступ перед секцией комментариев
                  _buildCommentsSection(context, state), // Секция 3: блок комментариев к публикации
                ],                                       // Завершение списка виджетов
              ),                                         // Завершение ListView
            );                                           // Завершение RefreshIndicator
          },                                             // Конец builder BlocBuilder
        ),                                               // Завершение BlocBuilder
      ),                                                 // Завершение Scaffold
    );                                                   // Завершение BlocProvider
  }                                                      // Конец build

  Widget _buildPostCard(BuildContext context, Post post) { // Приватный метод сборки карточки самого поста
    return Card(                                         // Виджет карточки публикации
      elevation: 2,                                      // Тень карточки
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Скругление 16px
      child: Padding(                                    // Внутренние отступы внутри карточки
        padding: const EdgeInsets.all(18.0),             // Отступ 18px
        child: Column(                                   // Вертикальное размещение элементов поста
          crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание по левому краю
          children: [                                  // Список строк карточки
            Row(                                         // Верхняя строка карточки: теги и идентификаторы
              children: [                                // Элементы строки
                CircleAvatar(                            // Круглая аватарка автора публикации
                  radius: 16,                            // Радиус 16px
                  backgroundColor: Colors.blue.shade100, // Голубой фон
                  child: Text(                           // Текст с первой буквой или ID
                    '${post.userId}',                    // Выводим ID автора
                    style: TextStyle(                    // Стилизация ID автора
                      fontWeight: FontWeight.bold,       // Жирный шрифт
                      color: Colors.blue.shade900,       // Темно-синий цвет
                      fontSize: 12,                      // Размер 12px
                    ),                                   // Завершение TextStyle
                  ),                                     // Завершение Text
                ),                                       // Завершение CircleAvatar
                const SizedBox(width: 10),               // Промежуток
                Text(                                    // Номер автора
                  'Автор ID: ${post.userId}',            // Текст ID
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13), // Серый стиль
                ),                                       // Завершение Text
                const Spacer(),                          // Сдвигаем бейдж локального поста вправо
                if (post.isLocal)                        // Если пост создан локально
                  Container(                             // Бейдж «создан локально»
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Отступы
                    decoration: BoxDecoration(           // Декорация
                      color: Colors.green.shade100,      // Зеленый фон
                      borderRadius: BorderRadius.circular(6), // Скругление 6px
                      border: Border.all(color: Colors.green), // Зеленая рамка
                    ),                                   // Завершение BoxDecoration
                    child: Text(                         // Текст бейджа
                      'создан локально',                 // Метка создания
                      style: TextStyle(color: Colors.green.shade900, fontSize: 11, fontWeight: FontWeight.bold), // Стиль
                    ),                                   // Завершение Text
                  ),                                     // Завершение Container
              ],                                         // Завершение children Row
            ),                                           // Завершение Row
            const Divider(height: 24),                   // Горизонтальный разделитель с отступом 24px
            Text(                                        // Полный заголовок публикации
              post.title,                                // Текст заголовка
              style: const TextStyle(                    // Стиль заголовка
                fontSize: 20,                            // Крупный размер шрифта 20px
                fontWeight: FontWeight.bold,             // Жирное начертание
                height: 1.3,                             // Межстрочный интервал
              ),                                         // Завершение TextStyle
            ),                                           // Завершение Text заголовка
            const SizedBox(height: 12),                  // Отступ между заголовком и текстом
            Text(                                        // Полный текст публикации
              post.body,                                 // Содержимое поста
              style: TextStyle(                          // Стиль текста публикации
                fontSize: 15,                            // Размер шрифта 15px
                color: Colors.grey.shade800,             // Темно-серый удобочитаемый цвет
                height: 1.5,                             // Комфортный межстрочный интервал
              ),                                         // Завершение TextStyle
            ),                                           // Завершение Text содержимого
          ],                                             // Завершение children Column
        ),                                               // Завершение Column
      ),                                                 // Завершение Padding
    );                                                   // Завершение Card
  }                                                      // Конец _buildPostCard

  Widget _buildAuthorCard(BuildContext context, User author) { // Приватный метод сборки информации об авторе
    return Card(                                         // Карточка автора публикации
      elevation: 1,                                      // Небольшая тень
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), // Скругление 14px
      child: Padding(                                    // Внутренние отступы
        padding: const EdgeInsets.all(16.0),             // Отступ 16px
        child: Column(                                   // Вертикальное расположение данных автора
          crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание по левому краю
          children: [                                  // Список строк
            Row(                                         // Заголовок блока с иконкой
              children: [                                // Элементы строки
                Icon(Icons.person_pin_rounded, color: Colors.blue.shade700), // Иконка профиля
                const SizedBox(width: 8),                // Промежуток
                const Text(                              // Заголовок секции автора
                  'Об авторе',                           // Текст заголовка
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Полужирный стиль 16px
                ),                                       // Завершение Text
              ],                                         // Завершение children
            ),                                           // Завершение Row
            const SizedBox(height: 10),                  // Отступ
            Text(                                        // Имя и никнейм автора
              '${author.name} (@${author.username})',    // Форматированное имя и логин
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), // Полужирный шрифт 14px
            ),                                           // Завершение Text
            const SizedBox(height: 4),                   // Отступ
            Text(                                        // Email автора
              'Email: ${author.email}',                  // Текст почты
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13), // Серый стиль 13px
            ),                                           // Завершение Text
            if (author.company?.name != null) ...[       // Если у автора указана компания (вложенный объект)
              const SizedBox(height: 4),                 // Отступ
              Text(                                      // Данные о компании
                'Компания: ${author.company!.name}',     // Название компании
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13), // Серый стиль
              ),                                         // Завершение Text
            ],                                           // Конец if компании
            if (author.address?.city != null) ...[       // Если у автора указан город (вложенный объект)
              const SizedBox(height: 4),                 // Отступ
              Text(                                      // Город проживания
                'Город: ${author.address!.city}',        // Название города
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13), // Стиль текста
              ),                                         // Завершение Text
            ],                                           // Конец if адреса
          ],                                             // Завершение children Column
        ),                                               // Завершение Column
      ),                                                 // Завершение Padding
    );                                                   // Завершение Card
  }                                                      // Конец _buildAuthorCard

  Widget _buildCommentsSection(BuildContext context, PostDetailState state) { // Секция комментариев
    return Column(                                       // Колонка со списком комментариев
      crossAxisAlignment: CrossAxisAlignment.start,     // Выравнивание по левому краю
      children: [                                        // Дочерние элементы
        Row(                                             // Заголовок блока комментариев
          children: [                                    // Элементы строки заголовка
            Icon(Icons.comment_outlined, color: Colors.blue.shade700), // Иконка комментариев
            const SizedBox(width: 8),                    // Промежуток
            Text(                                        // Текст заголовка с количеством
              'Комментарии (${state.comments.length})',   // Число комментариев
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Жирный шрифт 18px
            ),                                           // Завершение Text
          ],                                             // Завершение children Row
        ),                                               // Завершение Row
        const SizedBox(height: 12),                      // Отступ
        if (state.comments.isEmpty)                      // Если список комментариев пуст
          Padding(                                       // Отступ пустого состояния
            padding: const EdgeInsets.symmetric(vertical: 20), // Вертикальный отступ
            child: Center(                               // Центрирование
              child: Text(                               // Текст отсутствия комментариев
                'Комментариев пока нет',                 // Сообщение
                style: TextStyle(color: Colors.grey.shade500), // Светло-серый стиль
              ),                                         // Завершение Text
            ),                                           // Завершение Center
          )                                              // Завершение Padding
        else                                             // Если комментарии загружены
          ...state.comments.map((comment) => _buildCommentTile(comment)), // Преобразуем каждый комментарий в плитку
      ],                                                 // Завершение children
    );                                                   // Завершение Column
  }                                                      // Конец _buildCommentsSection

  Widget _buildCommentTile(Comment comment) {            // Виджет отдельного комментария
    return Card(                                         // Карточка комментария
      margin: const EdgeInsets.only(bottom: 10),         // Отступ снизу 10px
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Скругление 12px
      elevation: 0.5,                                    // Минимальная тень
      color: Colors.grey.shade50,                        // Светло-серый фон
      child: Padding(                                    // Отступы внутри комментария
        padding: const EdgeInsets.all(12.0),             // 12px со всех сторон
        child: Column(                                   // Вертикальное размещение
          crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание по левому краю
          children: [                                  // Элементы комментария
            Row(                                         // Строка автора комментария
              children: [                                // Элементы строки
                CircleAvatar(                            // Круглая миниатюра автора комментария
                  radius: 12,                            // Радиус 12px
                  backgroundColor: Colors.blue.shade200, // Голубой фон
                  child: Text(                           // Первая буква email
                    comment.email.isNotEmpty ? comment.email[0].toUpperCase() : '?', // Символ
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold), // Стиль
                  ),                                     // Завершение Text
                ),                                       // Завершение CircleAvatar
                const SizedBox(width: 8),                // Промежуток
                Expanded(                                // Растягиваем email на всю ширину
                  child: Text(                           // Email автора комментария
                    comment.email,                       // Адрес почты
                    overflow: TextOverflow.ellipsis,     // Троеточие при переполнении
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade800, fontWeight: FontWeight.w500), // Стиль
                  ),                                     // Завершение Text
                ),                                       // Завершение Expanded
              ],                                         // Завершение children Row
            ),                                           // Завершение Row
            const SizedBox(height: 6),                   // Отступ
            Text(                                        // Заголовок комментария (поле name)
              comment.name,                              // Имя комментария
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), // Жирный стиль 13px
            ),                                           // Завершение Text
            const SizedBox(height: 4),                   // Отступ
            Text(                                        // Текст комментария
              comment.body,                              // Содержимое
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800, height: 1.3), // Стиль текста
            ),                                           // Завершение Text
          ],                                             // Завершение children Column
        ),                                               // Завершение Column
      ),                                                 // Завершение Padding
    );                                                   // Завершение Card
  }                                                      // Конец _buildCommentTile
}                                                        // Конец класса PostDetailScreen
