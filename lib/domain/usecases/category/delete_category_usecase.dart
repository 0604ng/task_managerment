// lib/domain/usecases/category/delete_category_usecase.dart
import '../../repositories/category_repository.dart';

class DeleteCategoryUseCase {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<void> call(String categoryId) {
    return repository.deleteCategory(categoryId);
  }
}
