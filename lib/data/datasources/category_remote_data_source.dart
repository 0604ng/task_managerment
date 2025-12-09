// lib/data/datasources/category_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Stream<List<CategoryModel>> getCategories(String userId);

  Future<void> createCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);

  Future<void> reassignTasksToDefault(String deletedCategoryId, String defaultCategoryId) async {}
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore firestore;

  CategoryRemoteDataSourceImpl(this.firestore);

  CollectionReference get categoryRef =>
      firestore.collection("categories");

  @override
  Stream<List<CategoryModel>> getCategories(String userId) {
    return categoryRef
        .where("userId", isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CategoryModel.fromDoc(doc)).toList());
  }

  @override
  Future<void> createCategory(CategoryModel category) {
    return categoryRef.add(category.toMap());
  }

  @override
  Future<void> updateCategory(CategoryModel category) {
    return categoryRef.doc(category.id).update(category.toMap());
  }

  @override
  Future<void> deleteCategory(String categoryId) {
    return categoryRef.doc(categoryId).delete();
  }

  @override
  Future<void> reassignTasksToDefault(String deletedCategoryId, String defaultCategoryId) {
    // TODO: implement reassignTasksToDefault
    throw UnimplementedError();
  }
}
