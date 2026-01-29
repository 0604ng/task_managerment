import 'dart:async';
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
  final ReassignTasksUseCase reassignTasksUseCase;
  final DeleteTasksByCategoryUseCase deleteTasksByCategoryUseCase;

  StreamSubscription<List<CategoryEntity>>? _subscription;

  CategoryBloc({
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.getCategoriesByUserUseCase,
    required this.reassignTasksUseCase,
    required this.deleteTasksByCategoryUseCase,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);

    on<AddCategoryEvent>((event, emit) async {
      await createCategoryUseCase(event.category);
    });

    on<UpdateCategoryEvent>((event, emit) async {
      await updateCategoryUseCase(event.category);
    });

    on<DeleteCategoryEvent>((event, emit) async {
      try {
        if (event.reassignToCategoryId != null) {
          await reassignTasksUseCase(
            oldCategoryId: event.categoryId,
            newCategoryId: event.reassignToCategoryId!,
          );
        } else {
          await deleteTasksByCategoryUseCase(event.categoryId);
        }

        await deleteCategoryUseCase(event.categoryId);
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });
  }

  Future<void> _onLoadCategories(
      LoadCategories event,
      Emitter<CategoryState> emit,
      ) async {
    emit(CategoryLoading());
    await _subscription?.cancel();

    try {
      _subscription = getCategoriesByUserUseCase(event.userId).listen(
            (categories) {
          emit(CategoryLoaded(categories));
        },
        onError: (e) {
          emit(CategoryError(e.toString()));
        },
      );
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
