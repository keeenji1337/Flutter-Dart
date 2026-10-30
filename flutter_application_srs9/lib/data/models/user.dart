import 'package:equatable/equatable.dart';               // Библиотека Equatable: сравнение объектов по значениям полей
import 'package:json_annotation/json_annotation.dart';     // Аннотации генератора json_serializable

part 'user.g.dart';                                      // Файл, генерируемый build_runner для сериализации User

@JsonSerializable(explicitToJson: true)                  // Аннотация: генерация сериализатора с явным вызовом toJson для вложенных моделей
class User extends Equatable {                           // Модель автора поста, наследуется от Equatable для легкого сравнения
  final int id;                                          // Уникальный идентификатор пользователя
  final String name;                                     // Полное имя пользователя
  final String username;                                 // Никнейм / логин пользователя
  final String email;                                    // Адрес электронной почты
  final String? phone;                                   // Необязательный номер телефона
  final String? website;                                 // Необязательный веб-сайт
  final Company? company;                                // Вложенный объект: информация о компании
  final Address? address;                                // Вложенный объект: почтовый адрес

  const User({                                           // Конструктор модели User с именованными аргументами
    required this.id,                                    // Обязательное поле id
    required this.name,                                  // Обязательное поле name
    required this.username,                              // Обязательное поле username
    required this.email,                                 // Обязательное поле email
    this.phone,                                          // Необязательный телефон
    this.website,                                        // Необязательный сайт
    this.company,                                        // Необязательный объект компании
    this.address,                                        // Необязательный объект адреса
  });                                                    // Завершение конструктора User

  factory User.fromJson(Map<String, dynamic> json) {     // Фабричный метод безопасного создания User из Map/JSON
    try {                                                // Блок безопасного парсинга для предотвращения аварийного падения
      return _$UserFromJson(json);                      // Вызов автоматически сгенерированного парсера
    } catch (_) {                                        // Обработка возможной некорректной структуры JSON
      return User(                                       // Возврат объекта-заглушки при поврежденном JSON
        id: json['id'] is int ? json['id'] as int : 0,   // Безопасное чтение ID или 0
        name: json['name']?.toString() ?? 'Неизвестный', // Безопасное имя
        username: json['username']?.toString() ?? 'unknown', // Безопасный ник
        email: json['email']?.toString() ?? '',          // Безопасный email
      );                                                 // Завершение создания fallback User
    }                                                    // Конец catch
  }                                                      // Конец User.fromJson

  Map<String, dynamic> toJson() => _$UserToJson(this);   // Преобразование объекта User в Map для отправки или сохранения

  @override                                              // Переопределение списка свойств для сравнения объектов Equatable
  List<Object?> get props => [                           // Список полей, по которым определяется равенство двух пользователей
        id,                                              // Сравниваем по ID
        name,                                            // Сравниваем по имени
        username,                                        // Сравниваем по никнейму
        email,                                           // Сравниваем по почте
        phone,                                           // Сравниваем по телефону
        website,                                         // Сравниваем по сайту
        company,                                         // Сравниваем по компании
        address,                                         // Сравниваем по адресу
      ];                                                 // Завершение списка props
}                                                        // Конец класса User

@JsonSerializable()                                      // Аннотация кодогенерации для вложенной модели компании
class Company extends Equatable {                        // Вложенный класс сведений о компании
  final String? name;                                    // Название компании
  final String? catchPhrase;                             // Слоган компании
  final String? bs;                                      // Сфера деятельности

  const Company({                                        // Конструктор вложенной модели Company
    this.name,                                           // Имя компании
    this.catchPhrase,                                    // Слоган
    this.bs,                                             // Бизнес-сфера
  });                                                    // Завершение конструктора Company

  factory Company.fromJson(Map<String, dynamic> json) => // Парсинг компании из JSON с помощью кодогенерации
      _$CompanyFromJson(json);                           // Вызов сгенерированного метода

  Map<String, dynamic> toJson() => _$CompanyToJson(this); // Преобразование компании в JSON-словарь

  @override                                              // Свойства для проверки равенства компаний
  List<Object?> get props => [name, catchPhrase, bs];    // Равенство по названию, слогану и сфере
}                                                        // Конец класса Company

@JsonSerializable()                                      // Аннотация кодогенерации для вложенной модели адреса
class Address extends Equatable {                        // Вложенный класс сведений об адресе проживания
  final String? street;                                  // Улица
  final String? suite;                                   // Квартира / офис
  final String? city;                                    // Город
  final String? zipcode;                                 // Почтовый индекс

  const Address({                                        // Конструктор адреса
    this.street,                                         // Улица
    this.suite,                                          // Офис/номер
    this.city,                                           // Город
    this.zipcode,                                        // Индекс
  });                                                    // Завершение конструктора Address

  factory Address.fromJson(Map<String, dynamic> json) => // Парсинг адреса из JSON
      _$AddressFromJson(json);                           // Сгенерированный десериализатор

  Map<String, dynamic> toJson() => _$AddressToJson(this); // Сериализация адреса в Map

  @override                                              // Свойства для равенства адресов
  List<Object?> get props => [street, suite, city, zipcode]; // Сравнение по полям улицы, офиса, города и индекса
}                                                        // Конец класса Address
