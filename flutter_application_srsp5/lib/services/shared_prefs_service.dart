// ==================== СЕРВИС СОХРАНЕНИЯ ДАННЫХ ====================
// Логика работы с локальным хранилищем (SharedPreferences).

import 'package:shared_preferences/shared_preferences.dart';    // Key-value хранилище (аналог localStorage / NSUserDefaults)

class SharedPrefsService {                                      // static-методы → экземпляр создавать не нужно

  // Сохраняет все поля пользователя за один вызов.
  static Future<void> saveUserData(                             // Future<void> — асинхронно (диск), результата не возвращает
    String name,
    String phone,
    String email,
    String lifeStory,
  ) async {
    final prefs = await SharedPreferences.getInstance();        // Синглтон: один объект хранилища на всё приложение
    await prefs.setString('name', name);                        // setString пишет пару ключ-значение на диск
    await prefs.setString('phone', phone);                      // await у setString — ждём завершения записи
    await prefs.setString('email', email);
    await prefs.setString('lifeStory', lifeStory);
  }

  // Читает все поля одним словарём.
  static Future<Map<String, String?>> getUserData() async {     // String? — null, если ключ ещё не сохранён
    final prefs = await SharedPreferences.getInstance();        // Тот же синглтон, что и при сохранении
    final name = prefs.getString('name');                       // await НЕ нужен: данные уже в кэше памяти
    final phone = prefs.getString('phone');
    final email = prefs.getString('email');
    final lifeStory = prefs.getString('lifeStory');

    return {                                                    // Словарь, чтобы наружу не «протекали» имена ключей
      'name': name,
      'phone': phone,
      'email': email,
      'lifeStory': lifeStory,
    };
  }

  // Полная очистка хранилища.
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();                                        // clear() стирает ВСЕ ключи приложения, не только наши 4
  }
}