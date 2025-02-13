import 'package:test/api/api.dart';
import 'package:test/models/item.dart';

class ItemApi {
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

  /// 最近发布列表
  static Future<List<ItemModel>> latestList() async {
    try {
      final response = await Api().get('/recent_items');

      List<dynamic> itemListJson = response.data['items'];
      List<ItemModel> itemList =
          itemListJson.map((json) => ItemModel.fromJson(json)).toList();

      return itemList;
    } catch (e) {
      throw Exception("Error get latest list: $e");
    }
  }
}
