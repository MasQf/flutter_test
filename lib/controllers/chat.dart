import 'package:get/get.dart';
import 'package:test/api/chat.dart';
import 'package:test/models/message.dart';

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

  // 更新单个聊天的最后消息
  void updateLastMessage(String roomId, MessageModel message) {
    final index = chatList.indexWhere((chat) => chat.roomId == roomId);
    if (index != -1) {
      chatList[index].lastMessage = message;
      chatList[index].unreadCount[message.receiverId] =
          (chatList[index].unreadCount[message.receiverId] ?? 0) + 1;

      // 将最新消息的聊天移到顶部
      if (index != 0) {
        final chat = chatList.removeAt(index);
        chatList.insert(0, chat);
      }
    }
  }
}
