import 'package:dio/dio.dart';                                       // HTTP-клиент Dio
import 'package:flutter_application_srs8/data/remote/post_api.dart';      // Retrofit REST-клиент
import 'package:flutter_test/flutter_test.dart';                         // Тестовый фреймворк Flutter
import 'package:http_mock_adapter/http_mock_adapter.dart';               // Библиотека DioAdapter для перехвата и мокирования HTTP-запросов

void main() {                                                            // Точка входа в блок тестов с mock-адаптером Dio
  group('Тестирование отправки POST через Mock-адаптер Dio (Дополнительное ТЗ 7)', () { // Группа тестов без интернета

    late Dio dio;                                                        // Экземпляр Dio
    late DioAdapter dioAdapter;                                          // Mock-адаптер сетевого уровня Dio
    late PostApi postApi;                                                // Экземпляр Retrofit API

    setUp(() {                                                           // Инициализация окружения перед каждым тестом
      dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com')); // Создаем чистый клиент с базовым URL
      dioAdapter = DioAdapter(dio: dio);                                 // Подключаем мок-адаптер к клиенту Dio
      postApi = PostApi(dio);                                            // Инициализируем Retrofit через замоканный Dio
    });                                                                  // Конец setUp

    test('Успешная отправка POST /posts с валидацией ответа через DioAdapter', () async { // Тест POST без реального интернета
      const route = '/posts';                                            // Эндпоинт отправки публикации
      final requestPayload = {                                           // Тело отправляемого POST-запроса
        'title': 'Архитектура Flutter',                                  // Заголовок
        'body': 'Подробное описание работы с Retrofit и BLoC',           // Содержимое
        'userId': 1,                                                     // Автор
      };                                                                 // Завершение словаря запроса

      final serverResponsePayload = {                                    // Имитируемый ответ сервера (HTTP 201 Created)
        'id': 101,                                                       // Присвоенный сервером идентификатор
        'title': 'Архитектура Flutter',                                  // Возвращенный заголовок
        'body': 'Подробное описание работы с Retrofit и BLoC',           // Возвращенное тело
        'userId': 1,                                                     // Возвращенный автор
      };                                                                 // Завершение ответа сервера

      dioAdapter.onPost(                                                 // Настраиваем перехват POST-запроса на /posts
        route,                                                           // URL эндпоинта
        (server) => server.reply(201, serverResponsePayload),            // Возвращаем HTTP 201 Created и JSON
        data: Matchers.any,                                              // Принимаем любые валидные данные
      );                                                                 // Завершение настройки адаптера

      final createdPost = await postApi.createPost(requestPayload);      // Вызываем метод создания поста в Retrofit API

      expect(createdPost.id, equals(101));                               // Проверяем, что ID равен 101 из ответа сервера
      expect(createdPost.title, equals('Архитектура Flutter'));          // Проверяем соответствие заголовка
      expect(createdPost.userId, equals(1));                             // Проверяем автора
      expect(createdPost.body, contains('Retrofit'));                    // Проверяем вхождение ключевого слова в текст
    });                                                                  // Конец теста отправки POST
  });                                                                    // Конец группы тестов
}                                                                        // Конец main
