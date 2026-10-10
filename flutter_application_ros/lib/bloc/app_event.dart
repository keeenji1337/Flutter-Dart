abstract class AppEvent {}                                                 // Базовый класс для всех событий (нельзя создать напрямую, только наследников)

class AddToCartEvent extends AppEvent {                                    // Событие добавления товара в корзину
  final String item;                                                       // Название или ID товара

  AddToCartEvent(this.item);                                               // Конструктор: обязательный параметр item
}

class RemoveFromCartEvent extends AppEvent {                               // Событие удаления товара из корзины
  final String item;                                                       // Название товара для удаления

  RemoveFromCartEvent(this.item);                                          // Конструктор: обязательный параметр item
}