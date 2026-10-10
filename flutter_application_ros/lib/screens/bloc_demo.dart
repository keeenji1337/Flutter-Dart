import 'package:flutter/material.dart';                                    // Material Design: базовые UI-компоненты
import 'package:flutter_bloc/flutter_bloc.dart';                           // flutter_bloc: интеграция BLoC с UI
import '../bloc/app_bloc.dart';                                            // Импорт нашего BLoC
import '../bloc/app_state.dart';                                           // Импорт классов состояний
import '../bloc/app_event.dart';                                           // Импорт классов событий

class BlocDemoScreen extends StatelessWidget {                             // StatelessWidget: всем состоянием управляет BLoC
  final List<String> availableItems = const [                              // Список доступных товаров для покупки
    'Яблоко', 'Банан', 'Апельсин', 'Молоко', 'Хлеб'                        //    Товары
  ];

  const BlocDemoScreen({super.key});                                       // Конструктор с ключом

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {
    return Scaffold(                                                       // Каркас Material-экрана
      appBar: AppBar(                                                      // Верхняя панель приложения
        title: const Text('BLoC Demo (Магазин)'),                          //    Заголовок экрана
        actions: [
          BlocBuilder<AppBloc, AppState>(                                  //    BlocBuilder: слушает изменения AppBloc
            builder: (context, state) {                                    //    Билдер вызывается при каждом новом состоянии
              return Padding(                                              //    Отступ вокруг счётчика корзины
                padding: const EdgeInsets.only(right: 16.0),               //    Отступ справа
                child: Center(                                             //    Центрируем текст
                  child: Text(                                             //    Текст-счётчик товаров
                    'В корзине: ${state.cartItems.length}',                //    Количество товаров в корзине
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Жирный, 18
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Row(                                                           // Тело экрана: две колонки — товары и корзина
        children: [
          Expanded(                                                        // Левая часть: список товаров (1 часть)
            flex: 1,                                                       //    Пропорция 1
            child: Column(                                                 //    Вертикальный столбец
              children: [
                const Padding(                                             //    Отступ вокруг заголовка
                  padding: EdgeInsets.all(8.0),                            //    Внутренние отступы
                  child: Text('Товары', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // Заголовок "Товары"
                ),
                Expanded(                                                  //    Растягиваем список на всё оставшееся место
                  child: ListView.builder(                                 //    ListView.builder: рендерит только видимые элементы
                    itemCount: availableItems.length,                      //    Количество товаров
                    itemBuilder: (context, index) {                        //    Билдер элемента списка
                      final item = availableItems[index];                  //    Текущий товар
                      return ListTile(                                     //    Плитка товара
                        title: Text(item),                                 //    Название товара
                        trailing: IconButton(                              //    Кнопка "добавить в корзину"
                          icon: const Icon(Icons.add_shopping_cart, color: Colors.green), // Иконка
                          onPressed: () {                                  //    Обработчик клика
                            context.read<AppBloc>().add(AddToCartEvent(item)); // Отправляем событие в BLoC
                            ScaffoldMessenger.of(context).showSnackBar(    //    Показываем SnackBar
                              SnackBar(content: Text('$item добавлен в корзину'), duration: const Duration(milliseconds: 500)), // Текст уведомления
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1, color: Colors.grey),           // Вертикальный разделитель между колонками
          Expanded(                                                        // Правая часть: содержимое корзины (1 часть)
            flex: 1,                                                       //    Пропорция 1
            child: Column(                                                 //    Вертикальный столбец
              children: [
                const Padding(                                             //    Отступ вокруг заголовка
                  padding: EdgeInsets.all(8.0),                            //    Внутренние отступы
                  child: Text('Корзина', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // Заголовок "Корзина"
                ),
                Expanded(                                                  //    Растягиваем список на всё оставшееся место
                  child: BlocBuilder<AppBloc, AppState>(                   //    BlocBuilder: перерисовка при изменении состояния
                    builder: (context, state) {                            //    Билдер состояния корзины
                      if (state.cartItems.isEmpty) {                       //    Если корзина пуста
                        return const Center(child: Text('Корзина пуста')); // Показываем заглушку
                      }
                      return ListView.builder(                             //    Список товаров в корзине
                        itemCount: state.cartItems.length,                 //    Количество товаров
                        itemBuilder: (context, index) {                    //    Билдер элемента
                          final item = state.cartItems[index];             //    Текущий товар
                          return ListTile(                                 //    Плитка товара
                            title: Text(item),                             //    Название товара
                            trailing: IconButton(                          //    Кнопка "удалить из корзины"
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red), // Иконка
                              onPressed: () {                              //    Обработчик клика
                                context.read<AppBloc>().add(RemoveFromCartEvent(item)); // Отправляем событие удаления
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}