import 'package:get/get.dart';
import 'package:test/api/publish.dart';

class PublishController extends GetxController {
  var publishList = [].obs;

  // 获取已发布列表
  Future<void> loadPublishList({required String userId}) async {
    try {
      final itemList = await PublishApi.list(userId: userId);
      publishList.assignAll(itemList);
    } catch (e) {
      print("Error Load published List: $e");
    }
  }
}
