import '../../repositories/category_repository.dart';
import '../../entity/category_entity.dart';

class GetCategoriesByUserUseCase {
  final CategoryRepository repository;

  GetCategoriesByUserUseCase(this.repository);

  Stream<List<CategoryEntity>> call(String userId) {
    return repository.getCategoriesByUserId(userId);
  }
}
