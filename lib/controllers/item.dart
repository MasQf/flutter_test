import 'package:get/get.dart';
import 'package:test/api/item.dart';

class ItemController extends GetxController {
  var latestList = [].obs;

  // 获取最近商品列表
  Future<void> loadLatestList() async {
    try {
      final itemList = await ItemApi.latestList();
      latestList.assignAll(itemList);
    } catch (e) {
      print("Error Load published List: $e");
    }
  }
}
