class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String receiverId;
  final String content;
  final String type;
  final String time;

  MessageModel({
    this.id = '',
    required this.roomId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    this.time = '',
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      roomId: json['roomId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      type: json['type'],
      time: json['time'],
    );
  }
}
