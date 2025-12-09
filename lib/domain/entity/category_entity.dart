// lib/domain/entity/category_entity.dart
import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final int colorHex;
  final String userId;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, name, colorHex, userId];

  CategoryEntity copyWith({
    String? id,
    String? name,
    int? colorHex,
    String? userId,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      userId: userId ?? this.userId,
    );
  }
}
