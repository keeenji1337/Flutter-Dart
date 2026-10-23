import 'package:dio/dio.dart';                           // Библиотека Dio: высокоуровневый HTTP-клиент
import 'api_interceptor.dart';                           // Наш пользовательский перехватчик заголовков и ошибок

class DioClient {                                        // Класс-клиент Dio: настраивает базовый URL, таймауты и интерцепторы
  static const String baseUrl = 'https://jsonplaceholder.typicode.com'; // Базовый адрес тестового REST API

  static const Duration connectTimeout = Duration(seconds: 10); // Лимит времени на установку соединения (10 секунд)
  static const Duration receiveTimeout = Duration(seconds: 10); // Лимит времени на чтение ответа от сервера (10 секунд)

  static final DioClient _instance = DioClient._internal(); // Единственный статический экземпляр (паттерн Одиночка / Singleton)

  late final Dio _dio;                                   // Закрытое поле с единственным экземпляром HTTP-клиента Dio

  factory DioClient() {                                  // Фабричный конструктор: всегда возвращает один и тот же экземпляр
    return _instance;                                    // Возврат синглтона
  }                                                      // Конец фабричного конструктора

  DioClient._internal() {                                // Приватный конструктор: инициализирует настройки Dio один раз
    _dio = Dio(                                          // Создаем и конфигурируем экземпляр Dio
      BaseOptions(                                       // Базовые параметры для всех запросов клиента
        baseUrl: baseUrl,                                // Указываем корневой URL сервера
        connectTimeout: connectTimeout,                  // Задаем лимит ожидания рукопожатия сети
        receiveTimeout: receiveTimeout,                  // Задаем лимит ожидания получения байтов
        responseType: ResponseType.json,                 // Автоматически парсить тело ответа как JSON
      ),                                                 // Завершение BaseOptions
    );                                                   // Завершение создания Dio

    _dio.interceptors.addAll([                           // Добавляем перехватчики в конвейер обработки запросов
      ApiInterceptor(),                                  // Наш кастомный интерцептор заголовков и маппинга ошибок
      LogInterceptor(                                    // Встроенный логгер Dio для отладки в консоли
        request: true,                                   // Логировать URL и метод запроса
        requestHeader: true,                             // Логировать заголовки исходящего запроса
        requestBody: true,                               // Логировать тело запроса (payload)
        responseHeader: false,                           // Не засорять консоль заголовками ответов
        responseBody: true,                              // Логировать полученные с сервера данные
        error: true,                                     // Логировать детали возникших сетевых ошибок
      ),                                                 // Завершение LogInterceptor
    ]);                                                  // Завершение списка перехватчиков
  }                                                      // Конец приватного конструктора

  Dio get dio => _dio;                                   // Геттер для безопасного доступа к настроенному объекту Dio
}                                                        // Конец класса DioClient
