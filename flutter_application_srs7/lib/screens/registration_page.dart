import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';
import '../services/realtime_database_service.dart';
import 'users_list_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  final RealtimeDatabaseService _dbService = RealtimeDatabaseService();
  final NotificationService _notificationService = NotificationService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    try {
      // 1. Создаем модель пользователя
      final user = UserModel(
        fullName: name,
        email: email,
        phone: phone,
        password: password,
        fcmToken: _notificationService.fcmToken,
      );

      // 2. Сохраняем пользователя в Firebase Realtime Database
      final recordId = await _dbService.saveUser(user);

      // 3. Отправляем push-уведомление на устройство
      await _notificationService.showRegistrationSuccessNotification(
        fullName: name,
        email: email,
      );

      if (!mounted) return;

      // 4. Очищаем форму и показываем результат
      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _passwordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Успешно! Запись "$recordId" сохранена в Firebase Realtime Database. Push-уведомление отправлено!',
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'База данных',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersListPage()),
              );
            },
          ),
        ),
      );

      // Показываем диалоговое окно успеха
      _showSuccessDialog(name, email, recordId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Ошибка сохранения в Firebase: $e'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(String name, String email, String recordId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 54),
        title: const Text('Регистрация завершена!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Пользователь: $name', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Email: $email'),
            const SizedBox(height: 4),
            Text('ID в Realtime Database: $recordId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(height: 24),
            const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Push-уведомление отправлено в шторку устройства!',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersListPage()),
              );
            },
            child: const Text('Открыть список пользователей'),
          ),
        ],
      ),
    );
  }

  void _copyFcmToken() {
    final token = _notificationService.fcmToken;
    if (token != null && token.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: token));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 FCM Token скопирован в буфер обмена!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FCM Token пока не получен. Убедитесь, что подключен Firebase.'),
        ),
      );
    }
  }

  void _testLocalPush() async {
    await _notificationService.showNotification(
      title: 'Тестовое уведомление FCM 🔔',
      body: 'Проверка работы системы push-уведомлений в приложении!',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔔 Тестовое уведомление отправлено! Проверьте шторку уведомлений.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fcmToken = _notificationService.fcmToken;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лабораторная 7: Регистрация'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_outlined),
            tooltip: 'Список пользователей в Realtime Database',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersListPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Тест push-уведомления',
            onPressed: _testLocalPush,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Информационный блок Firebase & FCM статуса
              _buildStatusCard(theme, fcmToken),

              const SizedBox(height: 20),

              // Карточка формы регистрации
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.person_add_outlined,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Форма регистрации',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Данные сохраняются в Firebase Realtime Database с отправкой push-уведомления',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Divider(height: 24),

                        // Поле ввода ФИО
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'ФИО / Имя пользователя *',
                            hintText: 'Иван Иванов',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Пожалуйста, введите имя';
                            }
                            if (value.trim().length < 2) {
                              return 'Имя должно содержать не менее 2 символов';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Поле ввода Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Электронная почта (Email) *',
                            hintText: 'user@example.com',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Пожалуйста, введите Email';
                            }
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Введите корректный адрес электронной почты';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Поле ввода Телефона
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Номер телефона *',
                            hintText: '+7 (999) 123-45-67',
                            prefixIcon: Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Пожалуйста, введите номер телефона';
                            }
                            if (value.trim().length < 6) {
                              return 'Слишком короткий номер телефона';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Поле ввода Пароля
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Пароль *',
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите пароль';
                            }
                            if (value.length < 6) {
                              return 'Пароль должен быть не менее 6 символов';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Кнопка регистрации
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submitRegistration,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.cloud_upload_outlined),
                          label: Text(
                            _isLoading ? 'Сохранение...' : 'Зарегистрироваться',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Кнопка перехода к списку пользователей
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UsersListPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.storage_rounded),
                label: const Text('Перейти к списку пользователей в Realtime Database'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme, String? fcmToken) {
    final hasToken = fcmToken != null && fcmToken.isNotEmpty;

    return Card(
      elevation: 1,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasToken ? Icons.cloud_done : Icons.cloud_queue,
                  color: hasToken ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  hasToken ? 'Firebase & FCM активны' : 'Firebase инициализация',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              hasToken
                  ? 'FCM Token устройства получен. Вы можете скопировать его для отправки тестового Push из Firebase Console.'
                  : 'Если Firebase еще не подключен, следуйте инструкции в консоли Firebase.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            if (hasToken) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'FCM Token: ${fcmToken.substring(0, fcmToken.length > 25 ? 25 : fcmToken.length)}...',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: _copyFcmToken,
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('Копировать токен', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
