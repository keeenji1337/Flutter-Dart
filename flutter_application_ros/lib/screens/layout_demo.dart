import 'package:flutter/material.dart';                                    // Material Design: базовые UI-компоненты

class LayoutDemoScreen extends StatelessWidget {                           // Экран демонстрации вёрстки (без изменяемого состояния)
  const LayoutDemoScreen({super.key});                                     // Конструктор с ключом

  @override                                                                // Построение интерфейса
  Widget build(BuildContext context) {
    return Scaffold(                                                       // Базовый макет страницы
      appBar: AppBar(                                                      // Верхняя панель (header)
        title: const Text('Вёрстка (Layout)'),                             // Заголовок страницы
      ),
      body: SafeArea(                                                      // Безопасная зона: контент не перекрывается "челкой" и системными барами
        child: ListView(                                                   // Прокрутка контента по вертикали
          padding: const EdgeInsets.all(8.0),                              // Внутренние отступы списка
          children: [
            const Text('1. Container, Padding, Center, Align', style: TextStyle(fontWeight: FontWeight.bold)), // Заголовок секции 1
            Container(                                                     // Container — универсальная коробка: цвет, размеры, отступы
              height: 100,                                                 //    Фиксированная высота
              color: Colors.grey[300],                                   //    Цвет фона (светло-серый)
              child: Padding(                                              //    Padding: отступы между краем и child
                padding: const EdgeInsets.all(8.0),                        //    Внутренние отступы
                child: Center(                                             //    Center: центрирует дочерний виджет
                  child: Align(                                            //    Align: гибкое выравнивание
                    alignment: Alignment.bottomRight,                      //    Сдвигаем в правый нижний угол
                    child: Container(                                      //    Красный квадратик
                      color: Colors.red,                                 //    Цвет квадратика
                      child: const Text('Align bottom right'),             //    Текст внутри
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),                                    // Распорка-отступ
            const Text('2. Row, Column, Expanded (flex)', style: TextStyle(fontWeight: FontWeight.bold)), // Заголовок секции 2
            Container(                                                     // Контейнер с фиксированной высотой
              height: 150,                                                 //    Высота
              color: Colors.blue[50],                                    //    Светло-синий фон
              child: Row(                                                  //    Row: элементы по горизонтали
                children: [
                  Container(width: 50, color: Colors.blue, child: const Center(child: Text('50'))), // Фиксированная ширина 50
                  Expanded(                                                //    Expanded: занять всё свободное место
                    flex: 2,                                               //    Пропорция 2
                    child: Container(color: Colors.green, child: const Center(child: Text('flex: 2'))), // Зелёный блок
                  ),
                  Expanded(                                                //    Expanded: пропорция 1
                    flex: 1,                                               //    Пропорция 1
                    child: Column(                                         //    Column: элементы по вертикали
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,    //    Равные промежутки вдоль вертикали
                      children: const [
                        Text('Col 1'),                                     //    Первый текст
                        Text('Col 2'),                                     //    Второй текст
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),                                    // Распорка-отступ
            const Text('3. Stack', style: TextStyle(fontWeight: FontWeight.bold)), // Заголовок секции 3
            SizedBox(                                                      // Фиксированная высота для Stack
              height: 150,                                                 //    Высота
              child: Stack(                                                //    Stack: наложение виджетов друг на друга
                alignment: Alignment.center,                               //    Выравнивание непозиционированных детей
                children: [
                  Container(width: 100, height: 100, color: Colors.yellow), //    Нижний слой: жёлтый квадрат
                  Container(width: 80, height: 80, color: Colors.orange),   //    Слой поверх: оранжевый квадрат
                  Positioned(                                                 //    Positioned: только внутри Stack
                    bottom: 10,                                               //    Отступ от нижнего края
                    right: 10,                                                //    Отступ от правого края
                    child: Container(color: Colors.black, child: const Text('Top', style: TextStyle(color: Colors.white))), // Подпись "Top"
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),                                    // Распорка-отступ
            const Text('4. GridView (Обернут в SizedBox)', style: TextStyle(fontWeight: FontWeight.bold)), // Заголовок секции 4
            SizedBox(                                                      // Фиксированная высота: GridView внутри ListView
              height: 200,                                                 //    Высота
              child: GridView.count(                                       //    GridView.count: сетка с фиксированным числом колонок
                crossAxisCount: 3,                                         //    3 колонки
                mainAxisSpacing: 4,                                        //    Отступ по вертикали
                crossAxisSpacing: 4,                                       //    Отступ по горизонтали
                children: List.generate(6, (index) {                       //    Генерируем 6 ячеек
                  return Container(                                        //    Ячейка
                    color: Colors.teal[100 * (index % 9)],               //    Разный оттенок Teal
                    child: Center(child: Text('Item $index')),             //    Текст по центру
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),                                    // Распорка-отступ
            const Text('5. Table', style: TextStyle(fontWeight: FontWeight.bold)), // Заголовок секции 5
            Table(                                                         // Table: классическая таблица (строки и столбцы)
              border: TableBorder.all(),                                   //    Границы вокруг всех ячеек
              children: const [
                TableRow(                                                  //    Строка 1
                  children: [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Ячейка 1')), // Ячейка 1
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Ячейка 2')), // Ячейка 2
                  ],
                ),
                TableRow(                                                  //    Строка 2
                  children: [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Ячейка 3')), // Ячейка 3
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Ячейка 4')), // Ячейка 4
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),                                    // Распорка-отступ
            const Text('6. BoxFit (Для картинок)', style: TextStyle(fontWeight: FontWeight.bold)), // Заголовок секции 6
            Row(                                                           // Горизонтальный ряд примеров BoxFit
              mainAxisAlignment: MainAxisAlignment.spaceAround,            //    Равномерное распределение
              children: [
                Column(                                                    //    Пример BoxFit.cover
                  children: [
                    const Text('BoxFit.cover'),                            //    Подпись
                    Container(                                             //    Контейнер-рамка
                      width: 100, height: 100, color: Colors.grey,                   //    Размер и серый фон
                      child: Image.asset('assets/images/dash.gif', fit: BoxFit.cover), // Картинка обрезается под контейнер
                    ),
                  ],
                ),
                Column(                                                    //    Пример BoxFit.contain
                  children: [
                    const Text('BoxFit.contain'),                          //    Подпись
                    Container(                                             //    Контейнер-рамка
                      width: 100, height: 100, color: Colors.grey,       //    Размер и серый фон
                      child: Image.asset('assets/images/dash.gif', fit: BoxFit.contain), // Картинка вписана целиком
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),                                    // Финальный отступ снизу
          ],
        ),
      ),
    );
  }
}