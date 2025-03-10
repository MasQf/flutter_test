import 'package:get/get.dart';
import 'package:test/api/item.dart';

class ItemController extends GetxController {
  var latestList = [].obs;
  var favoriteList = [].obs;

  // 获取最近商品列表
  Future<void> loadLatestList() async {
    try {
      final itemList = await ItemApi.latestList();
      latestList.assignAll(itemList);
    } catch (e) {
      print("Error Load published List: $e");
    }
  }

  // 获取收藏列表
  Future<void> loadFavoriteList() async {
    try {
      final itemList = await ItemApi.favoriteList();
      favoriteList.assignAll(itemList);
    } catch (e) {
      print("Error Load Favorite List: $e");
    }
  }

  // 检查收藏列表中是否有至少一个项的 isSelected 为 true
  bool hasSelectedFavorites() {
    return favoriteList.any((item) => item.item.isSelected);
  }

  Future<void> removeSelectedFavorites() async {
    try {
      // 找到所有 isSelected 为 true 的 item
      var selectedItems =
          favoriteList.where((item) => item.item.isSelected).toList();

      // 并行删除所有选中的收藏项
      await Future.wait(selectedItems
          .map((item) => ItemApi.unFavorite(itemId: item.item.id)));

      // 从 favoriteList 中移除这些项
      favoriteList.removeWhere((item) => item.item.isSelected);
    } catch (e) {
      print("Error removing selected favorites: $e");
    }
  }
}
