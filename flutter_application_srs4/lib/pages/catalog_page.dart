import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/models/product.dart';
import '../generated/locale_keys.g.dart';

// ==================== СТРАНИЦА КАТАЛОГА ====================
// Здесь отображается список товаров в виде сетки (GridView)
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.catalog.tr()),                       // Название страницы из локализации
        centerTitle: true,
      ),
      // GridView.builder позволяет создавать элементы сетки лениво (по мере прокрутки),
      // что очень хорошо для производительности, когда элементов много.
      body: GridView.builder(
        padding: EdgeInsets.all(16.w),                     // Адаптивные отступы от краев экрана
        // SliverGridDelegateWithFixedCrossAxisCount задает сетку с фиксированным числом колонок
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,                               // 2 колонки
          childAspectRatio: 0.75,                          // Соотношение сторон элемента (ширина/высота)
          crossAxisSpacing: 16.w,                          // Расстояние между колонками
          mainAxisSpacing: 16.h,                           // Расстояние между строками
        ),
        itemCount: mockProducts.length,                    // Количество элементов берем из списка данных
        itemBuilder: (context, index) {
          final product = mockProducts[index];             // Получаем конкретный товар
          return _buildProductCard(context, product);      // Отрисовываем карточку товара
        },
      ),
    );
  }

  // Метод для создания отдельной карточки товара
  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      // Декорация карточки: цвет фона зависит от темы, скругленные углы
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // ClipRRect обрезает содержимое (например картинку) по краям скругленного контейнера
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,    // Текст по левому краю
          children: [
            // Expanded здесь нужен, чтобы картинка заняла верхнюю часть, а текст - нижнюю
            Expanded(
              // Image.asset загружает картинку из локальных файлов
              child: Image.asset(
                product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,                         // Заполняет все пространство, обрезая лишнее
                // Обработка ошибки загрузки картинки (чтобы приложение не падало, если файла нет)
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
              ),
            ),
            // Padding для текста и иконки
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название товара
                  Text(
                    product.name,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,                           // Не больше 1 строки
                    overflow: TextOverflow.ellipsis,       // Если не влезает, ставит "..."
                  ),
                  SizedBox(height: 4.h),
                  // Ряд с ценой и кнопкой избранного
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Разносит элементы по краям
                    children: [
                      // Цена (передаем значение в локализованную строку)
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: AppTextStyles.price.copyWith(color: AppColors.primary),
                      ),
                      // ValueListenableBuilder слушает наш ValueNotifier
                      // Когда список избранного меняется, перерисовывается ТОЛЬКО эта кнопка, а не весь экран
                      ValueListenableBuilder<List<int>>(
                        valueListenable: favoriteIdsNotifier,
                        builder: (context, favorites, child) {
                          final isFav = favorites.contains(product.id); // Проверяем, есть ли товар в избранном
                          return GestureDetector(
                            onTap: () => toggleFavorite(product.id),    // Добавляем/удаляем по клику
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? AppColors.error : AppColors.textSecondaryLight,
                              size: 24.w,
                            ),
                          );
                        },
                      ),
                    ],
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
