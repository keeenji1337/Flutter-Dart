import 'package:flutter_application_srs8/data/local/post_cache.dart';    // Локальный кэш
import 'package:flutter_application_srs8/data/models/post.dart';         // Модель поста
import 'package:flutter_application_srs8/data/remote/post_api.dart';      // Интерфейс API
import 'package:flutter_application_srs8/data/repositories/post_repository.dart'; // Репозиторий постов
import 'package:flutter_application_srs8/main.dart';                      // Главный класс приложения MyApp
import 'package:flutter_test/flutter_test.dart';                         // Тестовый фреймворк виджетов Flutter
import 'package:mocktail/mocktail.dart';                                 // Библиотека моков

class MockPostApi extends Mock implements PostApi {}                     // Мок API
class MockPostCache extends Mock implements PostCache {}                 // Мок кэша

void main() {                                                            // Точка входа в UI-тесты виджетов
  setUpAll(() {                                                          // Настройка один раз перед всеми тестами
    registerFallbackValue(<Post>[]);                                     // Регистрируем fallback-значение списка постов для mocktail
  });                                                                    // Конец setUpAll

  testWidgets('Проверка запуска корневого виджета MyApp и отображения ленты постов', (WidgetTester tester) async { // UI-тест
    final mockApi = MockPostApi();                                       // Создаем мок API
    final mockCache = MockPostCache();                                   // Создаем мок кэша

    when(() => mockCache.hasCachedPosts()).thenAnswer((_) async => false); // В кэше ничего нет
    when(() => mockCache.getCachedPosts()).thenAnswer((_) async => []);   // Пустой кэш
    when(() => mockCache.savePosts(any())).thenAnswer((_) async {});     // Обучаем мок кэширования первой страницы
    when(() => mockApi.getPosts(1, 10)).thenAnswer((_) async => [        // Мок первой страницы с 1 постом
          const Post(id: 1, userId: 1, title: 'Тестовый пост', body: 'Текст тестового поста'), // Тестовый пост
        ]);                                                              // Завершение ответа

    final repository = PostRepository(postApi: mockApi, postCache: mockCache); // Инициализация репозитория

    await tester.pumpWidget(MyApp(postRepository: repository));          // Строим дерево виджетов приложения

    expect(find.text('Post Explorer'), findsOneWidget);                  // Проверяем наличие заголовка в AppBar

    await tester.pumpAndSettle();                                        // Ждем завершения всех асинхронных операций BLoC

    expect(find.text('Тестовый пост'), findsOneWidget);                  // Проверяем, что загруженный пост отобразился в ленте
    expect(find.text('Автор: ID 1'), findsOneWidget);                    // Проверяем отображение автора публикации
  });                                                                    // Конец теста виджета
}                                                                        // Конец main
