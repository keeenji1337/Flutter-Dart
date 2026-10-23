import 'package:dio/dio.dart';                                       // Библиотека Dio для имитации сетевых ошибок
import 'package:flutter_application_srs8/core/error/app_exception.dart'; // Доменные исключения приложения
import 'package:flutter_application_srs8/data/local/post_cache.dart';    // Сервис локального кэширования
import 'package:flutter_application_srs8/data/models/post.dart';         // Модель публикации
import 'package:flutter_application_srs8/data/remote/post_api.dart';      // Интерфейс Retrofit
import 'package:flutter_application_srs8/data/repositories/post_repository.dart'; // Тестируемый репозиторий
import 'package:flutter_test/flutter_test.dart';                         // Фреймворк тестирования Flutter
import 'package:mocktail/mocktail.dart';                                 // Библиотека для создания mock-объектов

class MockPostApi extends Mock implements PostApi {}                     // Мок-класс для удаленного API Retrofit
class MockPostCache extends Mock implements PostCache {}                 // Мок-класс для локального хранилища SharedPreferences

void main() {                                                            // Точка входа в блок тестов репозитория
  late MockPostApi mockApi;                                              // Объявляем переменную мока API
  late MockPostCache mockCache;                                          // Объявляем переменную мока кэша
  late PostRepository repository;                                        // Тестируемый экземпляр репозитория

  setUp(() {                                                             // Выполняется перед каждым тестом
    mockApi = MockPostApi();                                             // Создаем свежий мок API
    mockCache = MockPostCache();                                         // Создаем свежий мок кэша
    repository = PostRepository(postApi: mockApi, postCache: mockCache); // Создаем репозиторий с внедренными моками
  });                                                                    // Конец setUp

  group('Тестирование PostRepository (Задание 7, Тесты 3 и 4)', () {     // Группа тестов репозитория

    test('Тест 3: Успешная загрузка постов через репозиторий', () async { // Тест 3 по ТЗ
      final testPosts = [                                                // Набор тестовых публикаций
        const Post(id: 1, userId: 1, title: 'Пост 1', body: 'Текст 1'), // Первый тестовый пост
        const Post(id: 2, userId: 1, title: 'Пост 2', body: 'Текст 2'), // Второй тестовый пост
      ];                                                                 // Завершение списка

      when(() => mockApi.getPosts(1, 10))                                // Обучаем мок: при вызове getPosts(1, 10)
          .thenAnswer((_) async => testPosts);                           // Возвращать тестовый список
      when(() => mockCache.savePosts(testPosts))                         // Обучаем мок сохранения в кэш
          .thenAnswer((_) async {});                                     // Завершается успешно без возврата значения

      final result = await repository.getPostsFromServer(page: 1, limit: 10); // Вызываем тестируемый метод репозитория

      expect(result, equals(testPosts));                                 // Проверяем, что вернулся ожидаемый список
      expect(result.length, equals(2));                                  // Проверяем количество полученных элементов
      verify(() => mockApi.getPosts(1, 10)).called(1);                   // Убеждаемся, что запрос к API был вызван ровно 1 раз
      verify(() => mockCache.savePosts(testPosts)).called(1);            // Проверяем, что первая страница сохранилась в локальный кэш
    });                                                                  // Конец Теста 3

    test('Тест 4: Обработка ошибки сервера (HTTP 500 -> ServerException)', () async { // Тест 4 по ТЗ
      final dioError = DioException(                                     // Имитируем ошибку библиотеки Dio
        requestOptions: RequestOptions(path: '/posts'),                  // Путь запроса
        response: Response(                                              // Ответ сервера с ошибкой
          statusCode: 500,                                               // Код ошибки 500 (Internal Server Error)
          requestOptions: RequestOptions(path: '/posts'),                // Опции запроса
        ),                                                               // Завершение Response
        type: DioExceptionType.badResponse,                              // Тип ошибки: некорректный ответ сервера
      );                                                                 // Завершение создания DioException

      when(() => mockApi.getPosts(1, 10))                                // Обучаем мок API
          .thenThrow(dioError);                                          // Выбрасывать смоделированную ошибку Dio

      expect(                                                            // Ожидаем выброса типизированного AppException
        () => repository.getPostsFromServer(page: 1, limit: 10),        // Вызов метода репозитория
        throwsA(isA<ServerException>()),                                 // Проверяем, что ошибка преобразовалась в ServerException
      );                                                                 // Завершение expect
      verify(() => mockApi.getPosts(1, 10)).called(1);                   // Запрос был выполнен 1 раз
      verifyNever(() => mockCache.savePosts(any()));                     // При ошибке кэш НЕ должен перезаписываться
    });                                                                  // Конец Теста 4

    test('Тест 4 (дополнительно): Обработка ошибки отсутствия интернета (NetworkException)', () async { // Проверка сети
      final noInternetError = DioException(                              // Имитируем отсутствие соединения
        requestOptions: RequestOptions(path: '/posts'),                  // Путь запроса
        type: DioExceptionType.connectionError,                          // Ошибка соединения
      );                                                                 // Завершение DioException

      when(() => mockApi.getPosts(1, 10)).thenThrow(noInternetError);    // Обучаем мок бросать ошибку сети

      expect(                                                            // Ожидаем сетевое исключение
        () => repository.getPostsFromServer(page: 1, limit: 10),        // Вызов метода
        throwsA(isA<NetworkException>()),                                // Проверяем преобразование в NetworkException
      );                                                                 // Завершение expect
    });                                                                  // Конец дополнительного теста

    test('Тест создания поста: Создание публикации возвращает объект с флагом isLocal=true', () async { // Проверка создания поста
      const serverReturnedPost = Post(id: 101, userId: 2, title: 'Заголовок', body: 'Текст', isLocal: false); // Серверный пост
      when(() => mockApi.createPost(any()))                              // Моделируем вызов POST /posts
          .thenAnswer((_) async => serverReturnedPost);                  // Возвращаем объект

      final result = await repository.createPost(                        // Вызываем метод создания в репозитории
        title: 'Заголовок',                                              // Заголовок
        body: 'Текст',                                                   // Текст
        userId: 2,                                                       // Автор
      );                                                                 // Завершение вызова

      expect(result.id, equals(101));                                    // ID присвоен
      expect(result.isLocal, isTrue);                                    // Флаг локального создания успешно установлен
    });                                                                  // Конец теста создания поста
  });                                                                    // Конец группы тестов репозитория
}                                                                        // Конец main
