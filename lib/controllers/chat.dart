import 'package:get/get.dart';
import 'package:test/api/chat.dart';

class ChatController extends GetxController {
  RxList chatList = [].obs;

  // 获取聊天列表
  Future<void> loadChatList({required String userId}) async {
    try {
      final newChatList = await ChatApi.contactList(userId: userId);
      chatList.assignAll(newChatList);
    } catch (e) {
      print("Error Load Chat List: $e");
    }
  }
}
