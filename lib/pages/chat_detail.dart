import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/chat.dart';
import 'package:test/constants/color.dart';
import 'package:test/controllers/chat.dart';
import 'package:test/controllers/user.dart';
import 'package:test/models/message.dart';
import 'package:test/pages/photo_view.dart';
import 'package:test/services/socket.dart';
import 'package:test/widgets/chat_bubble.dart';
import 'package:test/widgets/cup_button.dart';
import 'package:test/widgets/glass_page.dart';

class ChatDetailPage extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String targetName;
  final String targetAvatar;

  const ChatDetailPage({
    required this.senderId,
    required this.receiverId,
    required this.targetName,
    this.targetAvatar = '',
  });

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
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
      if (mounted) {
        setState(() {
          _messages.assignAll(newDetailList);
          isLoading = false;
          if (!isLoading) {
            // 延迟执行滚动
            Future.delayed(Duration(milliseconds: 300), () {
              _scrollToBottom(0);
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
    // 重置未读消息数
    _socketService.resetUnreadCount(_roomId, _senderId);
    // 监听接收消息
    _socketService.receiveMessage((message) {
      MessageModel msg = MessageModel.fromJson(message);
      if (mounted) {
        setState(() {
          _messages.add(msg);
        });
        Future.delayed(Duration(milliseconds: 300), () {
          _scrollToBottom(0);
        });
      }
    });

    // 监听焦点变化
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom(800);
      }
    });
  }

  @override
  void dispose() {
    // 离开房间
    _socketService.leaveRoom(_roomId);
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
      _messageController.clear();
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollToBottom(0);
      });
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

  void _showInfo({String? avatar, required String name}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      barrierColor: Colors.black.withOpacity(0),
      builder: (context) {
        return Container(
          width: 1.sw,
          height: 0.85.sh,
          decoration: BoxDecoration(
            color: kBackColor,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: Offset(0, -3),
              )
            ],
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: 1.sw,
                  padding: EdgeInsets.only(top: 200.w),
                  child: Column(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (avatar != null) {
                            Get.to(
                              () => PhotoViewPage(
                                images: [avatar],
                                initialIndex: 0,
                                hasPage: false,
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 230.w,
                          height: 230.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            image: (avatar?.isNotEmpty ?? false)
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(avatar!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (avatar?.isNotEmpty ?? false)
                              ? null
                              : Center(
                                  child: Icon(
                                    CupertinoIcons.person_fill,
                                    size: 190.w,
                                    color: kGrey,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 30.w),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 60.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 50.w),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 60.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Column(
                          children: [
                            infoButton(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r),
                                topRight: Radius.circular(30.r),
                              ),
                              onPressed: () {},
                              title: '发布',
                            ),
                            infoButton(
                              onPressed: () {},
                              title: '评价',
                            ),
                            infoButton(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30.r),
                                bottomRight: Radius.circular(30.r),
                              ),
                              onPressed: () {},
                              title: '称号',
                              hasDevider: false,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 80.w),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 60.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Column(
                          children: [
                            infoButton(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r),
                                topRight: Radius.circular(30.r),
                              ),
                              onPressed: () {},
                              title: '发布',
                              hasDevider: true,
                            ),
                            infoButton(
                              onPressed: () {},
                              title: '评价',
                              hasDevider: true,
                            ),
                            infoButton(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30.r),
                                bottomRight: Radius.circular(30.r),
                              ),
                              onPressed: () {},
                              title: '称号',
                              hasDevider: false,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 80.w),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 60.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Column(
                          children: [
                            infoButton(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r),
                                topRight: Radius.circular(30.r),
                              ),
                              onPressed: () {},
                              title: '发布',
                              hasDevider: true,
                            ),
                            infoButton(
                              onPressed: () {},
                              title: '评价',
                              hasDevider: true,
                            ),
                            infoButton(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30.r),
                                bottomRight: Radius.circular(30.r),
                              ),
                              onPressed: () {},
                              title: '称号',
                              hasDevider: false,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 80.w),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 60.w),
                        child: infoButton(
                          borderRadius: BorderRadius.circular(30.r),
                          onPressed: () {},
                          title: '举报',
                          titleColor: CupertinoColors.destructiveRed,
                          hasDevider: false,
                        ),
                      ),
                      SizedBox(height: 150.w),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1.sw,
                height: 130.w,
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: kDevideColor, width: 2.w))),
                child: Stack(
                  children: [
                    Positioned(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 1.sw,
                            height: 130.w,
                            color: Colors.white.withOpacity(0.7), // 半透明背景
                          ),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.w),
                        child: Row(
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {},
                              child: Text(
                                '完成',
                                style: TextStyle(
                                  fontSize: 45.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                            Spacer(),
                            Text(
                              '个人信息',
                              style: TextStyle(
                                fontSize: 45.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Spacer(),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Get.back();
                              },
                              child: Text(
                                '完成',
                                style: TextStyle(
                                  fontSize: 45.sp,
                                  fontWeight: FontWeight.bold,
                                  color: kMainColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取键盘高度
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // 根据键盘是否弹出动态调整高度
    final bottomBoxHeight = keyboardHeight > 0 ? 120.w : 200.w;
    final lastMarginHeight = keyboardHeight > 0 ? 40.w : 40.w;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GlassPage(
                  title: widget.targetName,
                  canBack: true,
                  controller: _scrollController,
                  pressBack: () {
                    chatController.loadChatList(userId: _senderId);
                    Get.back();
                  },
                  background: userController.background.value,
                  // 加载
                  // SliverToBoxAdapter(
                  //     child: Column(
                  //     children: [
                  //       SizedBox(height: 30.w),
                  //       myBubble(),
                  //       targetBubble(),
                  //       myBubble(),
                  //       targetBubble(),
                  //     ],
                  //   ))
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: _messages.length,
                      (context, index) {
                        final MessageModel message = _messages[index];
                        final isMe = message.senderId == _senderId;

                        return isMe
                            ? Container(
                                width: 1.sw,
                                margin: EdgeInsets.only(
                                    bottom: index == _messages.length - 1 ? lastMarginHeight : 40.w,
                                    top: index == 0 ? 30.w : 0),
                                padding: EdgeInsets.symmetric(horizontal: 30.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ChatBubble(isSentByMe: true, message: message.content),
                                    SizedBox(width: 30.w),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        _showInfo(avatar: userController.avatar.value, name: userController.name.value);
                                      },
                                      child: Container(
                                        width: 100.w,
                                        height: 100.w,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10.r),
                                            image: userController.avatar.value != ''
                                                ? DecorationImage(
                                                    image: CachedNetworkImageProvider(userController.avatar.value),
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
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                width: 1.sw,
                                margin: EdgeInsets.only(
                                    bottom: index == _messages.length - 1 ? lastMarginHeight : 40.w,
                                    top: index == 0 ? 30.w : 0),
                                padding: EdgeInsets.symmetric(horizontal: 30.w),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        _showInfo(avatar: widget.targetAvatar, name: widget.targetName);
                                      },
                                      child: Container(
                                        width: 100.w,
                                        height: 100.w,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10.r),
                                            image: widget.targetAvatar != ''
                                                ? DecorationImage(
                                                    image: CachedNetworkImageProvider(widget.targetAvatar),
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
                                    ),
                                    SizedBox(width: 30.w),
                                    ChatBubble(isSentByMe: false, message: message.content),
                                  ],
                                ),
                              );
                      },
                    ),
                  ),
                ),
              ),
              Container(
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
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.w),
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
              ),
            ],
          ),
          // Positioned(
          //   bottom: 0,
          //   child: Container(
          //     width: 1.sw,
          //     height: 0.85.sh,
          //     decoration: BoxDecoration(
          //       color: kBackColor,
          //       borderRadius: BorderRadius.circular(30.r),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.05),
          //           blurRadius: 20,
          //           offset: Offset(0, -3),
          //         )
          //       ],
          //     ),
          //     child: Stack(
          //       children: [
          //         SingleChildScrollView(
          //           child: Container(
          //             width: 1.sw,
          //             padding: EdgeInsets.only(top: 200.w),
          //             child: Column(
          //               children: [
          //                 CupertinoButton(
          //                   padding: EdgeInsets.zero,
          //                   onPressed: () {
          //                     if (widget.targetAvatar != '') {
          //                       Get.to(
          //                         () => PhotoViewPage(
          //                           images: [widget.targetAvatar],
          //                           initialIndex: 0,
          //                           hasPage: false,
          //                         ),
          //                       );
          //                     }
          //                   },
          //                   child: Container(
          //                     width: 230.w,
          //                     height: 230.w,
          //                     decoration: BoxDecoration(
          //                       color: Colors.white,
          //                       shape: BoxShape.circle,
          //                       image: widget.targetAvatar != ''
          //                           ? DecorationImage(
          //                               image:
          //                                   CachedNetworkImageProvider(widget.targetAvatar),
          //                               fit: BoxFit.cover,
          //                             )
          //                           : null,
          //                     ),
          //                     child: widget.targetAvatar != ''
          //                         ? null
          //                         : Center(
          //                             child: Icon(
          //                               CupertinoIcons.person_fill,
          //                               size: 190.w,
          //                               color: kGrey,
          //                             ),
          //                           ),
          //                   ),
          //                 ),
          //                 SizedBox(height: 30.w),
          //                 Text(
          //                   widget.targetName,
          //                   style: TextStyle(
          //                     fontSize: 60.sp,
          //                     fontWeight: FontWeight.bold,
          //                     color: Colors.black,
          //                   ),
          //                 ),
          //                 SizedBox(height: 50.w),
          //                 Container(
          //                   margin: EdgeInsets.symmetric(horizontal: 40.w),
          //                   decoration: BoxDecoration(
          //                     color: Colors.white,
          //                     borderRadius: BorderRadius.circular(30.r),
          //                   ),
          //                   child: Column(
          //                     children: [
          //                       infoButton(
          //                         borderRadius: BorderRadius.only(
          //                           topLeft: Radius.circular(30.r),
          //                           topRight: Radius.circular(30.r),
          //                         ),
          //                         onPressed: () {},
          //                         title: '已发布',
          //                       ),
          //                       infoButton(
          //                         onPressed: () {},
          //                         title: '发布',
          //                       ),
          //                       infoButton(
          //                         borderRadius: BorderRadius.only(
          //                           bottomLeft: Radius.circular(30.r),
          //                           bottomRight: Radius.circular(30.r),
          //                         ),
          //                         onPressed: () {},
          //                         title: '发布',
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //         Container(
          //           width: 1.sw,
          //           height: 130.w,
          //           child: Stack(
          //             children: [
          //               Positioned(
          //                 child: ClipRRect(
          //                   borderRadius: BorderRadius.only(
          //                     topLeft: Radius.circular(30.r),
          //                     topRight: Radius.circular(30.r),
          //                   ),
          //                   child: BackdropFilter(
          //                     filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          //                     child: Container(
          //                       width: 1.sw,
          //                       height: 130.w,
          //                       color: Colors.white.withOpacity(0.7), // 半透明背景
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //               ClipRRect(
          //                 borderRadius: BorderRadius.only(
          //                   topLeft: Radius.circular(30.r),
          //                   topRight: Radius.circular(30.r),
          //                 ),
          //                 child: Container(
          //                   padding: EdgeInsets.symmetric(
          //                       horizontal: 40.w, vertical: 30.w),
          //                   child: Row(
          //                     children: [
          //                       CupertinoButton(
          //                         padding: EdgeInsets.zero,
          //                         onPressed: () {},
          //                         child: Text(
          //                           '完成',
          //                           style: TextStyle(
          //                             fontSize: 45.sp,
          //                             fontWeight: FontWeight.bold,
          //                             color: Colors.transparent,
          //                           ),
          //                         ),
          //                       ),
          //                       Spacer(),
          //                       Text(
          //                         '个人信息',
          //                         style: TextStyle(
          //                           fontSize: 45.sp,
          //                           fontWeight: FontWeight.bold,
          //                           color: Colors.black,
          //                         ),
          //                       ),
          //                       Spacer(),
          //                       CupertinoButton(
          //                         padding: EdgeInsets.zero,
          //                         onPressed: () {
          //                           Get.back();
          //                         },
          //                         child: Text(
          //                           '完成',
          //                           style: TextStyle(
          //                             fontSize: 45.sp,
          //                             fontWeight: FontWeight.bold,
          //                             color: kMainColor,
          //                           ),
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         )
          //       ],
          //     ),
          //   ),
          // ),
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

  Widget infoButton({
    BorderRadiusGeometry? borderRadius,
    required void Function() onPressed,
    required String title,
    Color? titleColor = Colors.black,
    bool? hasDevider = true,
  }) {
    return CupButton(
        borderRadius: borderRadius,
        onPressed: onPressed,
        child: Container(
          width: 1.sw,
          child: Row(
            children: [
              SizedBox(width: 40.w),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: (hasDevider ?? false)
                        ? Border(
                            bottom: BorderSide(color: kDevideColor, width: 2.w),
                          )
                        : null,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20.w),
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 45.sp,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            CupertinoIcons.chevron_forward,
                            color: kGrey,
                            size: 60.w,
                          ),
                          SizedBox(width: 30.w),
                        ],
                      ),
                      SizedBox(height: 20.w),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
