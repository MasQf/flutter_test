import 'package:test/models/user.dart';

class TradeModel {
  final String id;
  final String sellerId;
  final String location;
  final String tradeTime;
  final String status;
  final List<dynamic> images;
  final String name;
  final double price;
  final UserModel? buyer;
  final UserModel? seller;

  TradeModel({
    this.id = '',
    required this.sellerId,
    required this.location,
    this.tradeTime = '',
    this.status = 'Pending',
    required this.images,
    required this.name,
    required this.price,
    this.buyer,
    this.seller,
  });

  factory TradeModel.fromJson(Map<String, dynamic> json) {
    final item = json['item'] ?? {};
    return TradeModel(
      id: json['_id'] ?? '',
      sellerId: json['sellerId'] ?? '',
      location: json['location'] ?? '',
      tradeTime: json['tradeTime'] ?? '',
      status: json['status'] ?? 'Pending',
      images: item['images'] ?? [],
      name: item['name'] ?? '',
      price: (item['price'] ?? 0).toDouble(),
      buyer: json['buyer'] != null ? UserModel.fromJson(json['buyer']) : null,
      seller:
          json['seller'] != null ? UserModel.fromJson(json['seller']) : null,
    );
  }
}
