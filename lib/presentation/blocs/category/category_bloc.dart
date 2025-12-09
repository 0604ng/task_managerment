// lib/presentation/blocs/category/category_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entity/category_entity.dart';
import '../../../domain/usecases/category/create_category_usecase.dart';
import '../../../domain/usecases/category/update_category_usecase.dart';
import '../../../domain/usecases/category/delete_category_usecase.dart';
import '../../../domain/usecases/category/get_categories_by_user_usecase.dart';

import '../../../domain/usecases/task/reassign_tasks_usecase.dart';
import '../../../domain/usecases/task/delete_tasks_by_category_usecase.dart';

import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CreateCategoryUseCase createCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final GetCategoriesByUserUseCase getCategoriesByUserUseCase;

  // EXTRA usecases cho xử lý cascading:
  final ReassignTasksUseCase reassignTasksUseCase;
  final DeleteTasksByCategoryUseCase deleteTasksByCategoryUseCase;

  CategoryBloc({
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.getCategoriesByUserUseCase,
    required this.reassignTasksUseCase,
    required this.deleteTasksByCategoryUseCase,
  }) : super(CategoryInitial()) {

    /// LOAD CATEGORIES REALTIME
    on<LoadCategories>((event, emit) async {
      emit(CategoryLoading());

      await emit.forEach(
        getCategoriesByUserUseCase(event.userId),
        onData: (List<CategoryEntity> list) {
          return CategoryLoaded(list);
        },
        onError: (error, stack) => CategoryError(error.toString()),
      );
    });

    /// CREATE CATEGORY
    on<AddCategoryEvent>((event, emit) async {
      try {
        await createCategoryUseCase(event.category);
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    /// UPDATE CATEGORY
    on<UpdateCategoryEvent>((event, emit) async {
      try {
        await updateCategoryUseCase(event.category);
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    /// DELETE CATEGORY + HANDLE CASCADE
    on<DeleteCategoryEvent>((event, emit) async {
      try {
        // CASE 1 — REASSIGN TASKS TO ANOTHER CATEGORY
        if (event.reassignToCategoryId != null) {
          await reassignTasksUseCase(
            oldCategoryId: event.categoryId,
            newCategoryId: event.reassignToCategoryId!,
          );
        }
        // CASE 2 — DELETE ALL TASKS
        else {
          await deleteTasksByCategoryUseCase(event.categoryId);
        }

        // Finally delete category
        await deleteCategoryUseCase(event.categoryId);

      } catch (e) {
        emit(CategoryError("Delete failed: ${e.toString()}"));
      }
    });

  }
}
