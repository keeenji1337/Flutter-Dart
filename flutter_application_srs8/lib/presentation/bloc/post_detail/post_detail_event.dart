import 'package:equatable/equatable.dart';               // Сравнение объектов событий BLoC
import '../../../data/models/post.dart';                 // Модель поста

abstract class PostDetailEvent extends Equatable {       // Базовое событие экрана детальной информации о посте
  const PostDetailEvent();                               // Конструктор базового события

  @override                                              // Свойства Equatable
  List<Object?> get props => [];                         // Пустой список свойств по умолчанию
}                                                        // Конец базового события PostDetailEvent

class PostDetailRequested extends PostDetailEvent {      // Событие запроса подробностей о публикации
  final int postId;                                      // Идентификатор поста для загрузки данных
  final Post? initialPost;                               // Опционально: уже имеющийся объект поста для мгновенного отображения

  const PostDetailRequested(this.postId, {this.initialPost}); // Конструктор с ID поста

  @override                                              // Свойства для сравнения событий
  List<Object?> get props => [postId, initialPost];      // Равенство определяется по postId и initialPost
}                                                        // Конец события PostDetailRequested
