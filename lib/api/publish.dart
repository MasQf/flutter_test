import 'package:test/api/api.dart';
import 'package:test/models/item.dart';

class PublishApi {
  /// 用户已发布的商品列表
  static Future<List<ItemModel>> publishList({required String userId}) async {
    try {
      final response = await Api().post('/published_items', data: {"userId": userId});

      List<dynamic> itemListJson = response.data['items'];
      List<ItemModel> itemList = itemListJson.map((json) => ItemModel.fromJson(json)).toList();

      return itemList;
    } catch (e) {
      throw Exception("Error get publish list: $e");
    }
  }

  /// 发布
  static Future<bool> publish({
    required String name,
    required double price,
    required String description,
    required String category,
    required List<String> images,
    required String ownerId,
    required bool status,
    required String location,
    required bool isNegotiable,
  }) async {
    try {
      final response = await Api().post('/publish', data: {
        "name": name,
        "price": price,
        "description": description,
        "category": category,
        "images": images,
        "ownerId": ownerId,
        "status": status,
        "location": location,
        "isNegotiable": isNegotiable
      });

      bool publishStatus = response.data['status'];

      return publishStatus;
    } catch (e) {
      throw Exception("Error get publish list: $e");
    }
  }
}
