import 'package:dio/dio.dart';                                                   // Библиотека Dio для симуляции HTTP-ответов и генерации сетевых исключений
import 'package:flutter_application_srs9/core/error/app_exception.dart';           // Базовый класс AppException и специализированные типы сетевых исключений
import 'package:flutter_application_srs9/data/local/post_cache.dart';              // Сервис локального кэширования для создания мок-объекта
import 'package:flutter_application_srs9/data/models/comment.dart';                 // Доменная модель комментария к посту
import 'package:flutter_application_srs9/data/models/post.dart';                    // Доменная модель публикации (поста)
import 'package:flutter_application_srs9/data/models/user.dart';                    // Доменная модель автора публикации
import 'package:flutter_application_srs9/data/remote/post_api.dart';                // Контракт удаленного REST API на основе Retrofit
import 'package:flutter_application_srs9/data/repositories/post_repository.dart';   // Репозиторий публикаций, управляющий источниками данных
import 'package:flutter_test/flutter_test.dart';                                   // Фреймворк модульного и интеграционного тестирования Flutter
import 'package:mocktail/mocktail.dart';                                           // Библиотека Mocktail для создания типобезопасных моков

class MockPostApi extends Mock implements PostApi {}                               // Мок-класс для эмуляции удаленного Retrofit-клиента
class MockPostCache extends Mock implements PostCache {}                           // Мок-класс для эмуляции локального кэш-хранилища

void main() {                                                                      // Главная точка входа в набор модульных Unit-тестов
  setUpAll(() {                                                                    // Однократная глобальная инициализация перед запуском всех тестов
    registerFallbackValue(<Post>[]);                                               // Регистрация резервного значения List<Post> для мок-метода savePosts
  });                                                                              // Завершение глобальной настройки setUpAll

  group('Практическое задание №2: Unit-тестирование бизнес-логики Post Explorer', () { // Группа модульных тестов моделей и репозитория

    // -------------------------------------------------------------------------
    // ТЕСТ 1: Проверка корректной десериализации модели Post из валидного JSON
    // -------------------------------------------------------------------------
    test('Unit Test 1: Валидный парсинг Post.fromJson и сериализация в JSON', () {  // Проверка прямого и обратного преобразования данных
      final rawJson = {                                                            // Исходный словарь данных, симулирующий ответ REST API
        'userId': 42,                                                              // Идентификатор автора статьи
        'id': 105,                                                                 // Уникальный идентификатор публикации
        'title': 'Архитектура Flutter приложения',                                  // Заголовок публикации
        'body': 'Подробное описание модульного тестирования и BLoC',                // Содержимое тела публикации
      };                                                                           // Завершение тестового словаря rawJson

      final post = Post.fromJson(rawJson);                                         // Вызов фабричного конструктора десериализации JSON

      expect(post.id, equals(105));                                                // Проверка соответствия извлеченного числового ID публикации
      expect(post.userId, equals(42));                                             // Проверка соответствия ID автора публикации
      expect(post.title, equals('Архитектура Flutter приложения'));                // Проверка точного совпадения строки заголовка
      expect(post.body, contains('BLoC'));                                         // Проверка наличия ключевого слова во фрагменте тела
      expect(post.isLocal, isFalse);                                               // Проверка флага: серверный пост по умолчанию не является локальным

      final jsonMap = post.toJson();                                               // Вызов метода обратной сериализации модели в Map<String, dynamic>
      expect(jsonMap['id'], equals(105));                                          // Проверка корректного экспорта поля id в JSON
      expect(jsonMap['userId'], equals(42));                                       // Проверка корректного экспорта поля userId в JSON
      expect(jsonMap['title'], equals('Архитектура Flutter приложения'));          // Проверка экспорта поля title в выходной JSON-словарь
    });                                                                            // Завершение теста 1

    // -------------------------------------------------------------------------
    // ТЕСТ 2 (Доп.): Тестирование некорректных входных данных и fallback
    // -------------------------------------------------------------------------
    test('Unit Test 2: Обработка некорректных входных данных (Fault-tolerance)', () { // Проверка отказоустойчивости парсера при битых типах
      final corruptedJson = {                                                      // Поврежденный JSON с неверными типами полей
        'userId': 'not_an_int',                                                    // Строка вместо ожидаемого целочисленного userId
        'id': 'invalid_id_type',                                                   // Строка вместо числа в первичном ключе публикации
        'title': null,                                                             // Значение null в обязательном строковом поле заголовка
        'body': 99999,                                                             // Число вместо строкового содержимого публикации
        'isLocal': 'yes',                                                          // Строка вместо булевого значения флага локальности
      };                                                                           // Завершение словаря с поврежденными данными

      final safePost = Post.fromJson(corruptedJson);                               // Вызов защищенного фабричного конструктора Post.fromJson

      expect(safePost.id, isNull);                                                 // Некорректный ID должен безопасно сброситься в null без краша
      expect(safePost.userId, equals(1));                                          // Некорректный userId заменяется резервным значением 1 (fallback)
      expect(safePost.title, equals('Без заголовка'));                             // Поле title null заменяется понятным fallback-текстом
      expect(safePost.body, equals('99999'));                                      // Числовое тело безопасно преобразуется в строку через toString()
      expect(safePost.isLocal, isFalse);                                           // Небулевое значение флага безопасно интерпретируется как false
    });                                                                            // Завершение теста 2

    // -------------------------------------------------------------------------
    // ТЕСТ 3: Метод copyWith для обновления полей без нарушения immutability
    // -------------------------------------------------------------------------
    test('Unit Test 3: Метод copyWith корректно обновляет поля и сохраняет неизменяемость', () { // Проверка создания модифицированной копии
      const original = Post(                                                       // Исходный неизменяемый экземпляр публикации
        id: 1,                                                                     // Начальный ID
        userId: 1,                                                                 // Начальный автор
        title: 'Исходный заголовок',                                               // Исходное название
        body: 'Исходный текст',                                                    // Исходное тело публикации
        isLocal: false,                                                            // Серверный признак
      );                                                                           // Завершение создания оригинального объекта

      final modified = original.copyWith(                                          // Создание копии с выборочной модификацией параметров
        title: 'Обновленный заголовок',                                            // Новое значение заголовка
        isLocal: true,                                                             // Перевод флага в локальный пост
      );                                                                           // Завершение вызова copyWith

      expect(modified.id, equals(original.id));                                    // Поле id должно остаться неизменным (1)
      expect(modified.userId, equals(original.userId));                            // Поле userId должно сохраниться прежним (1)
      expect(modified.body, equals(original.body));                                // Тело публикации должно остаться старым
      expect(modified.title, equals('Обновленный заголовок'));                     // Заголовок успешно обновился на новое значение
      expect(modified.isLocal, isTrue);                                            // Флаг локальности успешно изменился на true
      expect(original.title, equals('Исходный заголовок'));                        // Исходный объект остался строго неизменным (immutability)
    });                                                                            // Завершение теста 3

    // -------------------------------------------------------------------------
    // ТЕСТ 4: Модель Comment, проверка десериализации и сравнения через Equatable
    // -------------------------------------------------------------------------
    test('Unit Test 4: Десериализация модели Comment и сравнение через Equatable', () { // Проверка парсинга комментариев и сравнения по значениям
      final commentJson = {                                                        // Тестовый JSON комментария от JSONPlaceholder
        'id': 10,                                                                  // Идентификатор комментария
        'postId': 1,                                                               // Идентификатор поста, к которому оставлен комментарий
        'name': 'Иван Иванов',                                                     // Заголовок или имя автора комментария
        'email': 'ivan@example.com',                                               // Email автора комментария
        'body': 'Отличная статья про тестирование Flutter!',                       // Текст комментария
      };                                                                           // Завершение словаря комментария

      final comment1 = Comment.fromJson(commentJson);                              // Создание первого экземпляра через десериализацию
      final comment2 = Comment.fromJson(commentJson);                              // Создание второго идентичного экземпляра

      expect(comment1.id, equals(10));                                             // Проверка корректности извлечения ID комментария
      expect(comment1.postId, equals(1));                                          // Проверка связи комментария с постом ID 1
      expect(comment1.email, equals('ivan@example.com'));                          // Проверка адреса электронной почты
      expect(comment1, equals(comment2));                                          // Проверка эквивалентности двух разных объектов по полям (Equatable)
      expect(comment1.props, equals([10, 1, 'Иван Иванов', 'ivan@example.com', 'Отличная статья про тестирование Flutter!'])); // Проверка списка полей props
    });                                                                            // Завершение теста 4

    // -------------------------------------------------------------------------
    // ТЕСТ 5: Модель User и отказоустойчивость при отсутствии вложенных данных
    // -------------------------------------------------------------------------
    test('Unit Test 5: Десериализация модели User и fallback вложенных объектов', () { // Проверка парсинга автора и безопасных значений
      final userJson = {                                                           // Словарь с данными автора без вложенных адреса и компании
        'id': 7,                                                                   // Идентификатор автора
        'name': 'Анна Смирнова',                                                   // Полное имя автора
        'username': 'asmirnova',                                                   // Никнейм
        'email': 'anna@example.com',                                               // Контактный email
      };                                                                           // Завершение словаря автора

      final user = User.fromJson(userJson);                                        // Десериализация пользователя через фабрику User.fromJson

      expect(user.id, equals(7));                                                  // Проверка ID автора
      expect(user.name, equals('Анна Смирнова'));                                  // Проверка имени
      expect(user.username, equals('asmirnova'));                                  // Проверка никнейма
      expect(user.email, equals('anna@example.com'));                              // Проверка email
      expect(user.address, isNull);                                                // Отсутствующий адрес безопасно равен null без исключения
      expect(user.company, isNull);                                                // Отсутствующая компания безопасно равна null
    });                                                                            // Завершение теста 5

    // -------------------------------------------------------------------------
    // ТЕСТ 6: Преобразование сетевых ошибок Dio в доменные исключения AppException
    // -------------------------------------------------------------------------
    test('Unit Test 6: Маппинг сетевых ошибок DioException в типизированные AppException', () { // Проверка фабрики AppException.fromDioException
      final timeoutDioError = DioException(                                        // Эмуляция ошибки таймаута соединения от Dio
        requestOptions: RequestOptions(path: '/posts'),                            // Контекст запроса с указанием эндпоинта
        type: DioExceptionType.connectionTimeout,                                  // Тип ошибки: превышение времени подключения
      );                                                                           // Завершение создания DioException

      final appTimeoutException = AppException.fromDioException(timeoutDioError);  // Вызов фабрики преобразования сетевой ошибки
      expect(appTimeoutException, isA<TimeoutException>());                         // Проверка соответствия классу TimeoutException
      expect(appTimeoutException.message, contains('подключения'));                // Проверка понятного русского сообщения для пользователя

      final notFoundDioError = DioException(                                       // Эмуляция HTTP-ошибки 404 Not Found
        requestOptions: RequestOptions(path: '/posts/9999'),                       // Контекст запроса несуществующего ресурса
        type: DioExceptionType.badResponse,                                        // Тип ошибки: ответ с кодом ошибки
        response: Response(                                                        // Симуляция HTTP-ответа сервера
          requestOptions: RequestOptions(path: '/posts/9999'),                     // Запрос ответа
          statusCode: 404,                                                         // Код статуса 404
        ),                                                                         // Завершение Response
      );                                                                           // Завершение создания 404 ошибки

      final appClientException = AppException.fromDioException(notFoundDioError);  // Преобразование 404 в доменное исключение
      expect(appClientException, isA<ClientException>());                          // Проверка классификации как ошибки клиента ClientException
      expect(appClientException.statusCode, equals(404));                          // Проверка сохранения статус-кода 404

      final serverErrorDio = DioException(                                         // Эмуляция внутренней ошибки сервера HTTP 500
        requestOptions: RequestOptions(path: '/posts'),                            // Контекст запроса
        type: DioExceptionType.badResponse,                                        // Тип ошибки: ответ сервера
        response: Response(                                                        // Симуляция 500-го ответа
          requestOptions: RequestOptions(path: '/posts'),                          // Запрос
          statusCode: 500,                                                         // Код статуса 500
        ),                                                                         // Завершение ответа
      );                                                                           // Завершение DioException 500

      final appServerException = AppException.fromDioException(serverErrorDio);    // Преобразование 500 в ServerException
      expect(appServerException, isA<ServerException>());                          // Проверка принадлежности к классу ServerException
      expect(appServerException.statusCode, equals(500));                          // Проверка сохраненного кода 500
    });                                                                            // Завершение теста 6

    // -------------------------------------------------------------------------
    // ТЕСТ 7: Логика взаимодействия репозитория PostRepository с удаленным API и кэшем
    // -------------------------------------------------------------------------
    test('Unit Test 7: PostRepository кэширует первую страницу и возвращает посты', () async { // Проверка бизнес-логики репозитория
      final mockApi = MockPostApi();                                               // Создание мока сетевого клиента
      final mockCache = MockPostCache();                                           // Создание мока локального кэша
      final repository = PostRepository(postApi: mockApi, postCache: mockCache);   // Экземпляр репозитория с внедренными зависимостями

      final testPosts = [                                                          // Тестовый список постов для возврата из API
        const Post(id: 1, userId: 1, title: 'Тестовый пост 1', body: 'Текст 1'),  // Первый пост
        const Post(id: 2, userId: 1, title: 'Тестовый пост 2', body: 'Текст 2'),  // Второй пост
      ];                                                                           // Завершение списка

      when(() => mockApi.getPosts(1, 10))                                          // Настройка поведения мока: при запросе 1 страницы по 10 элементов
          .thenAnswer((_) async => testPosts);                                     // Возвращать тестовый список
      when(() => mockCache.savePosts(testPosts))                                   // Настройка поведения мока: при сохранении в кэш
          .thenAnswer((_) async {});                                               // Успешное асинхронное завершение без возврата значения

      final result = await repository.getPostsFromServer(page: 1, limit: 10);      // Вызов тестируемого метода репозитория

      expect(result, equals(testPosts));                                           // Проверка: результат совпадает с данными от API
      expect(result.length, equals(2));                                            // Проверка: получено ровно 2 поста
      verify(() => mockApi.getPosts(1, 10)).called(1);                             // Проверка: удаленный метод getPosts был вызван ровно 1 раз
      verify(() => mockCache.savePosts(testPosts)).called(1);                      // Проверка: кэш первой страницы был сохранен ровно 1 раз
    });                                                                            // Завершение теста 7

    // -------------------------------------------------------------------------
    // ТЕСТ 8: Создание поста через PostRepository с установкой флага isLocal: true
    // -------------------------------------------------------------------------
    test('Unit Test 8: PostRepository.createPost отправляет POST и выставляет isLocal: true', () async { // Проверка создания нового поста
      final mockApi = MockPostApi();                                               // Экземпляр мока API
      final mockCache = MockPostCache();                                           // Экземпляр мока кэша
      final repository = PostRepository(postApi: mockApi, postCache: mockCache);   // Инициализация репозитория

      const createdServerPost = Post(                                              // Объект поста, возвращаемый сервером после успешного POST
        id: 101,                                                                   // Сервер назначает ID 101
        userId: 1,                                                                 // ID выбранного автора
        title: 'Новая публикация',                                                 // Заголовок созданного поста
        body: 'Содержимое новой публикации',                                       // Текст созданного поста
        isLocal: false,                                                            // Сервер возвращает флаг false
      );                                                                           // Завершение описания серверного ответа

      when(() => mockApi.createPost(any()))                                        // Настройка мока: при вызове createPost с любым payload
          .thenAnswer((_) async => createdServerPost);                             // Возвращать созданный серверный объект

      final result = await repository.createPost(                                  // Вызов бизнес-метода создания поста в репозитории
        title: 'Новая публикация',                                                 // Передача заголовка
        body: 'Содержимое новой публикации',                                       // Передача тела
        userId: 1,                                                                 // Передача ID автора
      );                                                                           // Завершение вызова createPost

      expect(result.id, equals(101));                                              // Проверка: назначен корректный ID 101
      expect(result.title, equals('Новая публикация'));                            // Проверка: заголовок сохранен
      expect(result.isLocal, isTrue);                                              // Проверка: репозиторий корректно пометил пост как локальный
      verify(() => mockApi.createPost({                                            // Проверка вызова API с точными параметрами JSON payload
            'title': 'Новая публикация',                                           // Поле title в теле запроса
            'body': 'Содержимое новой публикации',                                 // Поле body в теле запроса
            'userId': 1,                                                           // Поле userId в теле запроса
          })).called(1);                                                           // Вызов сетевого метода ровно один раз
    });                                                                            // Завершение теста 8

  });                                                                              // Завершение группы Unit-тестов
}                                                                                  // Конец функции main
