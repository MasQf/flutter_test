class ChatItem {
  final String id;
  final String name;
  final String lastMessage;
  final String avatar;
  final DateTime lastMessageTime;

  ChatItem({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.avatar,
    required this.lastMessageTime,
  });
}

class Message {
  final String senderId;
  final String content;
  final String type; // text, image, video
  final DateTime time;

  Message({
    required this.senderId,
    required this.content,
    required this.type,
    required this.time,
  });
}
