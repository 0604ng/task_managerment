// lib/data/datasources/task_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Stream<List<TaskModel>> getTasks(String userId);
  Stream<List<TaskModel>> getTasksByCategory(String userId, String categoryId);

  Future<void> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSourceImpl(this.firestore);

  CollectionReference get tasksRef =>
      firestore.collection("tasks");

  @override
  Stream<List<TaskModel>> getTasks(String userId) {
    return tasksRef
        .where("userId", isEqualTo: userId)
        .orderBy("dueDate")
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TaskModel.fromDoc(doc)).toList());
  }

  @override
  Stream<List<TaskModel>> getTasksByCategory(
      String userId, String categoryId) {
    return tasksRef
        .where("userId", isEqualTo: userId)
        .where("categoryId", isEqualTo: categoryId)
        .orderBy("dueDate")
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TaskModel.fromDoc(doc)).toList());
  }

  @override
  Future<void> createTask(TaskModel task) async {
    await tasksRef.add(task.toMap());
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await tasksRef.doc(task.id).update(task.toMap());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await tasksRef.doc(taskId).delete();
  }
}
