import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Stream<List<TaskModel>> getTasks(String userId);
  Stream<List<TaskModel>> getTasksByCategory(String userId, String categoryId);

  Future<void> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);

  Future<void> deleteTask(String taskId);
  Future<void> deleteTasksByCategory(String categoryId);

  Future<void> reassignTasksToAnotherCategory(
      String oldCategoryId,
      String newCategoryId,
      );
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  TaskRemoteDataSourceImpl(this.firestore, this.auth);

  String get _uid => auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _tasksRef =>
      firestore
          .collection('users')
          .doc(_uid)
          .collection('tasks');

  @override
  Stream<List<TaskModel>> getTasks(String userId) {
    return _tasksRef
        .orderBy('dueDate')
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map((doc) => TaskModel.fromDoc(doc)).toList(),
    );
  }

  @override
  Stream<List<TaskModel>> getTasksByCategory(
      String userId,
      String categoryId,
      ) {
    return _tasksRef
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('dueDate')
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map((doc) => TaskModel.fromDoc(doc)).toList(),
    );
  }

  @override
  Future<void> createTask(TaskModel task) async {
    await _tasksRef
        .doc(task.id)
        .set(task.toMap());
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _tasksRef
        .doc(task.id)
        .update(task.toMap());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }

  @override
  Future<void> deleteTasksByCategory(String categoryId) async {
    final query = await _tasksRef
        .where('categoryId', isEqualTo: categoryId)
        .get();

    for (final doc in query.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<void> reassignTasksToAnotherCategory(
      String oldCategoryId,
      String newCategoryId,
      ) async {
    final query = await _tasksRef
        .where('categoryId', isEqualTo: oldCategoryId)
        .get();

    for (final doc in query.docs) {
      await doc.reference.update({
        'categoryId': newCategoryId,
      });
    }
  }
}
