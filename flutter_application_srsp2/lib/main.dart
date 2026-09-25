import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 2',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const Lab2Screen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Lab2Screen extends StatefulWidget {
  const Lab2Screen({super.key});

  @override
  State<Lab2Screen> createState() => _Lab2ScreenState();
}

class _Lab2ScreenState extends State<Lab2Screen> {
  // Переменная для хранения текущего значения BoxFit (масштабирования картинки).
  // Мы будем менять её, чтобы посмотреть, как ведут себя разные значения.
  BoxFit _currentFit = BoxFit.cover;

  // Флаг для переключения между двумя картинками.
  bool _showFirstImage = true;

  @override
  Widget build(BuildContext context) {
    // Выбираем какую картинку показывать в зависимости от флага
    final String currentImage = _showFirstImage ? 'assets/image1.jpg' : 'assets/image2.jpg';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лабораторная работа 2'),
      ),
      // 9. Stack позволяет накладывать виджеты друг на друга (по оси Z)
      body: Stack(
        children: [
          // 1. Самый нижний слой — это фоновое изображение.
          // Оборачиваем в Positioned.fill чтобы картинка заняла всё доступное место
          Positioned.fill(
            child: Image.asset(
              currentImage,
              // Эффекты от разных значений BoxFit:
              // BoxFit.fill: Растягивает картинку, искажая пропорции, чтобы заполнить весь экран.
              // BoxFit.contain: Картинка умещается целиком, сохраняя пропорции. Могут появиться пустые края.
              // BoxFit.cover: Картинка заполняет весь экран, сохраняя пропорции, но лишнее обрезается.
              // BoxFit.fitWidth: Подгоняет картинку по ширине экрана, по высоте может обрезать.
              // BoxFit.fitHeight: Подгоняет картинку по высоте, по ширине может обрезать.
              // BoxFit.none: Не масштабирует вообще. Картинка показывается в оригинальном размере (чаще всего по центру).
              // BoxFit.scaleDown: Работает как none, но если картинка больше экрана — уменьшает её, чтобы влезла (как contain).
              fit: _currentFit, 
            ),
          ),
          
          // 2. Полупрозрачный черный контейнер поверх картинки.
          // Нужен чтобы текст на фоне пестрой картинки был читаемым.
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          
          // 3. Основной контент (Текст и кнопки) поверх всего остального
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Текст поверх контейнера
                const Text(
                  'Welcome to Flutter',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Задание 10: ElevatedButton (Вызов SnackBar)
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Цвет кнопки: синий
                      foregroundColor: Colors.white, // Цвет текста: белый
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Привет! Это SnackBar!')),
                      );
                    },
                    child: const Text(
                      'Show SnackBar',
                      style: TextStyle(fontSize: 16), // Размер текста: 16
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Задание 11: TextButton (Переход на второй экран)
                SizedBox(
                  width: 200,
                  height: 50,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent, // Цвет кнопки: прозрачный
                      foregroundColor: Colors.green, // Цвет текста: зеленый
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SecondScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Go to Second Screen',
                      style: TextStyle(fontSize: 16), // Размер текста: 16
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Задание 12: OutlinedButton (Переключение картинки)
                SizedBox(
                  width: 200,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Цвет кнопки: прозрачный
                      foregroundColor: Colors.black, // Цвет текста: черный
                      side: const BorderSide(color: Colors.black), // Цвет границы: черный
                    ),
                    onPressed: () {
                      setState(() {
                        _showFirstImage = !_showFirstImage;
                      });
                    },
                    child: const Text(
                      'Toggle Image',
                      style: TextStyle(fontSize: 16), // Размер текста: 16
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Кнопки для переключения BoxFit, чтобы было удобно тестировать эффекты
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildFitButton(BoxFit.fill),
                    _buildFitButton(BoxFit.contain),
                    _buildFitButton(BoxFit.cover),
                    _buildFitButton(BoxFit.fitWidth),
                    _buildFitButton(BoxFit.fitHeight),
                    _buildFitButton(BoxFit.none),
                    _buildFitButton(BoxFit.scaleDown),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Вспомогательный метод для создания кнопок переключения BoxFit
  Widget _buildFitButton(BoxFit fit) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _currentFit == fit ? Colors.orange : Colors.grey,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        setState(() {
          _currentFit = fit;
        });
      },
      child: Text(fit.name),
    );
  }
}

// Второй экран, на который мы переходим по кнопке "Go to Second Screen".
class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Второй экран')),
      // Здесь мы выводим вторую картинку (image2.jpg) на весь экран.
      body: Center(
        child: Image.asset(
          'assets/image2.jpg',
          // Используем тип масштабирования BoxFit.contain.
          // Он делает так, чтобы картинка целиком поместилась на экране, не обрезаясь и сохраняя свои оригинальные пропорции.
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
