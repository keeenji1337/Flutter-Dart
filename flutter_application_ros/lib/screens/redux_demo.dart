import 'package:flutter/material.dart';                                    // Material Design: базовые UI-компоненты
import 'package:redux/redux.dart';                                         // Redux: Store, Reducer, Actions
import 'package:flutter_redux/flutter_redux.dart';                         // flutter_redux: StoreProvider, StoreConnector

// --- 1. State (Состояние) ---

class ReduxAppState {                                                      // Описывает состояние приложения для Redux
  final int counter;                                                       // Поле состояния: счётчик

  ReduxAppState({required this.counter});                                  // Конструктор с обязательным полем

  factory ReduxAppState.initial() => ReduxAppState(counter: 0);            // Начальное состояние
}

// --- 2. Actions (Действия) ---

class IncrementAction {}                                                   // Действие "Увеличить"
class DecrementAction {}                                                   // Действие "Уменьшить"

// --- 3. Reducer (Редьюсер) ---

ReduxAppState appReducer(ReduxAppState state, dynamic action) {            // Чистая функция: (state, action) → новое state
  if (action is IncrementAction) {                                         // Проверяем тип пришедшего действия
    return ReduxAppState(counter: state.counter + 1);                      // Новое состояние: счётчик + 1
  } else if (action is DecrementAction) {                                  // Другое действие
    return ReduxAppState(counter: state.counter - 1);                      // Новое состояние: счётчик − 1
  }
  return state;                                                            // Действие не распознано — состояние без изменений
}

// --- 4. Экран для демонстрации Redux ---

class ReduxDemoScreen extends StatelessWidget {                            // Экран-демо Redux
  final Store<ReduxAppState> store = Store<ReduxAppState>(                 // Store: хранилище Redux (в проде создаётся один раз в main.dart)
    appReducer,                                                            //    Передаём редьюсер
    initialState: ReduxAppState.initial(),                                 //    Передаём начальное состояние
  );

  ReduxDemoScreen({super.key});                                            // Конструктор с ключом

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {
    return StoreProvider<ReduxAppState>(                                   // 5. StoreProvider: делает store доступным для дочерних виджетов
      store: store,                                                        //    Передаём хранилище
      child: Scaffold(                                                     //    Каркас Material-экрана
        appBar: AppBar(title: const Text('Redux Demo')),                   //    Верхняя панель с заголовком
        body: Center(                                                      //    Центрируем содержимое
          child: Column(                                                   //    Вертикальный столбец
            mainAxisAlignment: MainAxisAlignment.center,                   //    Выравнивание по центру главной оси
            children: [
              const Text('Счетчик (Redux):'),                              //    Подпись
              StoreConnector<ReduxAppState, String>(                       // 6. StoreConnector: подключает виджет к Store
                converter: (store) => store.state.counter.toString(),      //    converter: берём из state только нужное (String)
                builder: (context, counterString) {                        //    builder: строим UI из полученных данных
                  return Text(                                             //    Отображаем счётчик
                    counterString,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  );
                },
              ),
              const SizedBox(height: 20),                                  //    Распорка-отступ
              Row(                                                         //    Горизонтальный ряд кнопок
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,          //    Равные промежутки между кнопками
                children: [
                  StoreConnector<ReduxAppState, VoidCallback>(             //    Кнопка уменьшения (-)
                    converter: (store) {                                   //    converter: возвращаем функцию-dispatch
                      return () => store.dispatch(DecrementAction());      //    Функция диспатчит DecrementAction
                    },
                    builder: (context, callback) {                         //    builder: строим кнопку
                      return ElevatedButton(                               //    Кнопка
                        onPressed: callback,                               //    Вызываем dispatch при нажатии
                        child: const Text('Минус (-)'),                    //    Текст кнопки
                      );
                    },
                  ),
                  StoreConnector<ReduxAppState, VoidCallback>(             //    Кнопка увеличения (+)
                    converter: (store) {                                   //    converter: возвращаем функцию-dispatch
                      return () => store.dispatch(IncrementAction());      //    Функция диспатчит IncrementAction
                    },
                    builder: (context, callback) {                         //    builder: строим кнопку
                      return ElevatedButton(                               //    Кнопка
                        onPressed: callback,                               //    Вызываем dispatch при нажатии
                        child: const Text('Плюс (+)'),                     //    Текст кнопки
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}