import 'package:dio/dio.dart';                           // Библиотека Dio: перехватчики запросов и ответов
import '../error/app_exception.dart';                    // Кастомная иерархия исключений приложения

class ApiInterceptor extends Interceptor {               // Пользовательский перехватчик: внедряет заголовки и ловит ошибки
  @override                                              // Переопределение метода обработки исходящего запроса
  void onRequest(                                        // Метод вызывается перед фактической отправкой HTTP-запроса
    RequestOptions options,                              // Конфигурация исходящего запроса (URL, метод, заголовки)
    RequestInterceptorHandler handler,                   // Обработчик цепочки перехватчиков (пропуск дальше)
  ) {                                                    // Начало тела метода onRequest
    options.headers['Accept'] = 'application/json';      // Указываем серверу, что ожидаем ответ в формате JSON
    options.headers['Content-Type'] = 'application/json; charset=UTF-8'; // Формат тела запроса и кодировка данных
    options.headers['X-Client-App'] = 'PostExplorer-Flutter'; // Пользовательский заголовок с названием нашего приложения
    options.headers['X-Client-Version'] = '1.0.0';       // Пользовательский заголовок с версией клиента
    options.headers['X-Request-Timestamp'] = DateTime.now().toIso8601String(); // Метка времени отправки запроса
    super.onRequest(options, handler);                   // Передаем управление следующему перехватчику в цепочке
  }                                                      // Конец метода onRequest

  @override                                              // Переопределение метода обработки успешного ответа
  void onResponse(                                       // Вызывается при успешном получении ответа от сервера
    Response response,                                   // Объект ответа сервера (данные, статус, заголовки)
    ResponseInterceptorHandler handler,                  // Обработчик цепочки перехватчиков
  ) {                                                    // Начало тела метода onResponse
    super.onResponse(response, handler);                 // Пропускаем успешный ответ дальше без изменений
  }                                                      // Конец метода onResponse

  @override                                              // Переопределение метода обработки ошибок запроса
  void onError(                                          // Вызывается при возникновении любой ошибки в Dio
    DioException err,                                    // Исходная ошибка библиотеки Dio
    ErrorInterceptorHandler handler,                     // Обработчик цепочки ошибок
  ) {                                                    // Начало тела метода onError
    final appException = AppException.fromDioException(err); // Преобразуем DioException в наше AppException
    final modifiedError = DioException(                  // Создаем обновленный объект ошибки с нашим AppException
      requestOptions: err.requestOptions,                // Сохраняем исходные параметры запроса
      response: err.response,                            // Сохраняем полученный ответ сервера (если был)
      type: err.type,                                    // Сохраняем исходный тип ошибки Dio
      error: appException,                               // Вкладываем наше человекопонятное AppException в поле error
      message: appException.message,                     // Присваиваем понятный текст ошибки полю message
    );                                                   // Завершение создания модифицированного DioException
    super.onError(modifiedError, handler);               // Передаем преобразованную ошибку дальше по цепочке
  }                                                      // Конец метода onError
}                                                        // Конец класса ApiInterceptor
