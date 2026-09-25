import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LayoutBasicsScreen(),
    );
  }
}

class LayoutBasicsScreen extends StatelessWidget {
  const LayoutBasicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Серый фон для всего экрана
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        // Настраиваем шапку
        title: const Text(
          'Lab 3: Layout Basics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        // Небольшие отступы по краям для визуала
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Первый блок (синий)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12), // Скругляем углы
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2), // Тень
                    offset: const Offset(2, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Center(
                // Центрирование текста внутри контейнера
                child: Text(
                  'Welcome to Flutter!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Расстояние между блоками
            const SizedBox(height: 16),
            
            // Второй блок (зеленый)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white, // Белая рамка
                  width: 2,
                ),
              ),
              child: const Row(
                // Раскидываем текст по разным краям
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Left Text',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Right Text',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
