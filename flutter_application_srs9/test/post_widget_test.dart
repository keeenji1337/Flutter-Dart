import 'package:flutter/material.dart';                                                   // Библиотека виджетов Material Design для построения UI-дерева в тестах
import 'package:flutter_application_srs9/data/local/post_cache.dart';              // Мок-класс локального хранилища кэша
import 'package:flutter_application_srs9/data/models/post.dart';                    // Модель публикации (поста) для тестовых данных
import 'package:flutter_application_srs9/data/models/user.dart';                    // Модель автора для экрана создания публикации
import 'package:flutter_application_srs9/data/remote/post_api.dart';                // Мок-класс удаленного REST API
import 'package:flutter_application_srs9/data/repositories/post_repository.dart';   // Репозиторий постов для внедрения через RepositoryProvider
import 'package:flutter_application_srs9/presentation/bloc/post_list/post_list_bloc.dart'; // BLoC списка публикаций
import 'package:flutter_application_srs9/presentation/bloc/post_list/post_list_event.dart'; // События BLoC списка публикаций
import 'package:flutter_application_srs9/presentation/screens/create_post_screen.dart'; // Экран формы создания публикации
import 'package:flutter_application_srs9/presentation/screens/post_list_screen.dart';   // Главный экран каталога публикаций
import 'package:flutter_application_srs9/presentation/widgets/post_card.dart';     // Компонент карточки публикации
import 'package:flutter_bloc/flutter_bloc.dart';                                    // Пакет flutter_bloc для провайдеров BLoC и RepositoryProvider
import 'package:flutter_test/flutter_test.dart';                                   // Фреймворк Widget-тестирования Flutter с WidgetTester
import 'package:mocktail/mocktail.dart';                                           // Библиотека для создания моков в тестах

class MockPostApi extends Mock implements PostApi {}                               // Мок-класс для эмуляции сетевых вызовов Retrofit
class MockPostCache extends Mock implements PostCache {}                           // Мок-класс для эмуляции операций с кэшем SharedPreferences

void main() {                                                                      // Главная функция запуска набора Widget-тестов
  late MockPostApi mockApi;                                                        // Переменная для экземпляра мок-клиента API
  late MockPostCache mockCache;                                                    // Переменная для экземпляра мок-сервиса кэша
  late PostRepository repository;                                                  // Репозиторий для внедрения в тестируемые экраны

  setUpAll(() {                                                                    // Однократная настройка перед всеми тестами
    registerFallbackValue(<Post>[]);                                               // Регистрация fallback-значения List<Post> для mocktail
    registerFallbackValue(<String, dynamic>{});                                    // Регистрация fallback-значения Map для POST-запросов
  });                                                                              // Завершение setUpAll

  setUp(() {                                                                       // Подготовка свежего состояния перед каждым отдельным тестом
    mockApi = MockPostApi();                                                       // Инициализация нового экземпляра MockPostApi
    mockCache = MockPostCache();                                                   // Инициализация нового экземпляра MockPostCache
    repository = PostRepository(postApi: mockApi, postCache: mockCache);           // Создание репозитория с подставленными моками

    when(() => mockCache.hasCachedPosts()).thenAnswer((_) async => false);         // Кэш изначально пуст (нет кэшированных данных)
    when(() => mockCache.getCachedPosts()).thenAnswer((_) async => []);            // Метод чтения кэша возвращает пустой список
    when(() => mockCache.savePosts(any())).thenAnswer((_) async {});               // Метод сохранения в кэш успешно завершается
    when(() => mockApi.getUsers()).thenAnswer((_) async => [                       // Возвращаем список авторов для выпадающего меню
          const User(id: 1, name: 'Алексей Иванов', username: 'alex', email: 'alex@mail.com'), // Автор 1
          const User(id: 2, name: 'Ольга Петрова', username: 'olga', email: 'olga@mail.com'),  // Автор 2
        ]);                                                                        // Завершение списка авторов
  });                                                                              // Завершение setUp

  Widget createWidgetUnderTest({required Widget child}) {                          // Вспомогательная функция сборки дерева с DI-провайдерами
    return RepositoryProvider<PostRepository>.value(                               // Предоставление репозитория через контекст виджетов
      value: repository,                                                           // Передача настроенного репозитория
      child: BlocProvider<PostListBloc>(                                           // Предоставление глобального BLoC списка публикаций
        create: (context) => PostListBloc(postRepository: repository)              // Фабрика инициализации BLoC
          ..add(const PostListStarted()),                                          // Немедленный запуск начальной загрузки постов
        child: MaterialApp(                                                        // Корневой MaterialApp для поддержки стилей и навигации
          home: child,                                                             // Тестируемый экран в качестве домашней страницы
        ),                                                                         // Завершение MaterialApp
      ),                                                                           // Завершение BlocProvider
    );                                                                             // Завершение RepositoryProvider
  }                                                                                // Конец createWidgetUnderTest

  group('Практическое задание №3: Widget-тестирование экранов и взаимодействия', () { // Группа интерфейсных тестов

    // -------------------------------------------------------------------------
    // WIDGET ТЕСТ 1: Отображение основного экрана, заголовка и ключевых элементов
    // -------------------------------------------------------------------------
    testWidgets('Widget Test 1: Отображение экрана PostListScreen, заголовка и элементов UI', (WidgetTester tester) async { // Проверка элементов
      final samplePosts = [                                                        // Тестовые данные для отображения в списке
        const Post(id: 1, userId: 1, title: 'Первая статья', body: 'Текст статьи 1'), // Первый пост
        const Post(id: 2, userId: 2, title: 'Вторая статья', body: 'Текст статьи 2'), // Второй пост
      ];                                                                           // Завершение samplePosts

      when(() => mockApi.getPosts(1, 10)).thenAnswer((_) async => samplePosts);    // Возврат 2 постов при запросе 1-й страницы

      await tester.pumpWidget(createWidgetUnderTest(child: const PostListScreen())); // Монтирование дерева виджетов в виртуальный экран
      await tester.pumpAndSettle();                                                // Ожидание завершения всех асинхронных операций и анимаций

      expect(find.text('Post Explorer'), findsOneWidget);                          // Проверка наличия заголовка приложения в AppBar
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);                  // Проверка наличия кнопки обновления ленты
      expect(find.byType(TextField), findsOneWidget);                              // Проверка наличия текстового поля поиска публикаций
      expect(find.text('Создать пост'), findsOneWidget);                           // Проверка наличия плавающей кнопки с текстом 'Создать пост'
      expect(find.byIcon(Icons.add), findsOneWidget);                              // Проверка наличия иконки добавления на кнопке
      expect(find.text('Первая статья'), findsOneWidget);                          // Проверка отображения заголовка первой статьи в ленте
      expect(find.text('Вторая статья'), findsOneWidget);                          // Проверка отображения заголовка второй статьи в ленте
    });                                                                            // Завершение теста 1

    // -------------------------------------------------------------------------
    // WIDGET ТЕСТ 2: Интерактивное взаимодействие со строкой поиска и очистка
    // -------------------------------------------------------------------------
    testWidgets('Widget Test 2: Ввод текста в поиск, появление и нажатие кнопки очистки', (WidgetTester tester) async { // Проверка поиска
      when(() => mockApi.getPosts(1, 10)).thenAnswer((_) async => [               // Мок-ответ со списком статей
            const Post(id: 1, userId: 1, title: 'Flutter Widgets', body: 'Body 1'), // Пост о виджетах
          ]);                                                                      // Завершение списка

      await tester.pumpWidget(createWidgetUnderTest(child: const PostListScreen())); // Сборка экрана каталога
      await tester.pumpAndSettle();                                                // Завершение начального рендера

      expect(find.byIcon(Icons.clear), findsNothing);                              // Иконка крестика очистки изначально скрыта (поле пустое)

      await tester.enterText(find.byType(TextField), 'Flutter');                   // Симуляция пользовательского ввода слова 'Flutter'
      await tester.pumpAndSettle();                                                // Перерисовка интерфейса с обновленным текстом

      expect(find.text('Flutter'), findsOneWidget);                                // Проверка отображения введенного слова в строке поиска
      expect(find.byIcon(Icons.clear), findsOneWidget);                            // Иконка очистки появилась в правой части поля

      await tester.tap(find.byIcon(Icons.clear));                                  // Клик пользователя по кнопке очистки поиска
      await tester.pumpAndSettle();                                                // Перерисовка экрана после очистки

      expect(find.byIcon(Icons.clear), findsNothing);                              // Кнопка очистки снова исчезла после сброса текста
    });                                                                            // Завершение теста 2

    // -------------------------------------------------------------------------
    // WIDGET ТЕСТ 3 (Бонус 3): Взаимодействие нескольких элементов формы и валидация
    // -------------------------------------------------------------------------
    testWidgets('Widget Test 3: Валидация и взаимодействие элементов формы на CreatePostScreen', (WidgetTester tester) async { // Комплексный тест формы
      await tester.pumpWidget(createWidgetUnderTest(child: const CreatePostScreen())); // Открытие экрана формы создания публикации
      await tester.pumpAndSettle();                                                // Ожидание завершения загрузки авторов

      expect(find.text('Создать публикацию'), findsOneWidget);                     // Проверка заголовка AppBar экрана создания
      expect(find.text('Опубликовать пост'), findsOneWidget);                      // Проверка кнопки отправки публикации

      await tester.tap(find.text('Опубликовать пост'));                            // Нажатие кнопки отправки при полностью пустых полях формы
      await tester.pumpAndSettle();                                                // Запуск валидаторов формы Flutter Form

      expect(find.text('Обязательно выберите автора'), findsOneWidget);             // Сообщение валидатора: автор не выбран
      expect(find.textContaining('Минимум 5 символов'), findsOneWidget);            // Сообщение валидатора заголовка: требуется не менее 5 символов
      expect(find.textContaining('Минимум 10 символов'), findsOneWidget);           // Сообщение валидатора содержимого: требуется не менее 10 символов

      final textFields = find.byType(TextFormField);                               // Поиск всех текстовых полей ввода на экране формы
      await tester.enterText(textFields.at(0), 'Валидный заголовок статьи');       // Ввод корректного заголовка (> 5 символов) в первое поле
      await tester.enterText(textFields.at(1), 'Текст статьи длиной более десяти символов'); // Ввод корректного тела (> 10 символов) во второе поле
      await tester.pumpAndSettle();                                                // Обновление состояния контроллеров

      await tester.tap(find.text('Опубликовать пост'));                            // Повторное нажатие кнопки отправки формы
      await tester.pumpAndSettle();                                                // Запуск повторной валидации формы

      expect(find.textContaining('Минимум 5 символов'), findsNothing);             // Ошибка заголовка исчезла, так как условие длины выполнено
      expect(find.textContaining('Минимум 10 символов'), findsNothing);            // Ошибка текста исчезла, так как условие длины выполнено
    });                                                                            // Завершение теста 3

    // -------------------------------------------------------------------------
    // WIDGET ТЕСТ 4 (Доп. 4): Переход между экранами навигации и возврат назад
    // -------------------------------------------------------------------------
    testWidgets('Widget Test 4: Переход с PostListScreen на CreatePostScreen и возврат назад', (WidgetTester tester) async { // Тест навигации
      when(() => mockApi.getPosts(1, 10)).thenAnswer((_) async => []);             // Пустой список постов для простоты навигации

      await tester.pumpWidget(createWidgetUnderTest(child: const PostListScreen())); // Запуск основного экрана в стеке навигатора MaterialApp
      await tester.pumpAndSettle();                                                // Ожидание завершения построения основного экрана

      expect(find.text('Post Explorer'), findsOneWidget);                          // Находимся на главном экране списка
      expect(find.text('Создать публикацию'), findsNothing);                       // Экран создания еще не открыт

      await tester.tap(find.text('Создать пост'));                                 // Клик по FloatingActionButton для перехода на экран создания
      await tester.pumpAndSettle();                                                // Ожидание анимации перехода Navigator.push

      expect(find.text('Создать публикацию'), findsOneWidget);                     // Успешно перешли на экран CreatePostScreen
      expect(find.byType(BackButton), findsOneWidget);                             // Наличие стандартной кнопки Назад в AppBar

      await tester.tap(find.byType(BackButton));                                   // Клик по кнопке Назад для возврата
      await tester.pumpAndSettle();                                                // Ожидание завершения анимации Navigator.pop

      expect(find.text('Post Explorer'), findsOneWidget);                          // Снова вернулись на главный экран PostListScreen
      expect(find.text('Создать публикацию'), findsNothing);                       // Экран создания закрыт и удален из стека навигации
    });                                                                            // Завершение теста 4

    // -------------------------------------------------------------------------
    // WIDGET ТЕСТ 5: Изолированное тестирование компонента карточки PostCard
    // -------------------------------------------------------------------------
    testWidgets('Widget Test 5: Отрисовка компонента PostCard и реакция на нажатие', (WidgetTester tester) async { // Тест виджета PostCard
      bool wasTapped = false;                                                      // Флаг для фиксации факта нажатия на карточку

      const testPost = Post(                                                       // Экземпляр поста для проверки карточки
        id: 77,                                                                    // ID публикации
        userId: 3,                                                                 // ID автора
        title: 'Заголовок карточки',                                               // Заголовок
        body: 'Подробное описание внутри карточки поста',                          // Текст
        isLocal: false,                                                            // Серверный статус
      );                                                                           // Завершение описания тестового поста

      await tester.pumpWidget(                                                     // Монтирование изолированного виджета PostCard
        MaterialApp(                                                               // Обертка MaterialApp
          home: Scaffold(                                                          // Обертка Scaffold
            body: PostCard(                                                        // Тестируемый виджет карточки публикации
              post: testPost,                                                      // Передача модели поста
              onTap: () => wasTapped = true,                                       // Колбэк клика: устанавливает флаг wasTapped в true
            ),                                                                     // Завершение PostCard
          ),                                                                       // Завершение Scaffold
        ),                                                                         // Завершение MaterialApp
      );                                                                           // Завершение pumpWidget

      expect(find.text('#77'), findsOneWidget);                                    // Проверка отображения плашки с ID публикации #77
      expect(find.text('Автор: ID 3'), findsOneWidget);                            // Проверка отображения строки автора
      expect(find.text('Заголовок карточки'), findsOneWidget);                     // Проверка отображения заголовка
      expect(find.text('Подробное описание внутри карточки поста'), findsOneWidget); // Проверка отображения текста публикации
      expect(find.byType(InkWell), findsOneWidget);                                // Проверка наличия интерактивной области клика InkWell

      await tester.tap(find.byType(PostCard));                                     // Клик по карточке публикации
      await tester.pump();                                                         // Обработка события жеста

      expect(wasTapped, isTrue);                                                   // Проверка: колбэк onTap успешно сработал
    });                                                                            // Завершение теста 5

  });                                                                              // Завершение группы Widget-тестов
}                                                                                  // Конец функции main
