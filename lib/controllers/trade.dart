import 'package:get/get.dart';
import 'package:test/api/trade.dart';
import 'package:test/models/trade.dart';

class TradeController extends GetxController {
  var sellList = <TradeModel>[].obs;
  var buyList = <TradeModel>[].obs;

  // 获取卖出列表
  Future<void> loadSellList({required String sellerId, String status = ''}) async {
    try {
      final itemList = await TradeApi.sellList(sellerId: sellerId, status: status);
      sellList.assignAll(itemList);
    } catch (e) {
      print("Error Load sell List: $e");
    }
  }

  // 获取卖出列表
  Future<void> loadBuyList({required String buyerId, String status = ''}) async {
    try {
      final itemList = await TradeApi.buyList(buyerId: buyerId, status: status);
      buyList.assignAll(itemList);
    } catch (e) {
      print("Error Load buy List: $e");
    }
  }
}
