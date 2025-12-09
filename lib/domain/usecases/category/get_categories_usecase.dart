// lib/domain/usecases/category/get_categories_usecase.dart
import '../../repositories/category_repository.dart';
import '../../entity/category_entity.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Stream<List<CategoryEntity>> call(String userId) {
    return repository.getCategories(userId);
  }
}
