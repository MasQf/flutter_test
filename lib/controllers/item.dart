import 'package:get/get.dart';
import 'package:test/api/item.dart';
import 'package:test/models/item.dart';

class ItemController extends GetxController {
  var latestList = [].obs;
  var favoriteList = [].obs;
  var viewRankingList = <ItemModel>[].obs;
  var favoriteRankingList = <ItemModel>[].obs;
  var fullLatestList = <ItemModel>[].obs;
  var fullFavoriteRankingList = <ItemModel>[].obs;
  var fullViewRankingList = <ItemModel>[].obs;

  // 获取最近商品列表
  Future<void> loadLatestList() async {
    try {
      final itemList = await ItemApi.latestList();
      latestList.assignAll(itemList);
    } catch (e) {
      print("Error Load published List: $e");
    }
  }

  // 获取完整最近发布列表（懒加载）
  Future<void> loadFullLatestList({int page = 1, int size = 3}) async {
    try {
      if (page == 1) {
        fullLatestList.clear();
      }
      final itemList = await ItemApi.latestList(page: page, size: size);

      if (itemList.isEmpty) {
        print("警告: 服务器返回空数据");
      }

      // 防止重复添加相同数据
      if (page > 1) {
        // 过滤已存在的项目
        final existingIds = fullLatestList.map((item) => item.id).toSet();
        final newItems =
            itemList.where((item) => !existingIds.contains(item.id)).toList();
        if (newItems.length < itemList.length) {
          print("过滤掉了${itemList.length - newItems.length}个重复项目");
        }
        fullLatestList.addAll(newItems);
      } else {
        fullLatestList.addAll(itemList);
      }

      print("当前列表总项目数: ${fullLatestList.length}");
    } catch (e) {
      print("Error Load Full Latest List: $e");
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

  // 加载排行榜完整列表
  Future<void> loadRankingLists() async {
    try {
      final rankingMap = await ItemApi.rankingList();
      favoriteRankingList.value =
          (rankingMap['favoritesItems'] as List<dynamic>?)
                  ?.map((json) => ItemModel.fromJson(json))
                  .toList() ??
              [];
      viewRankingList.value = (rankingMap['viewsItems'] as List<dynamic>?)
              ?.map((json) => ItemModel.fromJson(json))
              .toList() ??
          [];
    } catch (e) {
      print("Error Load Ranking Lists: $e");
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

  // 获取完整收藏榜单列表（懒加载）
  Future<void> loadFullFavoriteRankingList({int page = 1, int size = 3}) async {
    try {
      if (page == 1) {
        fullFavoriteRankingList.clear();
      }
      final itemList = await ItemApi.mostFavoritesItems(page: page, size: size);

      if (itemList.isEmpty) {
        print("警告: 服务器返回空数据");
      }

      // 防止重复添加相同数据
      if (page > 1) {
        // 过滤已存在的项目
        final existingIds =
            fullFavoriteRankingList.map((item) => item.id).toSet();
        final newItems =
            itemList.where((item) => !existingIds.contains(item.id)).toList();
        if (newItems.length < itemList.length) {
          print("过滤掉了${itemList.length - newItems.length}个重复收藏榜单项目");
        }
        fullFavoriteRankingList.addAll(newItems);
      } else {
        fullFavoriteRankingList.addAll(itemList);
      }

      print("当前收藏榜单总项目数: ${fullFavoriteRankingList.length}");
    } catch (e) {
      print("Error Load Full Favorite Ranking List: $e");
    }
  }

  // 获取完整浏览榜单列表（懒加载）
  Future<void> loadFullViewRankingList({int page = 1, int size = 3}) async {
    try {
      if (page == 1) {
        fullViewRankingList.clear();
      }
      final itemList = await ItemApi.mostViewsItems(page: page, size: size);

      if (itemList.isEmpty) {
        print("警告: 服务器返回空数据");
      }

      // 防止重复添加相同数据
      if (page > 1) {
        // 过滤已存在的项目
        final existingIds = fullViewRankingList.map((item) => item.id).toSet();
        final newItems =
            itemList.where((item) => !existingIds.contains(item.id)).toList();
        if (newItems.length < itemList.length) {
          print("过滤掉了${itemList.length - newItems.length}个重复浏览榜单项目");
        }
        fullViewRankingList.addAll(newItems);
      } else {
        fullViewRankingList.addAll(itemList);
      }

      print("当前浏览榜单总项目数: ${fullViewRankingList.length}");
    } catch (e) {
      print("Error Load Full View Ranking List: $e");
    }
  }
}
