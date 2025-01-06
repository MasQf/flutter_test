import 'package:flutter/material.dart';
import 'package:test/services/socket.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final SocketService _socketService = SocketService();
  final TextEditingController _messageController = TextEditingController();

  String _roomId = "room123"; // 示例房间 ID
  String _senderId = "user1"; // 示例用户 ID
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // 连接到 Socket.IO 服务器
    _socketService.connect('http://10.0.2.2:3000');
    // 加入房间
    _socketService.joinRoom(_roomId);
    // 监听接收消息
    _socketService.onMessageReceived((message) {
      setState(() {
        _messages.add(message);
      });
    });
  }

  @override
  void dispose() {
    print('dispose...');
    _socketService.disconnect();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty && mounted) {
      _socketService.sendMessage(_roomId, _senderId, content, 'text');
      // setState(() {
      //   _messages.add({
      //     'roomId': _roomId,
      //     'senderId': _senderId,
      //     'content': content,
      //     'type': 'text',
      //   });
      // });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['senderId'] == _senderId;
                return ListTile(
                  title: Text(
                    message['content'],
                    textAlign: isMe ? TextAlign.end : TextAlign.start,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
