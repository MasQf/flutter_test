import 'package:test/api/api.dart';
import 'package:test/models/favorite.dart';
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
  static Future<List<ItemModel>> latestList(
      {int page = 1, int size = 10}) async {
    try {
      final response = await Api().post('/latest_items', data: {
        'page': page,
        'size': size,
      });

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

  // 收藏
  static Future<bool> favorite({required String itemId}) async {
    try {
      final response = await Api().post('/favorite', data: {
        'itemId': itemId,
      });

      bool status = response.data['status'];

      return status;
    } catch (e) {
      throw Exception("Error favorite: $e");
    }
  }

  // 取消收藏
  static Future<bool> unFavorite({required String itemId}) async {
    try {
      final response = await Api().post('/unFavorite', data: {
        'itemId': itemId,
      });

      bool status = response.data['status'];

      return status;
    } catch (e) {
      throw Exception("Error unFavorite: $e");
    }
  }

  /// 收藏列表
  static Future<List<FavoriteModel>> favoriteList(
      {int page = 1, int size = 10}) async {
    try {
      final response = await Api().post('/favorites', data: {
        'page': page,
        'size': size,
      });

      List<dynamic> itemListJson = response.data['favorites'];
      List<FavoriteModel> itemList =
          itemListJson.map((json) => FavoriteModel.fromJson(json)).toList();

      return itemList;
    } catch (e) {
      throw Exception("Error get favorite list: $e");
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

  // 删除物品
  static Future<void> delete({required String itemId}) async {
    try {
      await Api().post('/delete', data: {"itemId": itemId});
    } catch (e) {
      throw Exception("Error delete item: $e");
    }
  }

  // 搜索
  static Future<List<ItemModel>> search({required String keyword}) async {
    try {
      final response = await Api().post('/search', data: {"keyword": keyword});
      List<dynamic> itemListJson = response.data['items'];
      List<ItemModel> itemList =
          itemListJson.map((json) => ItemModel.fromJson(json)).toList();

      return itemList;
    } catch (e) {
      throw Exception("Error delete item: $e");
    }
  }

  /// 获取最多收藏的物品列表(分页查询)
  static Future<List<ItemModel>> mostFavoritesItems(
      {int page = 1, int size = 3}) async {
    try {
      final response = await Api().post('/most_favorites_items', data: {
        'page': page,
        'size': size,
      });

      List<dynamic> itemListJson = response.data['items'];
      List<ItemModel> itemList =
          itemListJson.map((json) => ItemModel.fromJson(json)).toList();

      return itemList;
    } catch (e) {
      throw Exception("Error get most favorites items: $e");
    }
  }

  /// 获取最多浏览的物品列表(分页查询)
  static Future<List<ItemModel>> mostViewsItems(
      {int page = 1, int size = 3}) async {
    try {
      final response = await Api().post('/most_views_items', data: {
        'page': page,
        'size': size,
      });

      List<dynamic> itemListJson = response.data['items'];
      List<ItemModel> itemList =
          itemListJson.map((json) => ItemModel.fromJson(json)).toList();

      return itemList;
    } catch (e) {
      throw Exception("Error get most views items: $e");
    }
  }
}
