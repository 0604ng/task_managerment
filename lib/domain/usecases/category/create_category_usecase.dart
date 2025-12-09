// lib/domain/usecases/category/create_category_usecase.dart
import '../../repositories/category_repository.dart';
import '../../entity/category_entity.dart';

class CreateCategoryUseCase {
  final CategoryRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<void> call(CategoryEntity entity) {
    return repository.createCategory(entity);
  }
}
