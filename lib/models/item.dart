import 'package:test/models/user.dart';

class ItemModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final List<String> images;
  final bool status;
  final String location;
  final int views;
  final int favoritesCount;
  final bool isNegotiable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel owner;

  ItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.images,
    required this.status,
    required this.location,
    required this.views,
    required this.favoritesCount,
    required this.isNegotiable,
    required this.createdAt,
    required this.updatedAt,
    required this.owner,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['_id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      category: json['category'],
      images: List<String>.from(json['images']),
      status: json['status'],
      location: json['location'] ?? '',
      views: json['views'],
      favoritesCount: json['favoritesCount'],
      isNegotiable: json['isNegotiable'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      owner: UserModel.fromJson(json['owner']),
    );
  }
}
