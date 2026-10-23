import 'package:dio/dio.dart';                           // Библиотека Dio: HTTP-клиент и связанные типы ошибок

abstract class AppException implements Exception {        // Базовый абстрактный класс приложения для всех исключений
  final String message;                                  // Сообщение для отображения пользователю (понятный текст ошибки)
  final int? statusCode;                                 // Числовой HTTP-код ответа сервера (например, 404, 500)
  final dynamic originalError;                           // Исходная техническая ошибка для логирования разработчиком

  const AppException({                                   // Конструктор базового исключения с именованными параметрами
    required this.message,                               // Обязательный текст сообщения об ошибке
    this.statusCode,                                     // Необязательный статус-код HTTP
    this.originalError,                                  // Необязательный объект исходной ошибки
  });                                                    // Завершение конструктора AppException

  @override                                              // Переопределение метода строкового представления
  String toString() => message;                          // Возврат текста ошибки при вызове toString()

  factory AppException.fromDioException(DioException error) { // Фабричный конструктор: преобразует сетевые ошибки Dio в AppException
    switch (error.type) {                                // Анализ типа возникшей сетевой ошибки в клиенте Dio
      case DioExceptionType.connectionTimeout:           // Ошибка превышения времени установки связи с сервером
        return TimeoutException(                         // Создаем специализированную ошибку таймаута соединения
          message: 'Превышено время ожидания подключения к серверу.', // Человекочитаемое описание проблемы
          originalError: error,                          // Сохраняем исходное исключение Dio
        );                                               // Завершение ветки connectionTimeout

      case DioExceptionType.sendTimeout:                 // Ошибка превышения времени отправки запроса
        return TimeoutException(                         // Создаем ошибку таймаута отправки пакетов
          message: 'Превышено время отправки запроса на сервер.', // Человекочитаемое сообщение для пользователя
          originalError: error,                          // Сохраняем исходный объект ошибки
        );                                               // Завершение ветки sendTimeout

      case DioExceptionType.receiveTimeout:              // Ошибка ожидания ответа от удаленного сервера
        return TimeoutException(                         // Создаем ошибку таймаута получения данных
          message: 'Сервер слишком долго отвечает на запрос.', // Понятный текст для интерфейса
          originalError: error,                          // Исходная ошибка
        );                                               // Завершение ветки receiveTimeout

      case DioExceptionType.badResponse:                 // Сервер вернул ответ с кодом ошибки (4xx или 5xx)
        final code = error.response?.statusCode;         // Извлекаем целочисленный HTTP-статус из ответа сервера
        if (code != null && code >= 400 && code < 500) { // Проверка диапазона ошибок клиента (400-499)
          return ClientException(                        // Создаем клиентское исключение (неверный запрос/доступ)
            message: 'Ошибка клиента: $code. Проверьте запрос.', // Информативное сообщение для пользователя
            statusCode: code,                            // Передаем статус-код ответа
            originalError: error,                        // Сохраняем техническую информацию
          );                                             // Завершение ветки ClientException
        }                                                // Конец блока проверки клиентской ошибки
        return ServerException(                          // Создаем исключение ошибки на стороне сервера (500+)
          message: 'Внутренняя ошибка сервера: $code.',   // Сообщение о сбое серверной части
          statusCode: code,                              // HTTP-код 5xx
          originalError: error,                          // Технические детали Dio
        );                                               // Завершение ветки ServerException

      case DioExceptionType.cancel:                      // Запрос был явно отменен приложением
        return UnknownException(                         // Классифицируем как отмененное действие
          message: 'Запрос к серверу был отменен.',       // Пояснение для UI
          originalError: error,                          // Ссылка на отмененную операцию
        );                                               // Завершение ветки cancel

      case DioExceptionType.connectionError:             // Нет подключения к интернету или сервер недоступен
        return NetworkException(                         // Создаем специализированную сетевую ошибку
          message: 'Отсутствует интернет-соединение или сервер недоступен.', // Понятная подсказка включить сеть
          originalError: error,                          // Сохраняем контекст ошибки соединения
        );                                               // Завершение ветки connectionError

      case DioExceptionType.badCertificate:              // Ошибка валидации SSL/TLS сертификата сервера
        return NetworkException(                         // Относим к категории проблем сетевого доверия
          message: 'Ошибка проверки сертификата безопасности.', // Сообщение о ненадежном шифровании
          originalError: error,                          // Исходный объект сертификата
        );                                               // Завершение ветки badCertificate

      case DioExceptionType.unknown:                     // Неизвестная или внутренняя ошибка Dio/сокета
      default:                                           // Все остальные непредусмотренные типы ошибок
        if (error.error != null && error.error.toString().contains('SocketException')) { // Проверка отсутствия сокета
          return NetworkException(                       // Нет физического подключения к сокету сети
            message: 'Нет подключения к сети Интернет.', // Инструкция проверить Wi-Fi / мобильные данные
            originalError: error,                        // Исходное исключение сокета
          );                                             // Завершение возврата NetworkException
        }                                                // Конец проверки SocketException
        return UnknownException(                         // Возвращаем неопознанную ошибку общего вида
          message: 'Произошла непредвиденная ошибка сети.', // Текст по умолчанию для UI
          originalError: error,                          // Сохраняем стек-трейс и ошибку
        );                                               // Завершение дефолтной ветки
    }                                                    // Конец switch(error.type)
  }                                                      // Конец фабричного конструктора fromDioException
}                                                        // Конец абстрактного класса AppException

class NetworkException extends AppException {            // Ошибка отсутствия подключения к сети (офлайн)
  const NetworkException({                               // Конструктор ошибки сети
    required super.message,                              // Текст ошибки, передаваемый в родительский класс
    super.originalError,                                 // Исходный технический объект ошибки
  });                                                    // Завершение конструктора NetworkException
}                                                        // Конец класса NetworkException

class TimeoutException extends AppException {            // Ошибка истечения лимита времени на операцию
  const TimeoutException({                               // Конструктор ошибки таймаута
    required super.message,                              // Текст ошибки таймаута
    super.originalError,                                 // Исходная ошибка
  });                                                    // Завершение конструктора TimeoutException
}                                                        // Конец класса TimeoutException

class ClientException extends AppException {             // Ошибка HTTP 4xx (неверный путь, 404, неавторизован и т.д.)
  const ClientException({                                // Конструктор ошибки клиента
    required super.message,                              // Текст ошибки для пользователя
    super.statusCode,                                    // Числовой статус 4xx
    super.originalError,                                 // Исходный объект ответа Dio
  });                                                    // Завершение конструктора ClientException
}                                                        // Конец класса ClientException

class ServerException extends AppException {             // Ошибка HTTP 5xx (сбой на бэкенде 500, 502, 503)
  const ServerException({                                // Конструктор ошибки сервера
    required super.message,                              // Сообщение о неполадках сервера
    super.statusCode,                                    // Статус-код 5xx
    super.originalError,                                 // Ответ сервера с подробностями
  });                                                    // Завершение конструктора ServerException
}                                                        // Конец класса ServerException

class ParseException extends AppException {              // Ошибка десериализации или некорректного формата JSON
  const ParseException({                                 // Конструктор ошибки парсинга
    required super.message,                              // Текст ошибки структуры данных
    super.originalError,                                 // Ошибка парсера
  });                                                    // Завершение конструктора ParseException
}                                                        // Конец класса ParseException

class UnknownException extends AppException {            // Прочие непредвиденные системные сбои
  const UnknownException({                               // Конструктор неизвестной ошибки
    required super.message,                              // Текст общего сообщения
    super.originalError,                                 // Технические детали
  });                                                    // Завершение конструктора UnknownException
}                                                        // Конец класса UnknownException
