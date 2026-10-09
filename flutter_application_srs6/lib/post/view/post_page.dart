import 'package:flutter/material.dart';                  // Material Design: базовые UI-компоненты
import 'package:flutter_bloc/flutter_bloc.dart';         // flutter_bloc: BlocBuilder для реактивного UI
import 'package:flutter_application_srs6/models/get_posts.dart'; // Модель Posts
import 'package:flutter_application_srs6/post/bloc/post_bloc.dart'; // PostBloc, события и состояния

class PostPage extends StatefulWidget {                  // StatefulWidget: экран управляет своим жизненным циклом
  const PostPage({super.key});                           // Конструктор с ключом (для идентификации в дереве)

  @override                                              // Создаем объект состояния
  State<PostPage> createState() => _PostPageState();     // Возвращаем класс состояния _PostPageState
}

class _PostPageState extends State<PostPage> {           // Состояние: здесь хранится логика и данные экрана
  List<Posts> posts = [];                                // Локальный кэш постов для отрисовки после загрузки
  late PostBloc postBloc;                                // late: инициализируем позже, в initState (не в конструкторе)

  @override                                              // Жизненный цикл: вызывается один раз при создании виджета
  void initState() {
    postBloc = PostBloc();                               // Создаем экземпляр PostBloc (зависит от контекста)
    postBloc.add(GetPostEvent());                        // Триггерим событие: BLoC начинает загрузку данных
    super.initState();                                   // Вызываем родительский initState (обязательно)
  }

  @override                                              // Перерисовка при изменении состояния (setState или BlocBuilder)
  Widget build(BuildContext context) {
    return Scaffold(                                     // Базовый каркас экрана
      appBar: AppBar(title: const Text('Posts')),        // Верхняя панель приложения
      body: BlocBuilder<PostBloc, PostState>(            // Слушаем поток состояний из BLoC и перестраиваем UI
        bloc: postBloc,                                  // Передаем экземпляр BLoC
        builder: (BuildContext context, state) {         // State-driven UI: интерфейс зависит от текущего состояния
          if (state is LoadingPostState) {               // Состояние загрузки
            return const Center(child: CircularProgressIndicator()); // Показываем спиннер по центру
          }
          if (state is FetchedPostsState) {              // Состояние успеха: данные получены
            posts = state.posts;                         // Сохраняем данные в локальный кэш
            return buildBody();                          // Строим список
          } else {                                       // Состояние ошибки (или Initial)
            return const Center(                         // Центрируем текст ошибки
              child: Text("Some Error"),                 // Заглушка для ошибки
            );
          }
        },
      ),
    );
  }

  Widget buildBody() {                                   // Вынесено отдельно, чтобы не засорять build()
    List<Widget> children = [];                          // Императивное построение списка виджетов
    for (var item in posts) {                            // Проходимся по всем постам
      children.add(                                      // Добавляем элемент в список
        Column(                                          // Каждый пост — вертикальная колонка
          crossAxisAlignment: CrossAxisAlignment.start,  // Выравнивание по левому краю
          children: [
            Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)), // Жирный заголовок
            Text(item.body),                             // Обычный текст тела
            const Divider(),                             // Разделительная линия
          ],
        ),
      );
    }
    return Center(                                       // Центрируем контент
      child: SingleChildScrollView(                      // Оборачиваем в скролл, так как Column не скроллится сама
        padding: const EdgeInsets.all(16.0),             // Отступы по краям
        child: Column(                                   // Вертикальная колонка для списка
          children: children,                            // Передаем сгенерированные виджеты
        ),
      ),
    );
  }
}