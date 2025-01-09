import 'package:test/models/message.dart';
import 'package:test/models/user.dart';

class ChatModel {
  final String id;
  final String roomId;
  final List<String> participants;
  final MessageModel lastMessage;
  final int unreadCount;
  final UserModel targetUser;

  ChatModel({
    required this.id,
    required this.roomId,
    required this.participants,
    required this.lastMessage,
    required this.unreadCount,
    required this.targetUser,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['_id'],
      roomId: json['roomId'],
      participants: List<String>.from(json['participants']),
      lastMessage: MessageModel.fromJson(json['lastMessage']), // 填充 lastMessage
      unreadCount: json['unreadCount'],
      targetUser: UserModel.fromJson(json['targetUser']),
    );
  }
}
