import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class RealtimeDatabaseService {
  static final RealtimeDatabaseService _instance =
      RealtimeDatabaseService._internal();
  factory RealtimeDatabaseService() => _instance;
  RealtimeDatabaseService._internal();

  DatabaseReference? _usersRef;
  bool _isInitialized = false;
  String? _initError;

  bool get isInitialized => _isInitialized;
  String? get initError => _initError;

  /// Инициализация ссылки на Realtime Database
  void initialize() {
    try {
      if (Firebase.apps.isNotEmpty) {
        // Получаем ссылку на узел 'users' в Realtime Database
        _usersRef = FirebaseDatabase.instance.ref('users');
        _isInitialized = true;
        _initError = null;
        developer.log('Firebase Realtime Database initialized at path: users');
      } else {
        _isInitialized = false;
        _initError = 'Firebase.apps пуст. Проверьте конфигурацию Firebase.';
      }
    } catch (e) {
      _isInitialized = false;
      _initError = e.toString();
      developer.log('RealtimeDatabaseService init error: $e');
    }
  }

  /// Сохранение пользователя в Firebase Realtime Database
  /// Возвращает сгенерированный уникальный ключ записи в Realtime Database
  Future<String> saveUser(UserModel user) async {
    if (_usersRef == null) {
      initialize();
    }

    if (_usersRef == null) {
      throw Exception(
        'Realtime Database не подключена. Убедитесь, что добавлен google-services.json и включена Realtime Database в консоли Firebase.',
      );
    }

    try {
      // Создаем новую уникальную запись с автогенерируемым ID (.push())
      final newRecordRef = _usersRef!.push();
      final recordId = newRecordRef.key;

      if (recordId == null) {
        throw Exception('Не удалось сгенерировать ID для записи');
      }

      // Сохраняем данные пользователя
      await newRecordRef.set(user.toMap());
      developer.log('User saved successfully with ID: $recordId');

      return recordId;
    } catch (e) {
      developer.log('Error saving user to Realtime Database: $e');
      rethrow;
    }
  }

  /// Получение потока (Stream) со списком всех пользователей в реальном времени
  Stream<List<UserModel>> getUsersStream() {
    if (_usersRef == null) {
      initialize();
    }

    if (_usersRef == null) {
      return Stream.value([]);
    }

    return _usersRef!.onValue.map((DatabaseEvent event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) {
        return <UserModel>[];
      }

      final List<UserModel> users = [];
      try {
        final data = snapshot.value;
        if (data is Map) {
          data.forEach((key, value) {
            if (value is Map) {
              users.add(UserModel.fromMap(key.toString(), value));
            }
          });
        }
        // Сортировка по дате создания (новые сначала)
        users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (e) {
        developer.log('Error parsing users snapshot: $e');
      }

      return users;
    });
  }

  /// Удаление пользователя (для тестирования)
  Future<void> deleteUser(String userId) async {
    if (_usersRef == null) return;
    await _usersRef!.child(userId).remove();
  }
}
