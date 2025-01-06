import 'package:flutter/material.dart';
import 'package:test/models/chat.dart';
import 'package:test/pages/chat_detail.dart';

class ChatListPage extends StatelessWidget {
  final List<ChatItem> chatItems = [
    ChatItem(
      id: '1',
      name: 'Alice',
      lastMessage: 'Hi, how are you?',
      avatar: 'https://via.placeholder.com/150',
      lastMessageTime: DateTime.now(),
    ),
    ChatItem(
      id: '2',
      name: 'Bob',
      lastMessage: 'Check this out!',
      avatar: 'https://via.placeholder.com/150',
      lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat List')),
      body: ListView.builder(
        itemCount: chatItems.length,
        itemBuilder: (context, index) {
          final chat = chatItems[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(chat.avatar),
            ),
            title: Text(chat.name),
            subtitle: Text(chat.lastMessage),
            trailing: Text(
              '${chat.lastMessageTime.hour}:${chat.lastMessageTime.minute}',
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatDetailPage(chatId: chat.id, chatName: chat.name),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
