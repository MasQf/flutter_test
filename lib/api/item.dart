import 'package:test/api/api.dart';
import 'package:test/models/item.dart';

class ItemApi {
  static Future<ItemModel> item({required String itemId}) async {
    try {
      final response = await Api().post('/item_detail', data: {
        'itemId': itemId,
      });

      Map<String, dynamic> itemJson = response.data['item'];
      ItemModel item = ItemModel.fromJson(itemJson);

      return item;
    } catch (e) {
      throw Exception("Error get item: $e");
    }
  }

  /// 最近发布列表
  static Future<List<ItemModel>> latestList() async {
    try {
      final response = await Api().get('/latest_items');

      List<dynamic> itemListJson = response.data['items'];
      List<ItemModel> itemList =
          itemListJson.map((json) => ItemModel.fromJson(json)).toList();

      return itemList;
    } catch (e) {
      throw Exception("Error get latest list: $e");
    }
  }

  /// 排行榜
  static Future<Map<String, dynamic>> rankingList() async {
    try {
      final response = await Api().get('/ranking_list');

      Map<String, dynamic> data = response.data;

      return data;
    } catch (e) {
      throw Exception("Error get ranking list: $e");
    }
  }

  // 浏览数+1
  static Future<void> view({required String itemId}) async {
    try {
      await Api().post('/view', data: {"itemId": itemId});
    } catch (e) {
      throw Exception("Error views+1: $e");
    }
  }
}
