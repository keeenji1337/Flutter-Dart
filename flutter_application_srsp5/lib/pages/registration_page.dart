// ==================== СТРАНИЦА РЕГИСТРАЦИИ ====================
// Форма регистрации с проверками и полями ввода.

import 'package:flutter/material.dart';                                     // Импорт базовых виджетов + Material-дизайн
import 'package:flutter/services.dart';                                     // Отсюда FilteringTextInputFormatter и TextInputType
import 'user_info_page.dart';                                               // Своя страница информации (модуль 3)
import '../services/shared_prefs_service.dart';                             // Сервис сохранения в хранилище (модуль 2)

class RegistrationPage extends StatefulWidget {                             // StatefulWidget — форма меняет состояние
  const RegistrationPage({super.key});                                      // const-конструктор + key родителю
  @override                                                                 // Аннотация: переопределяю метод родителя
  State<RegistrationPage> createState() => _RegistrationPageState();        // Фреймворк вызовет сам, чтобы получить State
}                                                                           // Конец класса RegistrationPage

class _RegistrationPageState extends State<RegistrationPage> {              // _ = приватный класс, виден только в этом файле
  final _formKey = GlobalKey<FormState>();                                  // GlobalKey даёт доступ к состоянию Form снаружи (validate)
  final _nameController = TextEditingController();                          // «Ручка» поля Имя: читает/пишет/слушает текст
  final _phoneController = TextEditingController();                       
  final _emailController = TextEditingController();                        
  final _lifeStoryController = TextEditingController();                     
  final _passwordController = TextEditingController();                   
  final _confirmController = TextEditingController();                       
  final _nameFocus = FocusNode();                                           // FocusNode — управляет фокусом поля Имя
  final _phoneFocus = FocusNode();                                          // FocusNode для Телефона
  final _emailFocus = FocusNode();                                          // FocusNode для Email
  final _lifeStoryFocus = FocusNode();                                      // FocusNode для Истории
  final _passwordFocus = FocusNode();                                       // FocusNode для Пароля
  final _confirmFocus = FocusNode();                                        // FocusNode для Подтверждения
  bool _isPasswordObscured = true;                                          // true = пароль скрыт точками
  bool _isConfirmObscured = true;                                           // То же для подтверждения

  @override                                                                 // Переопределяю метод жизненного цикла
  void dispose() {                                                          // Вызывается, когда страница удаляется из дерева
    _nameController.dispose();                                              // Освобождаем нативные ресурсы — иначе утечка
    _phoneController.dispose();                                             // Каждый контроллер нужно закрыть вручную
    _emailController.dispose();
    _lifeStoryController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();                                                   // FocusNode тоже держит ресурсы — закрываем
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _lifeStoryFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();                                                        // Родительский dispose вызываем последним
  }

  void _submitForm() async {                                                // async — внутри await при сохранении на диск
    if (_formKey.currentState!.validate()) {                                // ! — не null; validate() запускает все validator'ы формы
      await SharedPrefsService.saveUserData(                                // Ждём, пока данные сохранятся
        _nameController.text,                                               // .text — текущее содержимое поля
        _phoneController.text,
        _emailController.text,
        _lifeStoryController.text,
      );
      if (mounted) {                                                        // mounted — виджет ещё в дереве? иначе Navigator упадёт
        Navigator.push(                                                     // push — положить новый экран поверх текущего
          context,                                                          // context нужен, чтобы найти Navigator в дереве
          MaterialPageRoute(builder: (context) => const UserInfoPage()),    // MaterialPageRoute — стандартная анимация перехода
        );
      }
    }
  }

  @override                                                                 // Переопределяю build
  Widget build(BuildContext context) {                                      // Возвращает описание UI; вызывается после каждого setState
    return Scaffold(                                                        // Каркас экрана: AppBar + body и т.д.
      appBar: AppBar(                                                       // Верхняя панель
        title: const Text('Register Form'),                                 // const — текст неизменяем
        centerTitle: true,                                                  // Центрируем заголовок (на Android по умолчанию слева)
        backgroundColor: Colors.blue,                                       // Синий фон панели
        foregroundColor: Colors.white,                                      // Цвет текста и иконок панели
      ),
      body: SingleChildScrollView(                                          // Прокрутка — спасает от overflow при нехватке высоты
        padding: const EdgeInsets.all(16.0),                                // Одинаковый отступ со всех сторон
        child: Form(                                                        // Form — контейнер, который умеет валидировать всё сразу
          key: _formKey,                                                    // Привязка ключа — через него вызовем validate()
          child: Column(                                                    // Column — вертикальный список детей
            children: [                                                     // Начало списка полей
              // ================= ПОЛЕ ИМЕНИ =================
              TextFormField(                                                // TextField + встроенная валидация
                controller: _nameController,                                // Связываем поле с контроллером
                focusNode: _nameFocus,                                      // Связываем с FocusNode
                decoration: InputDecoration(                                // Описывает внешний вид поля
                  labelText: 'Full Name *',                                 // label «плавает» над полем при вводе
                  prefixIcon: const Icon(Icons.person),                     // Иконка слева внутри поля
                  suffixIcon: IconButton(                                   // Интерактивная иконка справа
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _nameController.clear(),               // Стрелочная функция — короткая анонимная
                  ),
                  border: OutlineInputBorder(                               // Обводка вокруг поля
                    borderRadius: BorderRadius.circular(15.0),              // Радиус закругления углов
                  ),
                ),
                validator: (value) {                                        // Возвращает null (ок) или строку (ошибка)
                  if (value == null || value.isEmpty) {                     // Пустая строка — тоже «нет данных»
                    return 'Name cannot be empty';                          // Строка = сообщение под полем
                  }
                  return null;                                              // null = ошибок нет
                },
                onFieldSubmitted: (_) {                                     // Срабатывает при нажатии «Далее» на клавиатуре
                  FocusScope.of(context).requestFocus(_phoneFocus);         // Переносим фокус на следующее поле
                },
              ),
              const SizedBox(height: 16),                                   // Невидимый зазор между полями
              // ================= ПОЛЕ ТЕЛЕФОНА =================
              TextFormField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,                          // Тип клавиатуры — цифровая
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],  // Фильтр ввода «на лету»: только цифры
                decoration: InputDecoration(
                  labelText: 'Phone Number *',
                  helperText: 'Phone format: (XXX)XXX-XXXX',                // Постоянная подсказка снизу
                  prefixIcon: const Icon(Icons.phone),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _phoneController.clear(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone cannot be empty';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_emailFocus);         // Фокус → на email
                },
              ),
              const SizedBox(height: 16),                                   // Отступ
              // ================= ПОЛЕ EMAIL =================
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,                   // Клавиатура с @ и .com
                decoration: const InputDecoration(                          // const — decoration не меняется
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email cannot be empty';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');        // Регулярка; r'' — сырая строка без экранирования
                  if (!emailRegex.hasMatch(value)) {                        // hasMatch — проверяет совпадение с шаблоном
                    return 'Enter a valid email address';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_lifeStoryFocus);     // Фокус → на историю
                },
              ),
              const SizedBox(height: 16),                                   // Отступ
              // ================= ПОЛЕ ИСТОРИИ =================
              TextFormField(
                controller: _lifeStoryController,
                focusNode: _lifeStoryFocus,
                maxLines: 4,                                                // Фиксированная высота в 4 строки
                decoration: const InputDecoration(
                  labelText: 'Life Story',
                  helperText: 'Keep it short, this is just a demo',
                  border: OutlineInputBorder(),                             // Квадратная рамка
                ),
              ),
              const SizedBox(height: 16),                                   // Отступ
              // ================= ПОЛЕ ПАРОЛЯ =================
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: _isPasswordObscured,                           // true — символы заменяются точками
                decoration: InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: const Icon(Icons.security),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscured ? Icons.visibility : Icons.visibility_off, // Тернарник: открытый/закрытый глазик
                    ),
                    onPressed: () {
                      setState(() {                                         // setState — «данные изменились, перерисуй build»
                        _isPasswordObscured = !_isPasswordObscured;         // ! — логическое НЕ: переключаем true↔false
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password cannot be empty';
                  }
                  if (value.length < 6) {                                   // Простая проверка длины
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_confirmFocus);       // Фокус → на подтверждение
                },
              ),
              const SizedBox(height: 16),                                   // Отступ
              // ================= ПОДТВЕРЖДЕНИЕ ПАРОЛЯ =================
              TextFormField(
                controller: _confirmController,
                focusNode: _confirmFocus,
                obscureText: _isConfirmObscured,
                decoration: InputDecoration(
                  labelText: 'Confirm Password *',
                  prefixIcon: const Icon(Icons.edit),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmObscured ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmObscured = !_isConfirmObscured;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {                  // Сравниваем с первым паролем из его контроллера
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),                                   // Побольше отступ перед кнопкой
              // ================= КНОПКА ОТПРАВКИ =================
              SizedBox(
                width: double.infinity,                                     // double.infinity = «на всю ширину» (иначе сожмётся по тексту)
                height: 50,
                child: ElevatedButton(                                      // «Приподнятая» кнопка с тенью
                  onPressed: _submitForm,                                   // Ссылка на метод, а не его вызов
                  style: ElevatedButton.styleFrom(                          // styleFrom — фабрика стиля
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),             // Немного закруглённые углы
                    ),
                  ),
                  child: const Text(
                    'Submit Form',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],                                                              // Конец списка полей
          ),
        ),
      ),
    );
  }
}