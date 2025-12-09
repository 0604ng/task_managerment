import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/task_entity.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime dueDate;
  final String categoryId;
  final String userId;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.dueDate,
    required this.categoryId,
    required this.userId,
  });

  TaskEntity toEntity() => TaskEntity(
    id: id,
    title: title,
    description: description,
    isCompleted: isCompleted,
    dueDate: dueDate,
    categoryId: categoryId,
    userId: userId,
  );

  static TaskModel fromEntity(TaskEntity e) => TaskModel(
    id: e.id,
    title: e.title,
    description: e.description,
    isCompleted: e.isCompleted,
    dueDate: e.dueDate,
    categoryId: e.categoryId,
    userId: e.userId,
  );

  factory TaskModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TaskModel(
      id: data['id'] ?? doc.id,
      title: data['title'],
      description: data['description'],
      isCompleted: data['isCompleted'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      categoryId: data['categoryId'],
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'dueDate': Timestamp.fromDate(dueDate),
    'categoryId': categoryId,
    'userId': userId,
  };
}
