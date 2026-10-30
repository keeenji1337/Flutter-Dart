import 'package:flutter/material.dart';                  // UI-виджеты Flutter Material Design
import 'package:flutter_bloc/flutter_bloc.dart';            // Пакет управления состоянием Bloc
import '../../data/models/user.dart';                        // Модель автора для выпадающего списка
import '../../data/repositories/post_repository.dart';       // Репозиторий для выполнения запросов
import '../bloc/create_post/create_post_bloc.dart';         // BLoC создания публикации
import '../bloc/create_post/create_post_event.dart';        // События создания публикации
import '../bloc/create_post/create_post_state.dart';        // Состояния создания публикации

class CreatePostScreen extends StatefulWidget {           // Экран формы создания публикации (StatefulWidget для контроллеров полей)
  const CreatePostScreen({super.key});                   // Конструктор экрана создания

  @override                                              // Создание объекта состояния
  State<CreatePostScreen> createState() => _CreatePostScreenState(); // Возврат состояния экрана
}                                                        // Конец StatefulWidget

class _CreatePostScreenState extends State<CreatePostScreen> { // Класс состояния экрана формы
  final _formKey = GlobalKey<FormState>();               // Глобальный ключ формы для валидации полей ввода
  final _titleController = TextEditingController();      // Контроллер текстового поля заголовка
  final _bodyController = TextEditingController();        // Контроллер текстового поля содержимого поста
  int? _selectedUserId;                                  // Идентификатор выбранного в выпадающем списке автора

  @override                                              // Освобождение ресурсов при закрытии экрана
  void dispose() {                                       // Метод dispose
    _titleController.dispose();                          // Освобождаем память контроллера заголовка
    _bodyController.dispose();                           // Освобождаем память контроллера текста
    super.dispose();                                     // Вызов родительского dispose
  }                                                      // Конец dispose

  @override                                              // Построение пользовательского интерфейса экрана
  Widget build(BuildContext context) {                   // Метод сборки
    return BlocProvider(                                 // Внедряем CreatePostBloc в контекст экрана
      create: (context) => CreatePostBloc(               // Фабрика создания BLoC
        postRepository: context.read<PostRepository>(),  // Внедряем репозиторий постов
      )..add(const CreatePostUsersRequested()),          // Сразу запрашиваем список авторов для выпадающего меню
      child: Scaffold(                                   // Каркас экрана
        appBar: AppBar(                                  // Верхняя панель AppBar
          title: const Text('Создать публикацию'),       // Заголовок AppBar
          elevation: 1,                                  // Тень панели
        ),                                               // Завершение AppBar
        body: BlocConsumer<CreatePostBloc, CreatePostState>( // Слушатель событий и строитель UI
          listener: (context, state) {                   // Функция обработки однократных эффектов (успех/ошибка)
            if (state.status == CreatePostStatus.failure && state.errorMessage != null) { // Если возникла ошибка
              ScaffoldMessenger.of(context).showSnackBar( // Показываем всплывающее уведомление (SnackBar)
                SnackBar(                                // Виджет SnackBar
                  content: Text(state.errorMessage!),    // Текст ошибки
                  backgroundColor: Colors.red.shade700,  // Красный фоновый цвет
                  behavior: SnackBarBehavior.floating,   // Плавающий стиль SnackBar
                ),                                       // Завершение SnackBar
              );                                         // Завершение showSnackBar
            }                                            // Конец проверки ошибки

            if (state.status == CreatePostStatus.success && state.createdPost != null) { // Если пост успешно создан
              showDialog(                                // Показываем диалоговое окно с подтверждением от сервера (ТЗ Задание F)
                context: context,                        // Контекст виджета
                barrierDismissible: false,               // Запрещаем закрытие кликом мимо окна
                builder: (dialogCtx) => AlertDialog(     // Создание всплывающего окна
                  title: Row(                            // Заголовок диалога с зеленой иконкой
                    children: [                          // Дочерние элементы строки
                      Icon(Icons.check_circle_rounded, color: Colors.green.shade600), // Иконка успеха
                      const SizedBox(width: 8),          // Промежуток
                      const Text('Пост создан!'),        // Текст заголовка
                    ],                                   // Завершение children
                  ),                                     // Завершение title
                  content: Column(                       // Содержимое диалога: отображаем полученный сервером объект
                    mainAxisSize: MainAxisSize.min,      // Минимальная высота
                    crossAxisAlignment: CrossAxisAlignment.start, // По левому краю
                    children: [                          // Список строк информации
                      const Text('Сервер вернул объект:'), // Пояснительный текст
                      const SizedBox(height: 8),         // Отступ
                      Container(                         // Плашка с JSON-ответом или полями созданного объекта
                        padding: const EdgeInsets.all(10), // Отступы 10px
                        decoration: BoxDecoration(       // Декорация плашки
                          color: Colors.grey.shade100,   // Светло-серый фон
                          borderRadius: BorderRadius.circular(8), // Радиус 8px
                        ),                               // Завершение BoxDecoration
                        child: Text(                     // Форматированный текст с полями объекта
                          'ID: ${state.createdPost!.id}\n' // Назначенный сервером ID
                          'Автор ID: ${state.createdPost!.userId}\n' // ID автора
                          'Заголовок: ${state.createdPost!.title}\n' // Заголовок
                          'Пометка: ${state.createdPost!.isLocal ? "создан локально" : "серверный"}', // Статус
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'), // Моноширинный шрифт
                        ),                               // Завершение Text
                      ),                                 // Завершение Container
                    ],                                   // Завершение children Column
                  ),                                     // Завершение content
                  actions: [                             // Кнопка подтверждения
                    FilledButton(                        // Кнопка закрытия и возврата в ленту
                      onPressed: () {                    // Нажатие кнопки
                        Navigator.pop(dialogCtx);        // Закрываем диалог
                        Navigator.pop(context, state.createdPost); // Возвращаемся в ленту с новым постом
                      },                                 // Конец onPressed
                      child: const Text('Готово'),       // Текст кнопки
                    ),                                   // Завершение FilledButton
                  ],                                     // Завершение actions
                ),                                       // Завершение AlertDialog
              );                                         // Завершение showDialog
            }                                            // Конец проверки успеха
          },                                             // Конец listener
          builder: (context, state) {                    // Построение содержимого экрана формы
            return SingleChildScrollView(                // Прокрутка при открытии экранной клавиатуры
              padding: const EdgeInsets.all(20.0),       // Отступы формы 20px
              child: Form(                               // Виджет формы Flutter
                key: _formKey,                           // Связываем с ключом валидации
                child: Column(                           // Вертикальное размещение полей ввода
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Растягиваем элементы на всю ширину
                  children: [                            // Дочерние поля формы
                    _buildUserDropdown(context, state),  // Поле выбора автора (userId)
                    const SizedBox(height: 16),          // Отступ
                    _buildTitleField(state),             // Текстовое поле ввода заголовка (5-100 символов)
                    const SizedBox(height: 16),          // Отступ
                    _buildBodyField(state),              // Текстовое поле ввода текста поста (10-1000 символов)
                    const SizedBox(height: 28),          // Отступ перед кнопкой отправки
                    _buildSubmitButton(context, state),  // Кнопка отправки формы с блокировкой повторных кликов
                  ],                                     // Завершение children
                ),                                       // Завершение Column
              ),                                         // Завершение Form
            );                                           // Завершение SingleChildScrollView
          },                                             // Конец builder BlocConsumer
        ),                                               // Завершение BlocConsumer
      ),                                                 // Завершение Scaffold
    );                                                   // Завершение BlocProvider
  }                                                      // Конец build

  Widget _buildUserDropdown(BuildContext context, CreatePostState state) { // Виджет выбора автора
    if (state.isLoadingUsers) {                          // Если список пользователей еще загружается с сервера
      return const Padding(                              // Отступ для лоадера
        padding: EdgeInsets.symmetric(vertical: 12.0),   // 12px по вертикали
        child: Row(                                      // Строка с индикатором
          children: [                                    // Элементы
            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)), // Мини-лоадер
            SizedBox(width: 12),                         // Промежуток
            Text('Загрузка авторов...'),                 // Текст ожидания
          ],                                             // Завершение children
        ),                                               // Завершение Row
      );                                                 // Завершение Padding
    }                                                    // Конец проверки загрузки пользователей

    final users = state.users.isNotEmpty                 // Если пользователи загружены из API
        ? state.users                                    // Берем серверных пользователей
        : List.generate(                                 // Иначе fallback список из 10 авторов (для работы офлайн)
            10,                                          // 10 авторов
            (i) => User(                                 // Создаем пользователя по умолчанию
              id: i + 1,                                 // ID от 1 до 10
              name: 'Пользователь ${i + 1}',             // Имя
              username: 'user_${i + 1}',                 // Логин
              email: 'user${i + 1}@example.com',         // Email
            ),                                           // Завершение User
          );                                             // Завершение fallback

    return DropdownButtonFormField<int>(                 // Поле выпадающего списка выбора автора
      initialValue: _selectedUserId,                     // Начальный выбранный автор
      decoration: InputDecoration(                       // Декорация поля выпадающего списка
        labelText: 'Автор публикации *',                 // Текст метки поля (обязательное)
        hintText: 'Выберите автора',                     // Подсказка
        prefixIcon: const Icon(Icons.person_outline),    // Иконка пользователя слева
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // Скругленная рамка
      ),                                                 // Завершение InputDecoration
      items: users.map((user) {                          // Преобразуем каждого автора в элемент меню DropdownMenuItem
        return DropdownMenuItem<int>(                    // Элемент списка
          value: user.id,                                // Значением является ID автора
          child: Text('${user.name} (ID: ${user.id})'),  // Текст с именем и идентификатором
        );                                               // Завершение DropdownMenuItem
      }).toList(),                                       // Преобразование в List
      onChanged: state.isSubmitting                      // Блокируем изменение во время отправки запроса
          ? null                                         // null отключает поле
          : (val) => setState(() => _selectedUserId = val), // Запоминаем выбранного автора
      validator: (val) => val == null ? 'Обязательно выберите автора' : null, // Валидатор выбора
    );                                                   // Завершение DropdownButtonFormField
  }                                                      // Конец _buildUserDropdown

  Widget _buildTitleField(CreatePostState state) {       // Поле ввода заголовка публикации
    return TextFormField(                                // Виджет валидируемого текстового ввода
      controller: _titleController,                      // Связываем с контроллером
      enabled: !state.isSubmitting,                      // Блокируем поле ввода во время отправки
      maxLength: 100,                                    // Максимум 100 символов (требование ТЗ)
      decoration: InputDecoration(                       // Оформление поля
        labelText: 'Заголовок публикации *',             // Метка обязательного поля
        hintText: 'От 5 до 100 символов',                // Подсказка о допустимой длине
        prefixIcon: const Icon(Icons.title),             // Иконка заголовка
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // Рамка 12px
      ),                                                 // Завершение InputDecoration
      validator: (value) {                               // Функция валидации заголовка
        final text = value?.trim() ?? '';                // Получаем введенный текст без краевых пробелов
        if (text.length < 5) {                           // Минимум 5 символов (требование ТЗ)
          return 'Минимум 5 символов (сейчас: ${text.length})'; // Ошибка недостаточной длины
        }                                                // Конец проверки минимума
        if (text.length > 100) {                         // Максимум 100 символов
          return 'Максимум 100 символов';                // Ошибка превышения лимита
        }                                                // Конец проверки максимума
        return null;                                     // Валидация пройдена успешно
      },                                                 // Конец validator
    );                                                   // Завершение TextFormField
  }                                                      // Конец _buildTitleField

  Widget _buildBodyField(CreatePostState state) {        // Поле ввода содержимого поста
    return TextFormField(                                // Текстовое поле для содержимого
      controller: _bodyController,                       // Связываем с контроллером текста
      enabled: !state.isSubmitting,                      // Блокируем при отправке
      maxLines: 5,                                       // Высота поля в 5 строк
      maxLength: 1000,                                   // Максимум 1000 символов (требование ТЗ)
      decoration: InputDecoration(                       // Оформление поля
        labelText: 'Содержимое публикации *',            // Метка обязательного поля
        hintText: 'От 10 до 1000 символов',              // Подсказка лимитов текста
        alignLabelWithHint: true,                        // Выравнивание метки по верхнему краю при многострочном вводе
        prefixIcon: const Padding(                       // Иконка в верхнем левом углу
          padding: EdgeInsets.only(bottom: 80),          // Смещение иконки наверх
          child: Icon(Icons.article_outlined),           // Иконка статьи
        ),                                               // Завершение Padding
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // Рамка 12px
      ),                                                 // Завершение InputDecoration
      validator: (value) {                               // Валидатор содержимого поста
        final text = value?.trim() ?? '';                // Текст без пробелов
        if (text.length < 10) {                          // Минимум 10 символов (требование ТЗ)
          return 'Минимум 10 символов (сейчас: ${text.length})'; // Ошибка валидации
        }                                                // Конец проверки
        if (text.length > 1000) {                        // Максимум 1000 символов
          return 'Максимум 1000 символов';               // Ошибка длины
        }                                                // Конец проверки
        return null;                                     // Успех
      },                                                 // Конец validator
    );                                                   // Завершение TextFormField
  }                                                      // Конец _buildBodyField

  Widget _buildSubmitButton(BuildContext context, CreatePostState state) { // Кнопка отправки формы
    return FilledButton(                                 // Большая кнопка подтверждения
      onPressed: state.isSubmitting                      // Блокировка повторного нажатия во время отправки (ТЗ Задание F)
          ? null                                         // Если идет отправка — кнопка неактивна (null)
          : () {                                         // Если отправка не идет — обрабатываем клик
              if (_formKey.currentState?.validate() ?? false) { // Проверяем клиентскую валидацию всех полей
                if (_selectedUserId == null) {           // Дополнительная проверка выбора автора
                  ScaffoldMessenger.of(context).showSnackBar( // Предупреждение о необходимости автора
                    const SnackBar(content: Text('Выберите автора')), // Текст
                  );                                     // Завершение SnackBar
                  return;                                // Прерывание
                }                                        // Конец проверки автора
                context.read<CreatePostBloc>().add(      // Отправляем событие в BLoC для POST-запроса через Retrofit
                      CreatePostSubmitted(               // Объект события с данными полей формы
                        title: _titleController.text,    // Введенный заголовок
                        body: _bodyController.text,      // Введенный текст публикации
                        userId: _selectedUserId!,        // Выбранный ID автора
                      ),                                 // Завершение CreatePostSubmitted
                    );                                   // Завершение add
              }                                          // Конец проверки валидации формы
            },                                           // Конец onPressed
      style: FilledButton.styleFrom(                     // Стилизация кнопки
        padding: const EdgeInsets.symmetric(vertical: 16), // Высота кнопки (внутренний отступ 16px)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Скругление 12px
      ),                                                 // Завершение styleFrom
      child: state.isSubmitting                          // Переключение содержимого кнопки при отправке
          ? const SizedBox(                              // Если идет запрос — крутится круговой лоадер
              width: 20,                                 // Ширина лоадера
              height: 20,                                // Высота лоадера
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white), // Белый индикатор
            )                                            // Завершение SizedBox
          : const Text(                                  // Если отправка не идет — обычный текст кнопки
              'Опубликовать пост',                       // Текст действия
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Стиль текста кнопки
            ),                                           // Завершение Text
    );                                                   // Завершение FilledButton
  }                                                      // Конец _buildSubmitButton
}                                                        // Конец _CreatePostScreenState
