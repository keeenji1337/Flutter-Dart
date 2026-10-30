import 'package:equatable/equatable.dart';               // Сравнение событий BLoC по значениям полей
import '../../../data/models/post.dart';                 // Модель поста для событий добавления

abstract class PostListEvent extends Equatable {         // Базовый абстрактный класс событий списка постов
  const PostListEvent();                                 // Константный конструктор базового события

  @override                                              // Свойства Equatable
  List<Object?> get props => [];                         // По умолчанию список свойств пуст
}                                                        // Конец базового события PostListEvent

class PostListStarted extends PostListEvent {            // Событие первичной инициализации экрана (проверка кэша и загрузка)
  const PostListStarted();                               // Константный конструктор события старта
}                                                        // Конец события PostListStarted

class PostListRefreshed extends PostListEvent {          // Событие ручного обновления списка (pull-to-refresh)
  const PostListRefreshed();                             // Константный конструктор события обновления
}                                                        // Конец события PostListRefreshed

class PostListNextPageRequested extends PostListEvent {  // Событие запроса следующей страницы при прокрутке вниз
  const PostListNextPageRequested();                     // Константный конструктор события пагинации
}                                                        // Конец события PostListNextPageRequested

class PostListAuthorFilterChanged extends PostListEvent {// Событие изменения фильтра по автору (userId)
  final int? userId;                                     // ID выбранного автора или null для всех авторов

  const PostListAuthorFilterChanged(this.userId);        // Конструктор с параметром userId

  @override                                              // Свойства для сравнения
  List<Object?> get props => [userId];                   // Равенство определяется по userId
}                                                        // Конец события PostListAuthorFilterChanged

class PostListSearchQueryChanged extends PostListEvent { // Событие изменения поисковой строки
  final String query;                                    // Текст поискового запроса

  const PostListSearchQueryChanged(this.query);          // Конструктор с текстом запроса

  @override                                              // Свойства для сравнения
  List<Object?> get props => [query];                    // Равенство по query
}                                                        // Конец события PostListSearchQueryChanged

class PostListSortToggleRequested extends PostListEvent {// Событие переключения порядка сортировки по ID
  const PostListSortToggleRequested();                   // Константный конструктор переключения сортировки
}                                                        // Конец события PostListSortToggleRequested

class PostListFiltersResetRequested extends PostListEvent { // Событие полного сброса всех фильтров и поиска
  const PostListFiltersResetRequested();                 // Константный конструктор сброса
}                                                        // Конец события PostListFiltersResetRequested

class PostListLocalPostAdded extends PostListEvent {     // Событие добавления созданного локально поста в список
  final Post post;                                       // Модель нового поста

  const PostListLocalPostAdded(this.post);               // Конструктор с новым постом

  @override                                              // Свойства для сравнения
  List<Object?> get props => [post];                     // Равенство по объекту поста
}                                                        // Конец события PostListLocalPostAdded
