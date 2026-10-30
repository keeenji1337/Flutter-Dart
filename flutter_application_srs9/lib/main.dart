import 'package:flutter/material.dart';                  // Material Design: базовые UI-компоненты
import 'package:flutter_bloc/flutter_bloc.dart';            // Управление состоянием с помощью BLoC и провайдеров
import 'core/network/dio_client.dart';                      // Единый настроенный сетевой HTTP-клиент Dio
import 'data/local/post_cache.dart';                       // Локальный кэш постов на базе SharedPreferences
import 'data/remote/post_api.dart';                         // Retrofit REST API клиент для JSONPlaceholder
import 'data/repositories/post_repository.dart';           // Репозиторий: связывает удаленный API и локальный кэш
import 'presentation/bloc/post_list/post_list_bloc.dart';  // BLoC экрана списка публикаций
import 'presentation/bloc/post_list/post_list_event.dart'; // События BLoC списка публикаций
import 'presentation/screens/post_list_screen.dart';       // Стартовый экран каталога постов Post Explorer

void main() {                                            // Точка входа в Dart-приложение
  WidgetsFlutterBinding.ensureInitialized();              // Инициализация привязок движка Flutter перед асинхронными вызовами
  final dioClient = DioClient();                         // Создаем единственный экземпляр DioClient (Singleton)
  final postApi = PostApi(dioClient.dio);                // Создаем Retrofit-клиент, передавая в него настроенный Dio
  final postCache = PostCache();                         // Создаем экземпляр локального кэш-хранилища
  final postRepository = PostRepository(                 // Создаем слой репозитория для координации источников данных
    postApi: postApi,                                    // Внедряем удаленный источник данных Retrofit
    postCache: postCache,                                // Внедряем локальный источник данных кэша
  );                                                     // Завершение создания репозитория

  runApp(                                                // Запуск Flutter: создает корневой виджет и запускает движок
    MyApp(postRepository: postRepository),               // Передаем настроенный репозиторий в корневой виджет
  );                                                     // Завершение runApp
}                                                        // Конец функции main

class MyApp extends StatelessWidget {                    // Корневой виджет приложения (StatelessWidget)
  final PostRepository postRepository;                   // Экземпляр репозитория постов для всего приложения

  const MyApp({super.key, required this.postRepository}); // Конструктор с ключом и обязательным репозиторием

  @override                                              // Построение дерева виджетов приложения
  Widget build(BuildContext context) {                   // Метод build
    return RepositoryProvider<PostRepository>.value(     // Внедряем PostRepository во все дерево виджетов через DI
      value: postRepository,                             // Предоставляемый экземпляр репозитория
      child: BlocProvider<PostListBloc>(                 // Внедряем глобальный BLoC списка постов
        create: (context) => PostListBloc(               // Фабрика создания PostListBloc
          postRepository: postRepository,                // Передаем репозиторий в BLoC
        )..add(const PostListStarted()),                 // Сразу инициируем загрузку кэша и серверных данных
        child: MaterialApp(                              // Корневой виджет Material: настраивает тему и маршрутизацию
          title: 'Post Explorer',                        // Название приложения в диспетчере задач ОС
          debugShowCheckedModeBanner: false,             // Скрываем баннер режима отладки (DEBUG) в правом углу
          theme: ThemeData(                              // Настройка глобальной темы приложения
            useMaterial3: true,                          // Включаем современный дизайн Material 3
            colorScheme: ColorScheme.fromSeed(           // Генерация цветовой схемы от базового цвета
              seedColor: Colors.blue,                    // Основной синий оттенок для кнопок и акцентов
              brightness: Brightness.light,              // Светлая цветовая палитра
            ),                                           // Завершение ColorScheme
            appBarTheme: const AppBarTheme(              // Настройки темы верхних панелей AppBar
              centerTitle: false,                        // Выравнивание заголовка по левому краю
              backgroundColor: Colors.white,             // Белый фон панели
              foregroundColor: Colors.black87,           // Темно-серый цвет текста и иконок
            ),                                           // Завершение AppBarTheme
            cardTheme: CardThemeData(                    // Настройки оформления карточек постов
              color: Colors.white,                       // Белый фон карточек
              surfaceTintColor: Colors.transparent,      // Отключение автоматического затемнения карточек в Material 3
              shape: RoundedRectangleBorder(             // Скругление карточек по умолчанию
                borderRadius: BorderRadius.circular(14), // Радиус 14px
              ),                                         // Завершение формы
            ),                                           // Завершение CardThemeData
          ),                                             // Завершение ThemeData
          home: const PostListScreen(),                  // Стартовый экран (открывается при запуске приложения)
        ),                                               // Завершение MaterialApp
      ),                                                 // Завершение BlocProvider
    );                                                   // Завершение RepositoryProvider
  }                                                      // Конец build
}                                                        // Конец класса MyApp
