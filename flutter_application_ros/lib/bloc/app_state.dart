class AppState {                                                           // Состояние приложения (корзина)
  final List<String> cartItems;                                            // Список названий товаров в корзине (final — ссылку не переназначить)

  AppState({required this.cartItems});                                     // Конструктор: cartItems — именованный и обязательный параметр

  factory AppState.initial() {                                             // Фабричный метод: создаёт начальное состояние
    return AppState(cartItems: []);                                        //    Начальное состояние: пустая корзина
  }

  AppState copyWith({List<String>? cartItems}) {                           // copyWith: создаёт НОВЫЙ объект на основе текущего (иммутабельность)
    return AppState(                                                       //    Возвращаем новый AppState
      cartItems: cartItems ?? this.cartItems,                              //    Новый список, если передан, иначе — текущий
    );
  }
}