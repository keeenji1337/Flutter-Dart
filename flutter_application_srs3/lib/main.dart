import 'package:flutter/material.dart';          // Основная библиотека Flutter с готовыми виджетами (кнопки, тексты и т.д.)
import 'package:fluttertoast/fluttertoast.dart'; // Сторонняя библиотека для вывода коротких всплывающих уведомлений снизу

void main() {
  runApp(const MyApp());                          // runApp берёт виджет и делает его корнем всего дерева приложения
}

// ==================== КОРНЕВОЙ ВИДЖЕТ ПРИЛОЖЕНИЯ ====================
class MyApp extends StatelessWidget {             // StatelessWidget - виджет без изменяемого состояния, сам себя не перерисовывает
  const MyApp({super.key});                       // super.key помогает Flutter отличать виджеты друг от друга при обновлении дерева

  @override                                       // Переопределяем метод build, чтобы описать внешний вид виджета
  Widget build(BuildContext context) {            // build вызывается каждый раз, когда Flutter должен отрисовать этот виджет
    return MaterialApp(                           // MaterialApp даёт базовую структуру: навигацию, темы, локализацию
      debugShowCheckedModeBanner: false,          // Убирает красную ленточку "DEBUG" в правом верхнем углу экрана
      title: 'Лабораторная работа №3',            // Название приложения (используется системой, на экране не отображается)

      theme: ThemeData(                                              // Глобальные настройки внешнего вида - единая тема (Задание 7)
        useMaterial3: true,                                          // Включает современный визуальный стиль Material Design 3
        primarySwatch: Colors.teal,                                  // Основной цвет приложения, от него строятся все оттенки
        scaffoldBackgroundColor: Colors.grey[100],                   // Цвет фона по умолчанию на всех экранах

        appBarTheme: const AppBarTheme(                              // Единый стиль для всех верхних панелей (AppBar)
          backgroundColor: Colors.teal,                              // Цвет фона шапки
          foregroundColor: Colors.white,                             // Цвет иконок и текста кнопок в шапке
          elevation: 2,                                              // Небольшая тень под шапкой для эффекта объёма
          centerTitle: false,                                        // Заголовок прижат влево (иначе на iOS был бы по центру)
          titleTextStyle: TextStyle(                                 // Стиль текста заголовка в AppBar
            fontSize: 20,                                            // Размер шрифта заголовка
            fontWeight: FontWeight.bold,                             // Жирное начертание заголовка
            color: Colors.white,                                     // Белый цвет текста заголовка
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(                // Единый стиль для всех кнопок ElevatedButton в приложении
          style: ElevatedButton.styleFrom(                           // styleFrom - удобный способ задать стиль без ручного ButtonStyle
            backgroundColor: Colors.teal,                            // Цвет фона кнопки
            foregroundColor: Colors.white,                           // Цвет текста и иконки на кнопке
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), // Внутренние отступы кнопки
            shape: RoundedRectangleBorder(                           // Форма кнопки
              borderRadius: BorderRadius.circular(10),                // Скругление углов кнопки на 10 пикселей
            ),
          ),
        ),

        textTheme: const TextTheme(                                   // Единые стили заголовков текста по всему приложению
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),  // Крупный заголовок (например, экран профиля)
          titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600), // Заголовок среднего размера (например, в карточках)
        ),
      ),
      home: const HomeScreen(),                                        // Экран, который открывается первым при запуске приложения
    );
  }
}

// Небольшая обёртка над Fluttertoast, чтобы не дублировать параметры в каждом месте вызова (Задание 6)
void showToast(String message) {                     // Принимает текст, который нужно показать во всплывающем уведомлении
  Fluttertoast.showToast(                             // Вызываем метод библиотеки fluttertoast для показа Toast-сообщения
    msg: message,                                     // Текст самого уведомления
    toastLength: Toast.LENGTH_SHORT,                  // Короткая длительность показа
    gravity: ToastGravity.BOTTOM,                     // Уведомление появляется внизу экрана
  );
}

// ==================== МОДЕЛЬ ТОВАРА (для карточек) ====================
class Product {                                       // Для хранения данных одного товара
  final String name;                               
  final String description;                           
  final String fullDescription;                       
  final String price;                                 
  final IconData icon;                                
  final Color color;                                  // Цвет фона "изображения" товара

  const Product({                                     // Конструктор с именованными обязательными параметрами
    required this.name,
    required this.description,
    required this.fullDescription,
    required this.price,
    required this.icon,
    required this.color,
  });
}

// Список товаров для экрана "Карточки" (минимум 4 штуки - Задание 4)
final List<Product> products = [
  Product(
    name: 'Смартфон',                                                    
    description: 'Современный смартфон с большим экраном',               
    fullDescription:
        'Мощный современный смартфон с ярким экраном, быстрой зарядкой '
        'и отличной камерой для повседневных задач.',                     
    price: '49 990 ₽',                                                  
    icon: Icons.smartphone,                                           
    color: Colors.indigo,                                                 
  ),
  Product(                                                                // Товар №2
    name: 'Ноутбук',
    description: 'Лёгкий и производительный ноутбук',
    fullDescription:
        'Тонкий и лёгкий ноутбук с мощным процессором - отлично подходит '
        'для учёбы, работы и творческих задач.',
    price: '79 990 ₽',
    icon: Icons.laptop_mac,
    color: Colors.deepOrange,
  ),
  Product(                                                                // Товар №3
    name: 'Наушники',
    description: 'Беспроводные наушники с шумоподавлением',
    fullDescription:
        'Беспроводные наушники с активным шумоподавлением и временем '
        'работы до 30 часов от одного заряда.',
    price: '9 990 ₽',
    icon: Icons.headphones,
    color: Colors.teal,
  ),
  Product(                                                                // Товар №4
    name: 'Умные часы',
    description: 'Часы для отслеживания активности',
    fullDescription:
        'Умные часы с пульсометром, GPS-модулем и защитой от воды - '
        'помогают следить за здоровьем в течение дня.',
    price: '14 990 ₽',
    icon: Icons.watch,
    color: Colors.purple,
  ),
];

// ==================== ГЛАВНЫЙ ЭКРАН (TabBar + Drawer) ====================
class HomeScreen extends StatefulWidget {                              // StatefulWidget - экрану нужно хранить и менять состояние
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();                // Создаёт объект состояния, связанный с этим виджетом
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {                                // Миксин нужен, чтобы TabController мог использовать анимацию
  late final TabController _tabController;                              // Контроллер вкладок - управляем вручную, не через DefaultTabController

  int _currentTab = 0;                                                   // Индекс текущей открытой вкладки (0 - Список, 1 - Сетка)

  final List<String> _listItems =
      List.generate(10, (i) => 'Товар №${i + 1}');                       // 10 товаров для вкладки "Список" (Задание 2), хранятся здесь,
                                                                         // чтобы можно было добавлять новые через FAB (доп. задание)

  @override
  void initState() {                                                     // initState вызывается один раз при создании экрана
    super.initState();                                                   // Обязательно вызываем родительский initState
    _tabController = TabController(length: 2, vsync: this);              // Контроллер на 2 вкладки, this - источник анимации (vsync)
    _tabController.addListener(() {                                      // Подписываемся на изменения активной вкладки
      setState(() {                                                      // setState просит Flutter перерисовать экран
        _currentTab = _tabController.index;                              // Запоминаем новый индекс вкладки
      });
    });
  }

  @override
  void dispose() {                                                       // dispose вызывается при уничтожении экрана
    _tabController.dispose();                                            // Освобождаем ресурсы контроллера (иначе утечка памяти)
    super.dispose();                                                     // Обязательно вызываем родительский dispose
  }

  void _addNewItem(String name) {                                        // Добавляет новый товар в список (доп. задание)
    setState(() {                                                        // Оборачиваем изменение в setState, чтобы список перерисовался
      _listItems.add(name);                                              // Добавляем введённое пользователем название в конец списка
    });
  }

  void _showAddItemDialog() {                                            // Показывает диалог для ввода названия нового товара
    final TextEditingController controller = TextEditingController();    // Контроллер для чтения текста из поля ввода

    showDialog(                                                          // Открывает модальное окно поверх экрана
      context: context,                                                  // Контекст текущего экрана, нужен для показа диалога
      builder: (dialogContext) {                                         // builder строит содержимое диалога
        return AlertDialog(                                              // Стандартное диалоговое окно Material Design
          title: const Text('Новый товар'),                              // Заголовок диалога
          content: TextField(                                            // Поле для ввода текста
            controller: controller,                                      // Привязываем контроллер, чтобы прочитать введённый текст
            autofocus: true,                                             // Клавиатура и фокус появляются сразу при открытии
            decoration: const InputDecoration(
              hintText: 'Введите название товара',                       // Подсказка серым цветом в пустом поле
            ),
          ),
          actions: [                                                     // Кнопки внизу диалога
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),             // Закрывает диалог без добавления товара
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {                                            // Обработка нажатия кнопки "Добавить"
                final text = controller.text.trim();                     // Убираем лишние пробелы по краям текста
                if (text.isNotEmpty) {                                   // Добавляем товар, только если поле не пустое
                  _addNewItem(text);
                }
                Navigator.pop(dialogContext);                            // Закрываем диалог в любом случае
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(                                                      // Scaffold - базовый каркас экрана (AppBar, тело, Drawer, FAB)
      appBar: AppBar(                                                     // Верхняя панель экрана
        title: const Text('Моё приложение'),                              // Заголовок в шапке
        actions: [                                                        // Кнопки в правой части AppBar
          IconButton(                                                     // Кнопка перехода на экран с карточками товаров
            icon: const Icon(Icons.style),                                // Иконка в виде стопки карточек
            tooltip: 'Карточки',                                          // Подсказка при долгом нажатии
            onPressed: () {                                               // Обработчик нажатия
              Navigator.push(                                             // Открывает новый экран поверх текущего
                context,
                MaterialPageRoute(builder: (_) => const CardsScreen()),   // Экран, на который переходим
              );
            },
          ),
        ],
        bottom: TabBar(                                                   // Полоса вкладок под AppBar (Задание 1)
          controller: _tabController,                                     // Связываем TabBar с нашим контроллером
          tabs: const [                                                   // Список самих вкладок
            Tab(text: 'Список'),                                          // Первая вкладка
            Tab(text: 'Сетка'),                                           // Вторая вкладка
          ],
        ),
      ),
      drawer: buildAppDrawer(context),                                    // Боковое выезжающее меню (Задание 5)
      body: TabBarView(                                                   // Область показа содержимого активной вкладки
        controller: _tabController,                                       // Тот же контроллер, что и у TabBar - для синхронизации
        children: [
          ListTab(items: _listItems),                                     // Содержимое вкладки "Список"
          const GridTab(),                                                // Содержимое вкладки "Сетка"
        ],
      ),
      floatingActionButton: _currentTab == 0                               // FAB показываем только когда открыта вкладка "Список"
          ? FloatingActionButton(
              onPressed: _showAddItemDialog,                              // При нажатии открываем диалог добавления товара
              tooltip: 'Добавить товар',
              child: const Icon(Icons.add),                               // Иконка "плюс"
            )
          : null,                                                         // На вкладке "Сетка" кнопки нет вообще
    );
  }
}

// ==================== БОКОВОЕ МЕНЮ (Drawer) ====================
// Вынесено в отдельную функцию, чтобы использовать на нескольких экранах (Задание 5)
Widget buildAppDrawer(BuildContext context) {                              // context нужен, чтобы закрывать Drawer и открывать экраны
  return Drawer(                                                          // Drawer - стандартное выезжающее сбоку меню
    child: ListView(                                                      // ListView внутри, чтобы пункты можно было прокручивать
      padding: EdgeInsets.zero,                                           // Убираем стандартные отступы у ListView внутри Drawer
      children: [
        const DrawerHeader(                                               // Верхняя цветная "шапка" меню
          decoration: BoxDecoration(color: Colors.teal),                  // Заливка шапки основным цветом приложения
          child: Align(
            alignment: Alignment.bottomLeft,                              // Прижимаем текст к нижнему левому углу шапки
            child: Text(
              'Меню',
              style: TextStyle(color: Colors.white, fontSize: 26),        // Крупный белый текст заголовка меню
            ),
          ),
        ),
        ListTile(                                                         // Пункт меню "Главная"
          title: const Text('🏠 Главная'),
          onTap: () {                                                     // Обработчик нажатия на пункт
            Navigator.pop(context);                                       // Сначала закрываем сам Drawer
            Navigator.popUntil(context, (route) => route.isFirst);        // Убираем со стека все экраны, кроме самого первого (Главной)
          },
        ),
        ListTile(                                                         // Пункт меню "Профиль"
          title: const Text('👤 Профиль'),
          onTap: () {
            Navigator.pop(context);                                       // Закрываем Drawer
            Navigator.push(                                               // Открываем экран профиля поверх текущего
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
        ListTile(                                                         // Пункт меню "Настройки"
          title: const Text('⚙️ Настройки'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
        const Divider(),                                                  // Тонкая горизонтальная линия-разделитель
        ListTile(                                                         // Пункт меню "Выход"
          title: const Text('🚪 Выход'),
          onTap: () {
            Navigator.pop(context);                                       // Закрываем Drawer
            showToast('Выход из аккаунта');                               // Показываем Toast (реальный выход не нужен по заданию)
          },
        ),
      ],
    ),
  );
}

// ==================== ВКЛАДКА "СПИСОК" (ListView) ====================
class ListTab extends StatelessWidget {                                  // Сам список не хранит собственное состояние
  final List<String> items;                                              // Список названий товаров, переданный из HomeScreen

  const ListTab({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(                                             // .builder строит элементы только когда они видны на экране
      padding: const EdgeInsets.symmetric(vertical: 8),                  // Небольшие отступы сверху и снизу списка
      itemCount: items.length,                                           // Сколько всего элементов нужно построить
      itemBuilder: (context, index) {                                    // Строит один элемент списка по его индексу
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Отступы вокруг каждого элемента-карточки
          child: Card(                                                    // Card из Задания 4, оборачивает каждый элемент списка
            elevation: 2,                                                 // Небольшая тень у карточки
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),                    // Скруглённые углы карточки
            ),
            child: ListTile(                                              // Готовый виджет "строка списка" с иконкой и текстом
              leading: const CircleAvatar(                                // leading - виджет слева (Задание 2)
                backgroundColor: Colors.teal,
                child: Icon(Icons.shopping_bag, color: Colors.white),     // Иконка товара внутри цветного кружка
              ),
              title: Text(items[index]),                                  // title - название товара (Задание 2)
              subtitle: const Text('Описание товара'),                    // subtitle - подпись под названием (Задание 2)
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),    // trailing - стрелка справа (Задание 2)
              onTap: () => showToast('Вы выбрали: ${items[index]}'),      // При нажатии показываем Toast (Задание 1/2)
            ),
          ),
        );
      },
    );
  }
}

// ==================== ВКЛАДКА "СЕТКА" (GridView) ====================
class GridTab extends StatefulWidget {                                   // Нужно хранить и менять цвет каждой ячейки
  const GridTab({super.key});

  @override
  State<GridTab> createState() => _GridTabState();
}

class _GridTabState extends State<GridTab> {
  static const int _itemCount = 6;                                       // Количество ячеек сетки (минимум 6 по Заданию 3)

  late final List<Color> _colors;                                        // У каждой ячейки свой независимый цвет

  @override
  void initState() {
    super.initState();
    _colors = List.generate(_itemCount, (_) => Colors.blue);             // Изначально все 6 ячеек синие
  }

  void _toggleColor(int index) {                                         // Переключает цвет одной конкретной ячейки
    setState(() {                                                        // setState перерисовывает экран после изменения данных
      _colors[index] =
          _colors[index] == Colors.blue ? Colors.green : Colors.blue;    // Была синяя - станет зелёной, и наоборот
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),                                 // Отступы вокруг всей сетки
      child: GridView.builder(                                           // GridView.builder рекомендован заданием
        itemCount: _itemCount,                                           // Сколько всего ячеек нужно построить
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(   // Делегат определяет расположение ячеек в сетке
          crossAxisCount: 3,                                             // 3 колонки -> при 6 элементах получится 2 ряда
          crossAxisSpacing: 12,                                          // Расстояние между колонками
          mainAxisSpacing: 12,                                           // Расстояние между рядами
        ),
        itemBuilder: (context, index) {                                  // Строит одну ячейку сетки по её индексу
          return GestureDetector(                                        // Ловит нажатия на ячейку
            onTap: () => _toggleColor(index),                            // При нажатии переключаем цвет именно этой ячейки
            child: Container(                                            // Сама ячейка
              alignment: Alignment.center,                                // Число внутри ячейки по центру
              decoration: BoxDecoration(
                color: _colors[index],                                    // Текущий цвет этой ячейки (Задание 3)
                borderRadius: BorderRadius.circular(16),                   // Скруглённые углы ячейки (Задание 3)
              ),
              child: Text(
                '${index + 1}',                                           // Номер ячейки от 1 до 6 (Задание 3)
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== ЭКРАН "КАРТОЧКИ" (Card) ====================
class CardsScreen extends StatelessWidget {                              // Отдельный экран со списком карточек товаров (Задание 4)
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Карточки')),                     // Заголовок экрана
      body: ListView.builder(                                            // Список карточек, построенных по данным из products
        padding: const EdgeInsets.all(12),
        itemCount: products.length,                                      // Количество товаров в списке (минимум 4)
        itemBuilder: (context, index) {
          final product = products[index];                               // Товар, который нужно отобразить в текущей карточке
          return Card(                                                    // Сама карточка товара
            clipBehavior: Clip.antiAlias,                                 // Обрезает содержимое по скруглённым углам карточки
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 14),                    // Отступ снизу между карточками
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,               // Весь текст внутри карточки прижат к левому краю
              children: [
                Container(                                                 // "Изображение" товара - цветной блок с иконкой
                  height: 130,                                             // Высота блока-изображения
                  width: double.infinity,                                  // Блок растягивается на всю ширину карточки
                  alignment: Alignment.center,                             // Иконка по центру блока
                  color: product.color,                                    // Цвет блока берём из данных товара
                  child: Icon(product.icon, size: 56, color: Colors.white),// Крупная белая иконка товара
                ),
                Padding(
                  padding: const EdgeInsets.all(12),                       // Отступы вокруг текстовой части карточки
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,                                      // Название товара
                        style: Theme.of(context).textTheme.titleMedium,    // Единый стиль заголовка из темы (Задание 7)
                      ),
                      const SizedBox(height: 4),                           // Отступ между названием и описанием
                      Text(
                        product.description,                               // Краткое описание товара
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,                  // Прижимаем кнопку к правому краю карточки
                        child: ElevatedButton(
                          onPressed: () {                                  // Открываем экран с подробностями (Задание 4)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: product), // Передаём товар на новый экран
                              ),
                            );
                          },
                          child: const Text('Подробнее'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== ЭКРАН "ПОДРОБНОЕ ОПИСАНИЕ ТОВАРА" ====================
class ProductDetailScreen extends StatelessWidget {                       // Открывается по кнопке "Подробнее" с карточки
  final Product product;                                                  // Товар, детали которого нужно показать

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),                          // В заголовке экрана - название товара
      body: SingleChildScrollView(                                        // Позволяет прокручивать, если контент не помещается
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(                                                     // Большой цветной блок вместо фотографии товара
              height: 220,
              width: double.infinity,
              alignment: Alignment.center,
              color: product.color,
              child: Icon(product.icon, size: 90, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge,         // Крупный заголовок из общей темы (Задание 7)
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.price,                                         // Цена товара
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.fullDescription,                               // Полное описание товара
                    style: const TextStyle(fontSize: 16, height: 1.4),     // height - межстрочный интервал для удобства чтения
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

// ==================== ЭКРАН "ПРОФИЛЬ" ====================
class ProfileScreen extends StatelessWidget {                             // Простой экран с информацией о пользователе (Задание 5)
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      drawer: buildAppDrawer(context),                                    // Тот же Drawer, что и на Главной - можно перейти на другой экран
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,                  // Содержимое по центру экрана по вертикали
            children: [
              const CircleAvatar(                                         // Аватар пользователя (иконка вместо настоящего фото)
                radius: 50,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Абрамов Даниил',                                             
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'abramovdaniil@gmail.com',                                 
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ЭКРАН "НАСТРОЙКИ" ====================
class SettingsScreen extends StatefulWidget {                             // Нужно хранить состояние переключателя
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;                                      // Состояние переключателя уведомлений (Задание 5)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      drawer: buildAppDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(                                                // Готовый виджет "переключатель + подпись"
              title: const Text('Уведомления'),
              value: _notificationsEnabled,                                // Текущее состояние переключателя
              onChanged: (value) {                                         // Вызывается при переключении
                setState(() {
                  _notificationsEnabled = value;                           // Сохраняем новое состояние и перерисовываем экран
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(                                                 // Кнопка приветствия из Задания 6
              onPressed: () => showToast('Hello, Flutter!'),                // Показывает Toast с приветствием
              child: const Text('Показать приветствие'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(                                                 // Кнопка сохранения настроек - ещё одно место с Toast
              onPressed: () => showToast('Настройки сохранены'),
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}