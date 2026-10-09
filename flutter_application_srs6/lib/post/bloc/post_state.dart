part of 'post_bloc.dart';                                // Указываем, что этот файл является частью post_bloc.dart

sealed class PostState extends Equatable {               // Базовый класс состояний, наследуется от Equatable
  const PostState();                                     // Константный конструктор

  @override                                              // Переопределяем метод props
  List<Object> get props => [];                          // Возвращаем пустой список по умолчанию
}

final class PostInitial extends PostState {}             // Начальное состояние BLoC до начала загрузки

final class LoadingPostState extends PostState {}        // Состояние, указывающее на процесс загрузки данных

final class FetchedPostsState extends PostState {        // Состояние успешной загрузки данных с API
  final List<Posts> posts;                               // Список загруженных постов для передачи в UI
  
  const FetchedPostsState(this.posts);                   // Конструктор, принимающий список постов

  @override                                              // Переопределяем props
  List<Object> get props => [posts];                     // Сравниваем состояния по списку постов
}

final class FailurePostState extends PostState {}        // Состояние ошибки при неудачной загрузке
