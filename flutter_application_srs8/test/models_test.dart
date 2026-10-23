import 'package:flutter_application_srs8/data/models/comment.dart'; // Модель комментария к посту
import 'package:flutter_application_srs8/data/models/post.dart';    // Модель публикации
import 'package:flutter_application_srs8/data/models/user.dart';    // Модель автора с вложенными объектами
import 'package:flutter_test/flutter_test.dart';                    // Фреймворк модульного тестирования Flutter

void main() {                                                       // Точка входа в блок тестов моделей
  group('Тестирование моделей и JSON-сериализации (Задание 7, Тесты 1 и 2)', () { // Группа тестов сериализации

    test('Тест 1: Успешное преобразование JSON в Post (десериализация)', () { // Тест 1 по ТЗ
      final jsonMap = {                                             // Имитируем ответ сервера JSONPlaceholder
        'userId': 1,                                                // Идентификатор автора
        'id': 101,                                                  // Идентификатор поста
        'title': 'Тестовый заголовок публикации',                   // Заголовок поста
        'body': 'Тестовое подробное содержимое публикации',         // Текст поста
      };                                                            // Завершение тестового словаря

      final post = Post.fromJson(jsonMap);                          // Выполняем десериализацию через json_serializable

      expect(post.id, equals(101));                                 // Проверяем корректность распознавания поля id
      expect(post.userId, equals(1));                               // Проверяем корректность распознавания поля userId
      expect(post.title, equals('Тестовый заголовок публикации'));  // Проверяем заголовок
      expect(post.body, equals('Тестовое подробное содержимое публикации')); // Проверяем тело публикации
      expect(post.isLocal, isFalse);                                // По умолчанию пост с сервера не является локальным
    });                                                             // Конец Теста 1

    test('Тест 1 (дополнительно): Устойчивость к поврежденному JSON без аварийного завершения', () { // Дополнительный тест надежности парсинга
      final corruptedJson = {                                       // Словарь с некорректными типами данных
        'userId': 'not_an_int',                                     // Строка вместо ожидаемого int
        'title': null,                                              // null вместо заголовка
        'body': 12345,                                              // Число вместо строки
      };                                                            // Завершение поврежденного словаря

      final post = Post.fromJson(corruptedJson);                    // Парсер не должен упасть благодаря защищенному блоку try/catch

      expect(post.title, equals('Без заголовка'));                  // Сработал безопасный fallback для заголовка
      expect(post.body, equals('12345'));                           // Число безопасно приведено к строке
      expect(post.userId, equals(1));                               // Сработал безопасный fallback автора по умолчанию
    });                                                             // Конец дополнительного теста устойчивости

    test('Тест 2: Преобразование Post обратно в JSON (сериализация)', () { // Тест 2 по ТЗ
      const originalPost = Post(                                    // Создаем исходный объект модели Post
        id: 42,                                                     // Идентификатор
        userId: 7,                                                  // Автор
        title: 'Заголовок для сериализации',                        // Заголовок
        body: 'Текст для отправки на сервер',                       // Текст
        isLocal: false,                                             // Серверный флаг
      );                                                            // Завершение создания модели

      final jsonResult = originalPost.toJson();                     // Преобразуем объект модели в Map<String, dynamic>

      expect(jsonResult['id'], equals(42));                         // Проверяем наличие ключа id в результирующем JSON
      expect(jsonResult['userId'], equals(7));                      // Проверяем ключ userId
      expect(jsonResult['title'], equals('Заголовок для сериализации')); // Проверяем ключ title
      expect(jsonResult['body'], equals('Текст для отправки на сервер')); // Проверяем ключ body
    });                                                             // Конец Теста 2

    test('Тест вложенных моделей: Сериализация и десериализация User с Company и Address', () { // Проверка вложенных объектов
      final userJson = {                                            // Имитация JSON автора с вложенными структурами
        'id': 1,                                                    // ID пользователя
        'name': 'Иван Иванов',                                      // Полное имя
        'username': 'ivanov',                                       // Никнейм
        'email': 'ivan@example.com',                                // Почта
        'company': {                                                // Вложенный объект компании
          'name': 'Яндекс',                                         // Название компании
          'catchPhrase': 'Найдётся всё',                            // Слоган
          'bs': 'IT решения',                                       // Направление
        },                                                          // Завершение company
        'address': {                                                // Вложенный объект адреса
          'street': 'Тверская',                                     // Улица
          'suite': 'Офис 10',                                       // Номер офиса
          'city': 'Москва',                                         // Город
          'zipcode': '101000',                                      // Индекс
        },                                                          // Завершение address
      };                                                            // Завершение userJson

      final user = User.fromJson(userJson);                         // Парсим объект со сложной вложенностью

      expect(user.id, equals(1));                                   // Проверка ID
      expect(user.company, isNotNull);                              // Вложенная компания успешно распознана
      expect(user.company!.name, equals('Яндекс'));                 // Проверка названия компании
      expect(user.address, isNotNull);                              // Вложенный адрес успешно распознан
      expect(user.address!.city, equals('Москва'));                 // Проверка города в адресе

      final serializedUser = user.toJson();                         // Сериализуем обратно
      expect(serializedUser['company']['name'], equals('Яндекс'));  // Вложенная компания корректно сохранена в JSON
    });                                                             // Конец теста вложенных моделей

    test('Тест модели Comment: Сериализация и десериализация', () { // Проверка модели комментария
      final commentJson = {                                         // Имитируем JSON комментария
        'id': 5,                                                    // ID комментария
        'postId': 1,                                                // ID поста
        'name': 'Отличный пост',                                    // Тема комментария
        'email': 'reader@example.com',                              // Почта комментатора
        'body': 'Очень полезная информация, спасибо!',              // Текст комментария
      };                                                            // Завершение commentJson

      final comment = Comment.fromJson(commentJson);                // Парсинг комментария
      expect(comment.id, equals(5));                                // Проверка ID
      expect(comment.postId, equals(1));                            // Проверка postId
      expect(comment.name, equals('Отличный пост'));                // Проверка темы

      final serialized = comment.toJson();                          // Сериализация обратно
      expect(serialized['email'], equals('reader@example.com'));    // Проверка сохраненной почты
    });                                                             // Конец теста комментария
  });                                                               // Конец группы тестов моделей
}                                                                   // Конец main
