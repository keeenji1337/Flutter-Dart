import 'package:flutter/material.dart';

// Простая модель товара для демонстрации (Обычно такие классы лежат в папке models)
class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;

  Product({required this.id, required this.name, required this.price, required this.imageUrl});
}

// Глобальный список для имитации базы данных товаров (демонстрационные данные)
final List<Product> mockProducts = [
  Product(id: 1, name: "Кроссовки Nike", price: 120.0, imageUrl: "assets/images/nike.jpg"),
  Product(id: 2, name: "Футболка Adidas", price: 40.0, imageUrl: "assets/images/adidas.jpg"),
  Product(id: 3, name: "Кепка Puma", price: 25.0, imageUrl: "assets/images/puma.jpg"),
  Product(id: 4, name: "Штаны Reebok", price: 60.0, imageUrl: "assets/images/reebok.jpg"),
];

// Глобальный ValueNotifier для хранения списка избранных ID.
// Это простой способ сделать состояние глобальным без сложных стейт-менеджеров.
final ValueNotifier<List<int>> favoriteIdsNotifier = ValueNotifier<List<int>>([]);

// Функция для добавления/удаления из избранного
void toggleFavorite(int id) {
  final current = List<int>.from(favoriteIdsNotifier.value);
  if (current.contains(id)) {
    current.remove(id); // Если уже есть - удаляем
  } else {
    current.add(id);    // Если нет - добавляем
  }
  favoriteIdsNotifier.value = current; // Уведомляем всех слушателей о новой версии списка
}
