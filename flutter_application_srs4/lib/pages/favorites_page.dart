import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/models/product.dart';
import '../generated/locale_keys.g.dart';

// ==================== СТРАНИЦА ИЗБРАННОГО ====================
// Здесь отображаются только те товары, которые были добавлены в избранное
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.favorites.tr()),
        centerTitle: true,
      ),
      // ValueListenableBuilder слушает изменение глобального списка избранного
      // Как только мы нажмем "Сердечко" на экране каталога, этот экран тоже обновится
      body: ValueListenableBuilder<List<int>>(
        valueListenable: favoriteIdsNotifier,
        builder: (context, favoriteIds, child) {
          // Если список пуст, показываем сообщение
          if (favoriteIds.isEmpty) {
            return Center(
              child: Text(
                "Нет избранных товаров",
                style: AppTextStyles.body,
              ),
            );
          }

          // Фильтруем все товары, оставляя только те, чей ID есть в списке favoriteIds
          final favoriteProducts = mockProducts.where((p) => favoriteIds.contains(p.id)).toList();

          // ListView.separated создает список элементов с разделителями между ними
          return ListView.separated(
            padding: EdgeInsets.all(16.w),                 // Адаптивные отступы
            itemCount: favoriteProducts.length,            // Количество элементов
            separatorBuilder: (context, index) => SizedBox(height: 16.h), // Разделитель (просто пустое пространство)
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];     // Текущий товар
              return _buildFavoriteItem(context, product);
            },
          );
        },
      ),
    );
  }

  // Метод для создания элемента списка избранного
  Widget _buildFavoriteItem(BuildContext context, Product product) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Картинка товара (квадратная, с закругленными углами)
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.asset(
              product.imageUrl,
              width: 80.w,
              height: 80.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(width: 80.w, height: 80.w, color: Colors.grey[300]),
            ),
          ),
          SizedBox(width: 16.w),
          // Описание товара
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: AppTextStyles.price.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          // Кнопка удаления из избранного (вызывает ту же функцию)
          IconButton(
            icon: Icon(Icons.favorite, color: AppColors.error, size: 28.w),
            onPressed: () => toggleFavorite(product.id),
          ),
        ],
      ),
    );
  }
}
