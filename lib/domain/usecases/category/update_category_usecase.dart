// lib/domain/usecases/category/update_category_usecase.dart
import '../../repositories/category_repository.dart';
import '../../entity/category_entity.dart';

class UpdateCategoryUseCase {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<void> call(CategoryEntity entity) {
    return repository.updateCategory(entity);
  }
}
