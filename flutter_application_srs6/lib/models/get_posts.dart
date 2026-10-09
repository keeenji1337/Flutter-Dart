import 'package:json_annotation/json_annotation.dart'; // Аннотации для автоматической сериализации (JSON <-> Dart)

part 'get_posts.g.dart';                                 // Связь с сгенерированным файлом (.g.dart), в котором будет логика преобразования

@JsonSerializable()                                      // Маркер для генератора кода: "Сделай для этого класса методы fromJson/toJson"
class Posts {
  final int id;                                          // ID поста
  final String title;                                    // Заголовок поста
  final String body;                                     // Тело поста

  Posts({                                                // Обычный конструктор для ручного создания объекта в коде
    required this.id,
    required this.title,
    required this.body,
  });

  factory Posts.fromJson(Map<String, dynamic> json) =>   // Фабричный конструктор: принимает JSON-словарь, возвращает объект
      _$PostsFromJson(json);                             // Вызов сгенерированной функции, которая парсит Map в поля класса
  
  Map<String, dynamic> toJson() => _$PostsToJson(this);  // Метод экземпляра: берет поля текущего объекта (this) и собирает из них Map
}