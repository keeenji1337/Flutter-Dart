import 'package:equatable/equatable.dart';               // Пакет Equatable: сравнение событий и состояний по значению, а не по ссылке
import 'package:flutter_application_srs6/models/get_posts.dart'; // Импорт модели Posts
import 'package:flutter_application_srs6/post/repository/post_repository.dart'; // Импорт репозитория для работы с API
import 'package:flutter_bloc/flutter_bloc.dart';         // flutter_bloc: базовые классы для реализации паттерна BLoC

part 'post_event.dart';                                  // Подключение файла с определениями событий (часть этой же библиотеки)
part 'post_state.dart';                                  // Подключение файла с определениями состояний

class PostBloc extends Bloc<PostEvent, PostState> {      // BLoC: связывает входящие события (PostEvent) с исходящими состояниями (PostState)
  final _repository = PostRepository();                  // Экземпляр репозитория для выполнения сетевых запросов
  
  PostBloc() : super(PostInitial()) {                    // Конструктор: передает начальное состояние PostInitial в базовый класс
    on<GetPostEvent>(_repository.getPosts);              // Регистрация обработчика: при событии GetPostEvent вызывается метод getPosts
  }
}