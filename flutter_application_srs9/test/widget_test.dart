import 'package:flutter_application_srs9/data/local/post_cache.dart';              // Сервис локального кэширования для создания мока
import 'package:flutter_application_srs9/data/models/post.dart';                    // Доменная модель публикации
import 'package:flutter_application_srs9/data/remote/post_api.dart';                // Контракт удаленного REST API
import 'package:flutter_application_srs9/data/repositories/post_repository.dart';   // Репозиторий постов для внедрения в корневой виджет
import 'package:flutter_application_srs9/main.dart';                                // Главный класс приложения MyApp
import 'package:flutter_test/flutter_test.dart';                                   // Фреймворк тестирования виджетов Flutter
import 'package:mocktail/mocktail.dart';                                           // Библиотека для создания моков

class MockPostApi extends Mock implements PostApi {}                               // Мок-класс для эмуляции сетевых вызовов Retrofit
class MockPostCache extends Mock implements PostCache {}                           // Мок-класс для эмуляции кэш-хранилища

void main() {                                                                      // Точка входа в базовый smoke-тест приложения
  setUpAll(() {                                                                    // Однократная настройка перед выполнением теста
    registerFallbackValue(<Post>[]);                                               // Регистрация fallback-значения для мока кэша
  });                                                                              // Завершение setUpAll

  testWidgets('Smoke Test: Запуск приложения MyApp и начальная загрузка экрана', (WidgetTester tester) async { // Дымовой тест запуска
    final mockApi = MockPostApi();                                                 // Создание экземпляра мок-клиента API
    final mockCache = MockPostCache();                                             // Создание экземпляра мок-кэша

    when(() => mockCache.hasCachedPosts()).thenAnswer((_) async => false);         // Кэш пуст
    when(() => mockCache.getCachedPosts()).thenAnswer((_) async => []);            // Чтение из кэша возвращает пустой список
    when(() => mockCache.savePosts(any())).thenAnswer((_) async {});               // Сохранение в кэш отрабатывает успешно
    when(() => mockApi.getPosts(1, 10)).thenAnswer((_) async => [                  // Мок первой страницы постов
          const Post(id: 1, userId: 1, title: 'Заголовок smoke-теста', body: 'Тело smoke-теста'), // Тестовый пост
        ]);                                                                        // Завершение мок-ответа

    final repository = PostRepository(postApi: mockApi, postCache: mockCache);     // Инициализация репозитория с моками

    await tester.pumpWidget(MyApp(postRepository: repository));                    // Запуск корневого виджета приложения MyApp
    expect(find.text('Post Explorer'), findsOneWidget);                            // Проверка немедленного отображения заголовка в AppBar

    await tester.pumpAndSettle();                                                  // Ожидание завершения загрузки BLoC и стабилизации UI
    expect(find.text('Заголовок smoke-теста'), findsOneWidget);                    // Проверка успешного отображения загруженного поста в ленте
  });                                                                              // Завершение smoke-теста
}                                                                                  // Конец main
