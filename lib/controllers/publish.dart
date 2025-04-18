import 'package:get/get.dart';
import 'package:test/api/item.dart';
import 'package:test/api/publish.dart';
import 'package:test/models/item.dart';

class PublishController extends GetxController {
  var publishList = <ItemModel>[].obs;

  // 获取已发布列表
  Future<void> loadPublishList({required String userId}) async {
    try {
      final itemList = await PublishApi.publishList(userId: userId);
      publishList.assignAll(itemList);
    } catch (e) {
      print("Error Load published List: $e");
    }
  }

  // 删除指定项
  Future<void> deleteItem({required String itemId}) async {
    try {
      await ItemApi.delete(itemId: itemId);

      // 从列表中移除
      publishList.removeWhere((item) => item.id == itemId);
    } catch (e) {
      print("Error deleting item: $e");
    }
  }
}
