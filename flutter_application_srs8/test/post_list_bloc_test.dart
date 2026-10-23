import 'package:bloc_test/bloc_test.dart';                                // Библиотека bloc_test для декларативного тестирования BLoC
import 'package:flutter_application_srs8/data/models/post.dart';         // Модель публикации
import 'package:flutter_application_srs8/data/repositories/post_repository.dart'; // Репозиторий постов
import 'package:flutter_application_srs8/presentation/bloc/post_list/post_list_bloc.dart'; // Тестируемый PostListBloc
import 'package:flutter_application_srs8/presentation/bloc/post_list/post_list_event.dart'; // События BLoC
import 'package:flutter_application_srs8/presentation/bloc/post_list/post_list_state.dart'; // Состояния BLoC
import 'package:flutter_test/flutter_test.dart';                         // Тестовый фреймворк Flutter
import 'package:mocktail/mocktail.dart';                                 // Библиотека моков

class MockPostRepository extends Mock implements PostRepository {}       // Мок-класс для репозитория постов

void main() {                                                            // Точка входа в блок тестов BLoC
  late MockPostRepository mockRepository;                                // Экземпляр мока репозитория

  setUp(() {                                                             // Инициализация перед каждым тестом
    mockRepository = MockPostRepository();                               // Создаем чистый мок репозитория
  });                                                                    // Конец setUp

  group('Тестирование PostListBloc (Задание 7, Тесты 5 и 6)', () {       // Группа тестов BLoC

    final samplePosts = [                                                // Набор публикаций для тестирования фильтрации
      const Post(id: 3, userId: 1, title: 'Flutter архитектура', body: 'Текст о BLoC'), // Пост 3
      const Post(id: 1, userId: 2, title: 'Dart программирование', body: 'Текст о Dart'), // Пост 1
      const Post(id: 2, userId: 1, title: 'Flutter UI дизайн', body: 'Текст о виджетах'), // Пост 2
    ];                                                                   // Завершение тестового набора

    blocTest<PostListBloc, PostListState>(                               // Тест 5 по ТЗ: фильтрация и поиск
      'Тест 5: Фильтрация постов по заголовку и сортировка по ID',       // Название теста
      build: () => PostListBloc(postRepository: mockRepository),         // Инициализация тестируемого BLoC
      seed: () => PostListState(                                         // Предустанавливаем начальное состояние с 3 постами
        status: PostListStatus.success,                                  // Статус «успешно»
        posts: samplePosts,                                              // Исходный список постов
        displayedPosts: samplePosts,                                     // Отображаемый список
        sortAscending: true,                                             // Сортировка по возрастанию
      ),                                                                 // Завершение seed
      act: (bloc) {                                                      // Действие: выполняем поиск по слову "UI"
        bloc.add(const PostListSearchQueryChanged('UI'));                // Ищем публикации со словом "UI" в заголовке
      },                                                                 // Конец act
      expect: () => [                                                    // Ожидаемое состояние после поиска
        predicate<PostListState>((state) {                               // Проверяем предикатом
          return state.displayedPosts.length == 1 &&                     // Должен остаться только 1 пост
              state.displayedPosts.first.id == 2 &&                      // Это пост с ID 2 ("Flutter UI дизайн")
              state.searchQuery == 'UI';                                 // Поисковая строка зафиксирована как 'UI'
        }),                                                              // Конец predicate
      ],                                                                 // Конец expect
    );                                                                   // Конец blocTest (Тест 5)

    blocTest<PostListBloc, PostListState>(                               // Тест 6 по ТЗ: защита от дублирования пагинации
      'Тест 6: Защита от дублирующейся загрузки страницы (если уже isLoadingMore)', // Название теста
      build: () => PostListBloc(postRepository: mockRepository),         // Инициализация BLoC
      seed: () => const PostListState(                                   // Предустанавливаем состояние: загрузка УЖЕ идет
        status: PostListStatus.success,                                  // Текущий статус успех
        isLoadingMore: true,                                             // В данный момент УЖЕ выполняется запрос страницы
        page: 1,                                                         // 1-я страница
      ),                                                                 // Завершение seed
      act: (bloc) {                                                      // Пытаемся вызвать повторный запрос пагинации
        bloc.add(const PostListNextPageRequested());                     // Дополнительный вызов события пагинации
      },                                                                 // Конец act
      expect: () => [],                                                  // BLoC НЕ должен эмитить новых состояний и блокирует запрос
      verify: (_) {                                                      // Проверяем вызовы репозитория
        verifyNever(() => mockRepository.getPostsFromServer(             // Убеждаемся, что повторный сетевой запрос НЕ был вызван
              page: any(named: 'page'),                                  // Любая страница
              limit: any(named: 'limit'),                                // Любой лимит
              userId: any(named: 'userId'),                              // Любой автор
            ));                                                          // Завершение verifyNever
      },                                                                 // Конец verify
    );                                                                   // Конец blocTest (Тест 6)

    blocTest<PostListBloc, PostListState>(                               // Тест 6 (дополнительно): защита при hasReachedMax
      'Тест 6 (дополнительно): Защита от загрузки при достижении конца списка (hasReachedMax)', // Название теста
      build: () => PostListBloc(postRepository: mockRepository),         // Инициализация BLoC
      seed: () => const PostListState(                                   // Предустановка состояния конца списка
        status: PostListStatus.success,                                  // Успех
        hasReachedMax: true,                                             // Конец списка уже достигнут
        page: 10,                                                        // Последняя страница
      ),                                                                 // Завершение seed
      act: (bloc) {                                                      // Попытка пагинации
        bloc.add(const PostListNextPageRequested());                     // Отправка события
      },                                                                 // Конец act
      expect: () => [],                                                  // Никаких новых запросов
      verify: (_) {                                                      // Проверка отсутствия сетевых вызовов
        verifyNever(() => mockRepository.getPostsFromServer(             // Репозиторий не дергается
              page: any(named: 'page'),                                  // Страница
              limit: any(named: 'limit'),                                // Лимит
              userId: any(named: 'userId'),                              // Автор
            ));                                                          // Конец verifyNever
      },                                                                 // Конец verify
    );                                                                   // Конец blocTest
  });                                                                    // Конец группы тестов
}                                                                        // Конец main
