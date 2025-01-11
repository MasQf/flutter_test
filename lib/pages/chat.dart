import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/chat.dart';
import 'package:test/constants/color.dart';
import 'package:test/controllers/chat.dart';
import 'package:test/controllers/user.dart';
import 'package:test/models/message.dart';
import 'package:test/services/socket.dart';
import 'package:test/widgets/chat_bubble.dart';
import 'package:test/widgets/glass_page.dart';

class ChatPage extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String targetName;
  final String targetAvatar;

  const ChatPage({
    required this.senderId,
    required this.receiverId,
    required this.targetName,
    this.targetAvatar = '',
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final SocketService _socketService = SocketService();
  final TextEditingController _messageController = TextEditingController();
  final UserController userController = Get.find<UserController>();
  ChatController chatController = Get.put(ChatController());
  final ScrollController _scrollController = ScrollController();

  late String _roomId;
  late String _senderId;
  late String _receiverId;
  List<MessageModel> _messages = [];

  FocusNode _focusNode = FocusNode();

  bool isLoading = true;

  Future<void> loadDetailList({required String roomId}) async {
    try {
      final newDetailList = await ChatApi.detail(roomId: roomId);
      _messages.assignAll(newDetailList);
      if (mounted) {
        setState(() {
          _messages.assignAll(newDetailList);
          isLoading = false;
          if (!isLoading) {
            // 延迟执行滚动
            Future.delayed(Duration(milliseconds: 300), () {
              _scrollToBottom(8000);
            });
          }
        });
      }
    } catch (e) {
      print("Error Load Chat Detail List: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _senderId = widget.senderId;
    _receiverId = widget.receiverId;
    // Sort the list first and then join it to create the roomId
    List<String> ids = [_senderId, _receiverId];
    ids.sort();
    _roomId = ids.join('_');

    // 加载历史消息
    loadDetailList(roomId: _roomId);

    // 连接到 Socket.IO 服务器
    _socketService.connect('http://10.0.2.2:3000');
    // 加入房间
    _socketService.joinRoom(_roomId);
    // 监听接收消息
    _socketService.onMessageReceived((message) {
      print('_socketService.onMessageReceived: ${message}');
      MessageModel msg = MessageModel.fromJson(message);
      if (mounted) {
        setState(() {
          _messages.add(msg);
        });
      }
    });

    // // 监听焦点变化
    // _focusNode.addListener(() {
    //   if (_focusNode.hasFocus) {
    //     _scrollToBottom(1000);
    //   }
    // });
  }

  @override
  void dispose() {
    _socketService.disconnect();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final String content = _messageController.text.trim();
    MessageModel msg = MessageModel(
      roomId: _roomId,
      senderId: _senderId,
      receiverId: _receiverId,
      content: content,
      type: 'text',
      time: '',
    );

    if (content.isNotEmpty && mounted) {
      _socketService.sendMessage(msg);
      _scrollToBottom(400);
      _messageController.clear();
    }
  }

  // 滚动到底部的方法
  void _scrollToBottom(double height) {
    // Scroll to the bottom of the chat list when a new message is added
    if (_scrollController.hasClients) {
      print("Scrolling to bottom");
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + height.h,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取键盘高度
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // 根据键盘是否弹出动态调整高度
    final bottomBoxHeight = keyboardHeight > 0 ? 120.w : 200.w;
    final lastMarginHeight = keyboardHeight > 0 ? 160.w : 230.w;

    return Scaffold(
      body: Stack(
        children: [
          GlassPage(
            title: widget.targetName,
            canBack: true,
            controller: _scrollController,
            pressBack: () {
              chatController.loadChatList(userId: _senderId);
              Get.back();
            },
            sliver: isLoading
                ? SliverToBoxAdapter(
                    child: Column(
                    children: [
                      SizedBox(height: 30.w),
                      myBubble(),
                      targetBubble(),
                      myBubble(),
                      targetBubble(),
                    ],
                  ))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: _messages.length,
                      (context, index) {
                        final MessageModel message = _messages[index];
                        final isMe = message.senderId == _senderId;

                        return isMe
                            ? Container(
                                width: 1.sw,
                                margin: EdgeInsets.only(
                                    bottom: index == _messages.length - 1
                                        ? lastMarginHeight
                                        : 40.w,
                                    top: index == 0 ? 30.w : 0),
                                padding: EdgeInsets.symmetric(horizontal: 30.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ChatBubble(
                                        isSentByMe: true,
                                        message: message.content),
                                    SizedBox(width: 30.w),
                                    Container(
                                      width: 100.w,
                                      height: 100.w,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          image:
                                              userController.avatar.value != ''
                                                  ? DecorationImage(
                                                      image: NetworkImage(
                                                          userController
                                                              .avatar.value),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null),
                                      child: userController.avatar.value != ''
                                          ? null
                                          : Center(
                                              child: Icon(
                                                CupertinoIcons.person_fill,
                                                size: 100.w,
                                                color: kGrey,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                width: 1.sw,
                                margin: EdgeInsets.only(
                                    bottom: index == _messages.length - 1
                                        ? lastMarginHeight
                                        : 40.w,
                                    top: index == 0 ? 30.w : 0),
                                padding: EdgeInsets.symmetric(horizontal: 30.w),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 100.w,
                                      height: 100.w,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          image: widget.targetAvatar != ''
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                      widget.targetAvatar),
                                                  fit: BoxFit.cover)
                                              : null),
                                      child: widget.targetAvatar != ''
                                          ? null
                                          : Center(
                                              child: Icon(
                                                CupertinoIcons.person_fill,
                                                size: 100.w,
                                                color: kGrey,
                                              ),
                                            ),
                                    ),
                                    SizedBox(width: 30.w),
                                    ChatBubble(
                                        isSentByMe: false,
                                        message: message.content),
                                  ],
                                ),
                              );
                      },
                    ),
                  ),
          ),
          Positioned(
              bottom: 0,
              child: Container(
                width: 1.sw,
                height: bottomBoxHeight,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border(top: BorderSide(color: kDevideColor)),
                ),
                child: Stack(children: [
                  Positioned.fill(
                    child: ClipRect(
                      // ClipRect 限制模糊范围
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          height: 200.h,
                          width: 1.sw,
                          color: Colors.white.withOpacity(0.7), // 半透明背景
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(height: 10.w),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 50.w),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {},
                            child: Icon(
                              CupertinoIcons.camera_fill,
                              color: kGrey,
                              size: 80.w,
                            ),
                          ),
                          SizedBox(width: 30.w),
                          Expanded(
                            child: CupertinoButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              child: Container(
                                child: CupertinoTextField(
                                  controller: _messageController,
                                  focusNode: _focusNode,
                                  placeholder: '信息',
                                  placeholderStyle: TextStyle(
                                    fontSize: 37.sp,
                                    color: CupertinoColors.placeholderText,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30.w, vertical: 20.w),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 30.w),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _sendMessage();
                            },
                            child: Container(
                              width: 80.w,
                              height: 80.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CupertinoColors.activeGreen,
                              ),
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.arrow_up,
                                  color: Colors.white,
                                  size: 60.w,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 50.w),
                        ],
                      ),
                    ],
                  ),
                ]),
              ))
        ],
      ),
    );
  }

  Widget myBubble() {
    return Container(
      margin: EdgeInsets.only(bottom: 30.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ChatBubble(
            isSentByMe: true,
            message: '',
            width: 0.5.sw,
            height: 300.h,
            myColor: Colors.white,
          ),
          SizedBox(width: 30.w),
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.person_fill,
                size: 100.w,
                color: kGrey,
              ),
            ),
          ),
          SizedBox(width: 30.w),
        ],
      ),
    );
  }

  Widget targetBubble() {
    return Container(
      margin: EdgeInsets.only(bottom: 30.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(width: 30.w),
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.person_fill,
                size: 100.w,
                color: kGrey,
              ),
            ),
          ),
          SizedBox(width: 30.w),
          ChatBubble(
            isSentByMe: false,
            message: '',
            width: 0.5.sw,
            height: 300.h,
          ),
        ],
      ),
    );
  }
}
