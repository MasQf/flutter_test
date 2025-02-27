import 'package:test/models/item.dart';

class FavoriteModel {
  final String id;
  final String userId;
  final DateTime createdAt;
  final ItemModel item;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.item,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['_id'],
      userId: json['userId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      item: ItemModel.fromJson(json['item']),
    );
  }
}
