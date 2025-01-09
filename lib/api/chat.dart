import 'package:test/api/api.dart';
import 'package:test/models/chat.dart';
import 'package:test/models/message.dart';

class ChatApi {
  static Future<List<ChatModel>> contactList({required String userId}) async {
    try {
      final response = await Api().post('/chat_list', data: {"userId": userId});

      List<dynamic> contactListJson = response.data['chatList'];
      List<ChatModel> contacList =
          contactListJson.map((json) => ChatModel.fromJson(json)).toList();

      return contacList;
    } catch (e) {
      throw Exception("Error get contact list: $e");
    }
  }

  static Future<List<MessageModel>> detail({required String roomId}) async {
    try {
      final response =
          await Api().post('/chat_detail', data: {"roomId": roomId});

      List<dynamic> detailJson = response.data['messages'];
      List<MessageModel> detailList =
          detailJson.map((json) => MessageModel.fromJson(json)).toList();

      return detailList;
    } catch (e) {
      throw Exception("Error get chat list: $e");
    }
  }
}
