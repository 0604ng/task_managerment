// lib/data/repositories/category_repository_impl.dart
import 'package:task_manager/domain/entity/category_entity.dart';
import 'package:task_manager/domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<CategoryEntity>> getCategories(String userId) {
    return remoteDataSource.getCategories(userId).map(
          (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<void> createCategory(CategoryEntity entity) async {
    await remoteDataSource.createCategory(
      CategoryModel.fromEntity(entity),
    );
  }

  @override
  Future<void> updateCategory(CategoryEntity entity) async {
    await remoteDataSource.updateCategory(
      CategoryModel.fromEntity(entity),
    );
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await remoteDataSource.deleteCategory(categoryId);
  }

  @override
  Future<void> reassignTasksToDefault(String deletedCategoryId, String defaultCategoryId) async {
    await remoteDataSource.reassignTasksToDefault(deletedCategoryId, defaultCategoryId);
  }

  @override
  Stream<List<CategoryEntity>> getCategoriesByUserId(String userId) {
    // TODO: implement getCategoriesByUserId
    throw UnimplementedError();
  }
}