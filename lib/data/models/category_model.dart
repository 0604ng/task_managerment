// lib/data/models/category_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entity/category_entity.dart';

class CategoryModel {
  final String id;
  final String name;
  final int colorHex;
  final String userId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.userId,
  });

  // Model → Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      colorHex: colorHex,
      userId: userId,
    );
  }

  // Entity → Model
  static CategoryModel fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      colorHex: entity.colorHex,
      userId: entity.userId,
    );
  }

  // Firestore → Model
  factory CategoryModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return CategoryModel(
      id: doc.id,
      name: data?['name'] ?? '',
      colorHex: data?['colorHex'] ?? 0xFF2196F3,
      userId: data?['userId'] ?? '',
    );
  }

  // Model → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
      'userId': userId,
    };
  }
}
