import 'package:dio/dio.dart';                           // Библиотека Dio: передается в качестве сетевого движка Retrofit
import 'package:retrofit/retrofit.dart';                 // Библиотека Retrofit для декларативного описания REST API
import '../models/comment.dart';                         // Модель комментария
import '../models/post.dart';                            // Модель поста
import '../models/user.dart';                            // Модель пользователя / автора

part 'post_api.g.dart';                                  // Файл реализации Retrofit, генерируемый build_runner

@RestApi(baseUrl: "https://jsonplaceholder.typicode.com") // Аннотация Retrofit с базовым адресом REST-сервиса
abstract class PostApi {                                 // Абстрактный интерфейс удаленного источника данных (Retrofit API)
  factory PostApi(Dio dio, {String baseUrl}) = _PostApi; // Фабрика: создает сгенерированную реализацию _PostApi

  @GET("/posts")                                         // Запрос №1: получение списка постов с пагинацией по страницам
  Future<List<Post>> getPosts(                           // Метод получения страницы постов
    @Query("_page") int page,                            // Номер запрашиваемой страницы
    @Query("_limit") int limit,                          // Количество постов на одну страницу
  );                                                     // Конец объявления метода getPosts

  @GET("/posts/{id}")                                    // Запрос №2: получение детальной информации о конкретном посте по ID
  Future<Post> getPostById(                              // Метод получения одного поста
    @Path("id") int id,                                  // Идентификатор поста в пути URL
  );                                                     // Конец объявления метода getPostById

  @GET("/posts")                                         // Запрос №3: фильтрация постов по идентификатору автора userId
  Future<List<Post>> getPostsByUserId(                   // Метод получения постов конкретного пользователя
    @Query("userId") int userId,                         // Идентификатор автора в query-параметрах
    @Query("_page") int? page,                           // Необязательный номер страницы при фильтрации
    @Query("_limit") int? limit,                         // Необязательный лимит постов при фильтрации
  );                                                     // Конец объявления метода getPostsByUserId

  @GET("/posts/{id}/comments")                           // Запрос №4: получение всех комментариев к указанному посту
  Future<List<Comment>> getCommentsByPostId(             // Метод получения комментариев поста
    @Path("id") int id,                                  // Идентификатор поста в URL пути
  );                                                     // Конец объявления метода getCommentsByPostId

  @POST("/posts")                                        // Запрос №5: создание нового поста на сервере
  Future<Post> createPost(                               // Метод отправки POST-запроса создания поста
    @Body() Map<String, dynamic> body,                   // Тело запроса с полями title, body и userId
  );                                                     // Конец объявления метода createPost

  @GET("/users")                                         // Дополнительный запрос: получение списка всех авторов
  Future<List<User>> getUsers();                         // Метод получения списка пользователей

  @GET("/users/{id}")                                    // Дополнительный запрос: получение подробной информации об авторе
  Future<User> getUserById(                              // Метод получения пользователя по его ID
    @Path("id") int id,                                  // Идентификатор пользователя
  );                                                     // Конец объявления метода getUserById
}                                                        // Конец интерфейса PostApi
