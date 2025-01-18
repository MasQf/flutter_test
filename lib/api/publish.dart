import 'package:test/api/api.dart';
import 'package:test/models/item.dart';

class PublishApi {
  static Future<List<ItemModel>> list({required String userId}) async {
    try {
      final response =
          await Api().post('/items_by_user', data: {"userId": userId});

      List<dynamic> itemListJson = response.data['items'];
      List<ItemModel> itemList =
          itemListJson.map((json) => ItemModel.fromJson(json)).toList();

      return itemList;
    } catch (e) {
      throw Exception("Error get item list: $e");
    }
  }
}
