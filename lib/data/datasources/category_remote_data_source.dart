import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Stream<List<CategoryModel>> getCategories(String userId);

  Future<void> createCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);

  Future<void> reassignTasksToDefault(
      String deletedCategoryId,
      String defaultCategoryId,
      );
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CategoryRemoteDataSourceImpl(this.firestore, this.auth);

  String get _uid => auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _categoryRef =>
      firestore.collection('users').doc(_uid).collection('categories');

  CollectionReference<Map<String, dynamic>> get _tasksRef =>
      firestore.collection('users').doc(_uid).collection('tasks');

  @override
  Stream<List<CategoryModel>> getCategories(String userId) async* {
    final snapshot = await _categoryRef.get();

    if (snapshot.docs.isEmpty) {
      await _categoryRef.doc('default').set({
        'id': 'default',
        'name': 'Default',
        'colorHex': 0xFF9E9E9E,
        'userId': userId,
      });
    }

    yield* _categoryRef.snapshots().map(
          (snap) => snap.docs.map(CategoryModel.fromDoc).toList(),
    );
  }

  @override
  Future<void> createCategory(CategoryModel category) async {
    await _categoryRef.doc(category.id).set(category.toMap());
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await _categoryRef.doc(category.id).update(category.toMap());
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _categoryRef.doc(categoryId).delete();
  }

  @override
  Future<void> reassignTasksToDefault(
      String deletedCategoryId,
      String defaultCategoryId,
      ) async {
    final tasks = await _tasksRef
        .where('categoryId', isEqualTo: deletedCategoryId)
        .get();

    for (final doc in tasks.docs) {
      await doc.reference.update({
        'categoryId': defaultCategoryId,
      });
    }
  }
}
