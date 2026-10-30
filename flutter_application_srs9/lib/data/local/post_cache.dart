import 'dart:convert';                                    // Для кодирования и декодирования JSON-строк
import 'package:shared_preferences/shared_preferences.dart'; // Локальное хранилище ключ-значение в Flutter
import '../models/post.dart';                            // Модель поста для сохранения и восстановления из кэша

class PostCache {                                        // Класс локального кэширования постов на устройстве
  static const String _postsKey = 'cached_posts_v1';     // Ключ для хранения списка постов в SharedPreferences
  static const String _updatedAtKey = 'cached_posts_time'; // Ключ для хранения времени последнего обновления кэша

  Future<void> savePosts(List<Post> posts) async {       // Метод сохранения списка постов в локальный кэш
    final prefs = await SharedPreferences.getInstance(); // Получаем доступ к экземпляру SharedPreferences
    final jsonList = posts.map((post) => post.toJson()).toList(); // Преобразуем список моделей в список JSON Map
    final jsonString = jsonEncode(jsonList);             // Преобразуем список JSON Map в единую текстовую JSON-строку
    await prefs.setString(_postsKey, jsonString);        // Асинхронно записываем строку постов в хранилище
    await prefs.setString(                               // Сохраняем дату и время кэширования
      _updatedAtKey,                                     // Ключ времени обновления
      DateTime.now().toIso8601String(),                  // Текущее системное время в формате ISO 8601
    );                                                   // Завершение сохранения временной метки
  }                                                      // Конец метода savePosts

  Future<List<Post>> getCachedPosts() async {            // Метод извлечения ранее сохраненных постов из кэша
    final prefs = await SharedPreferences.getInstance(); // Открываем доступ к SharedPreferences
    final jsonString = prefs.getString(_postsKey);       // Читаем сохраненную JSON-строку по ключу
    if (jsonString == null || jsonString.isEmpty) {      // Проверяем, существует ли запись в кэше
      return [];                                         // Если кэш пуст, возвращаем пустой список
    }                                                    // Конец проверки на null
    try {                                                // Блок безопасного декодирования сохраненного кэша
      final decoded = jsonDecode(jsonString);            // Распарсиваем строку в динамический список объектов
      if (decoded is List) {                             // Убеждаемся, что декодированный объект является списком
        return decoded                                   // Проходим по каждому элементу списка
            .map((item) => Post.fromJson(item as Map<String, dynamic>)) // Преобразуем Map обратно в Post
            .toList();                                   // Собираем результат в типизированный List<Post>
      }                                                  // Конец проверки типа List
      return [];                                         // Возврат пустого списка при несоответствии типа
    } catch (_) {                                        // Обработка возможного повреждения данных в хранилище
      return [];                                         // Безопасный возврат пустого списка при сбое парсинга
    }                                                    // Конец блока catch
  }                                                      // Конец метода getCachedPosts

  Future<bool> hasCachedPosts() async {                  // Проверка наличия хотя бы одной записи в кэше
    final prefs = await SharedPreferences.getInstance(); // Доступ к SharedPreferences
    return prefs.containsKey(_postsKey);                 // Проверяем наличие ключа в локальной базе
  }                                                      // Конец метода hasCachedPosts

  Future<DateTime?> getLastUpdated() async {             // Получение времени последнего успешного обновления кэша
    final prefs = await SharedPreferences.getInstance(); // Доступ к SharedPreferences
    final timeStr = prefs.getString(_updatedAtKey);      // Читаем строковую метку времени
    if (timeStr == null) return null;                    // Если метки нет, возвращаем null
    return DateTime.tryParse(timeStr);                   // Парсим ISO-строку в объект DateTime
  }                                                      // Конец метода getLastUpdated

  Future<void> clearCache() async {                      // Метод очистки кэша постов (для сброса или выхода)
    final prefs = await SharedPreferences.getInstance(); // Доступ к SharedPreferences
    await prefs.remove(_postsKey);                       // Удаляем сохраненные посты
    await prefs.remove(_updatedAtKey);                   // Удаляем метку времени обновления
  }                                                      // Конец метода clearCache
}                                                        // Конец класса PostCache
