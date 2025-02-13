import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:test/controllers/user.dart';
import 'package:test/models/message.dart';

class SocketService {
  late IO.Socket socket;

  final UserController userController = Get.find<UserController>();

  // 初始化 Socket.IO
  void connect(String serverUrl) {
    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({'userId': userController.id.value}) // 传递 userId
          .build(),
    );

    // 监听连接成功
    socket.onConnect((_) {
      print('Connected to server: $serverUrl');
    });

    // 监听连接断开
    socket.onDisconnect((_) {
      print('Disconnected from server');
    });

    // 开始连接
    socket.connect();
  }

  // 加入房间
  void joinRoom(String roomId) {
    socket.emit('joinRoom', roomId);
    print('Joined room: $roomId');
  }

  void leaveRoom(String roomId) {
    socket.emit('leaveRoom', roomId);
    print('Leave room: $roomId');
  }

  // 用户进入聊天详情页，通知服务器重置未读消息数
  void resetUnreadCount(String roomId, String userId) {
    socket.emit('resetUnreadCount', {'roomId': roomId, 'userId': userId});
    print('User $userId entered chat detail for room $roomId');
  }

  // 发送消息
  void sendMessage(MessageModel msg) {
    socket.emit('sendMessage', {
      'roomId': msg.roomId,
      'senderId': msg.senderId,
      'receiverId': msg.receiverId,
      'content': msg.content,
      'type': msg.type,
    });
  }

  // 接收消息
  void receiveMessage(Function(Map<String, dynamic>) callback) {
    socket.on('receiveMessage', (data) {
      callback(data);
    });
  }

  // 刷新消息
  void refreshChatList(Function(Map<String, dynamic>) callback) {
    socket.on('refreshChatList', (data) {
      callback(data);
    });
  }

  // 断开连接
  void disconnect() {
    socket.disconnect();
    print('Socket disconnected');
  }
}
