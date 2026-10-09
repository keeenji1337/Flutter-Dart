import 'dart:convert';                                   // Библиотека для кодирования и декодирования JSON

import 'package:flutter_application_srs6/models/get_posts.dart'; // Модель Posts
import 'package:flutter_application_srs6/post/bloc/post_bloc.dart'; // BLoC для доступа к событиям и состояниям
import 'package:flutter_bloc/flutter_bloc.dart';         // Для использования класса Emitter
import 'package:http/http.dart' as http;                 // Библиотека http для сетевых запросов

class PostRepository {                                   // Репозиторий для получения данных из API
  final _baseUrl = "https://jsonplaceholder.typicode.com/posts"; // URL для получения постов из API

  Future<void> getPosts(GetPostEvent event, Emitter<PostState> emit) async { // Метод загрузки постов
    emit(LoadingPostState());                            // Отправляем состояние загрузки для показа индикатора
    
    try {                                                // Блок try-catch для перехвата ошибок
      final response = await http.get(Uri.parse(_baseUrl)); // Выполняем GET-запрос и ждем результат
      final List<dynamic> jsonList = jsonDecode(response.body); // Декодируем строку JSON в список
      final getPosts = jsonList.map((json) => Posts.fromJson(json)).toList(); // Преобразуем JSON в список объектов
      
      emit(FetchedPostsState(getPosts));                 // Отправляем успешное состояние со списком
    } catch (e) {                                        // Если произошла ошибка
      emit(FailurePostState());                          // Отправляем состояние ошибки
    }
  }
}
