part of 'post_bloc.dart';                                // Указываем, что этот файл является частью post_bloc.dart

sealed class PostEvent extends Equatable {               // Базовый класс для всех событий, наследуется от Equatable
  const PostEvent();                                     // Константный конструктор базового класса

  @override                                              // Переопределяем метод props из Equatable
  List<Object> get props => [];                          // Возвращаем пустой список, так как нет свойств
}

final class GetPostEvent extends PostEvent {}            // Событие, которое инициирует загрузку списка постов
