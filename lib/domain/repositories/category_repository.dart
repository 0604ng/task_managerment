import '../entity/category_entity.dart';

abstract class CategoryRepository {
  Stream<List<CategoryEntity>> getCategories(String userId);
  Stream<List<CategoryEntity>> getCategoriesByUserId(String userId);
  Future<void> createCategory(CategoryEntity category);

  Future<void> updateCategory(CategoryEntity category);

  Future<void> deleteCategory(String categoryId);

  Future<void> reassignTasksToDefault(
      String deletedCategoryId, String defaultCategoryId);
}
