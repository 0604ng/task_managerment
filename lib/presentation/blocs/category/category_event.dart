// lib/presentation/blocs/category/category_event.dart

import '../../../domain/entity/category_entity.dart';

abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {
  final String userId;
  LoadCategories(this.userId);
}

class AddCategoryEvent extends CategoryEvent {
  final CategoryEntity category;
  AddCategoryEvent(this.category);
}

class UpdateCategoryEvent extends CategoryEvent {
  final CategoryEntity category;
  UpdateCategoryEvent(this.category);
}

class DeleteCategoryEvent extends CategoryEvent {
  final String categoryId;
  final String? reassignToCategoryId;
  // null = DELETE all tasks
  // not null = move tasks to this category

  DeleteCategoryEvent(this.categoryId, {this.reassignToCategoryId});
}
