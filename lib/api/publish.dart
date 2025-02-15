import 'package:test/api/api.dart';
import 'package:test/models/item.dart';

class PublishApi {
  /// 用户已发布的商品列表
  static Future<List<ItemModel>> publishList({required String userId}) async {
    try {
      final response =
          await Api().post('/published_items', data: {"userId": userId});

      List<dynamic> itemListJson = response.data['items'];
      List<ItemModel> itemList =
          itemListJson.map((json) => ItemModel.fromJson(json)).toList();

      return itemList;
    } catch (e) {
      throw Exception("Error get publish list: $e");
    }
  }
}
