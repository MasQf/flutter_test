import 'package:test/api/api.dart';
import 'package:test/models/trade.dart';

class TradeApi {
  static Future<void> createTrade({
    required String sellerId,
    required String buyerId,
    required String itemId,
    required String location,
    required String tradeTime,
  }) async {
    try {
      // sellerId, buyerId, itemId, location, tradeTime
      await Api().post('/create_trade', data: {
        "sellerId": sellerId,
        "buyerId": buyerId,
        "itemId": itemId,
        "location": location,
        "tradeTime": tradeTime,
      });
    } catch (e) {
      throw Exception("Error get sellList: $e");
    }
  }

  static Future<List<TradeModel>> sellList({required String sellerId, String? status}) async {
    try {
      final response = await Api().post('/sell_list', data: {"sellerId": sellerId, "status": status ?? ''});

      List<dynamic> tradesListJson = response.data['trades'];
      List<TradeModel> sellList = tradesListJson.map((json) => TradeModel.fromJson(json)).toList();

      return sellList;
    } catch (e) {
      throw Exception("Error get sellList: $e");
    }
  }

  static Future<List<TradeModel>> buyList({required String buyerId, String? status}) async {
    try {
      final response = await Api().post('/buy_list', data: {"buyerId": buyerId, "status": status ?? ''});

      List<dynamic> tradesListJson = response.data['trades'];
      List<TradeModel> buyList = tradesListJson.map((json) => TradeModel.fromJson(json)).toList();

      return buyList;
    } catch (e) {
      throw Exception("Error get buyList: $e");
    }
  }

  static Future<void> updateStatus({required String tradeId, required String status}) async {
    try {
      await Api().post('/update_trade_status', data: {"tradeId": tradeId, "status": status});
    } catch (e) {
      throw Exception("Error update status: $e");
    }
  }
}
