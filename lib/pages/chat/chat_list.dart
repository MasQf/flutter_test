import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/constants/color.dart';
import 'package:test/constants/text.dart';
import 'package:test/controllers/chat.dart';
import 'package:test/controllers/user.dart';
import 'package:test/models/chat.dart';
import 'package:test/pages/chat/chat_detail.dart';
import 'package:test/services/socket.dart';
import 'package:test/utils/date.dart';
import 'package:test/widgets/button/cup_button.dart';
import 'package:test/pages/common/static_title_page.dart';

class ChatListPage extends StatefulWidget {
  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  ChatController chatController = Get.put(ChatController());
  UserController userController = Get.find<UserController>();
  final SocketService _socketService = SocketService();
  late String _userId;

  final ScrollController _scrollController = ScrollController();

  bool isImageUrl(String content) {
    // 定义一个简单的正则表达式，检查图片路径
    final imageRegex = RegExp(r'\b(http(s)?://\S+\.(jpg|jpeg|png|gif|bmp|webp))\b');
    return imageRegex.hasMatch(content);
  }

  Widget buildMessageText(String content) {
    if (isImageUrl(content)) {
      // 如果是图片链接，则显示 [图片]
      return Text(
        '[图片]',
        style: TextStyle(
          fontSize: 40.sp,
          fontWeight: FontWeight.bold,
          color: kGrey,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      // 否则正常显示文本
      return Text(
        content,
        style: TextStyle(
          fontSize: 40.sp,
          fontWeight: FontWeight.bold,
          color: kGrey,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    chatController.loadChatList(userId: userController.id.value);
    _userId = userController.id.value;
    // 用户进入聊天列表页面时加入房间
    _socketService.connect('http://10.0.2.2:3000');
    _socketService.joinRoom(_userId);
    // 监听刷新聊天列表事件
    _socketService.refreshChatList((data) {
      print('New message in room: ${data['roomId']}');
      chatController.loadChatList(userId: userController.id.value);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StaticTitlePage(
      title: '信息',
      canBack: false,
      controller: _scrollController,
      sliver: Obx(
        () => SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              ChatModel chat = chatController.chatList[index];
              return Column(
                children: [
                  CupButton(
                    onPressed: () {
                      Get.to(
                        () => ChatDetailPage(
                          senderId: userController.id.value,
                          receiverId: chat.targetUser.id,
                          targetName: chat.targetUser.name,
                          targetAvatar: chat.targetUser.avatar,
                        ),
                        transition: Transition.cupertino,
                      );
                    },
                    child: Container(
                        width: 1.sw,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 40.w),
                            Column(
                              children: [
                                SizedBox(height: 30.w),
                                Container(
                                  width: 120.w,
                                  height: 120.w,
                                  decoration: BoxDecoration(
                                    color: kBackColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                    image: chat.targetUser.avatar != ''
                                        ? DecorationImage(
                                            image: CachedNetworkImageProvider(chat.targetUser.avatar),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: chat.targetUser.avatar != ''
                                      ? null
                                      : Center(
                                          child: Icon(
                                            CupertinoIcons.person_fill,
                                            size: 110.w,
                                            color: kGrey,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            SizedBox(width: 30.w),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    // border: index == chatController.chatList.length - 1
                                    //     ? null
                                    //     : Border(
                                    //         bottom: BorderSide(
                                    //         color: kBackColor,
                                    //         width: 2.w,
                                    //       )),
                                    ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 20.w),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                chat.targetUser.name,
                                                style: kPageTitle,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: 30.w),
                                            Text(
                                              getFriendlyDate(chat.lastMessage.time),
                                              style: TextStyle(
                                                fontSize: 40.sp,
                                                color: kGrey,
                                              ),
                                            ),
                                            SizedBox(width: 20.w),
                                            Icon(
                                              CupertinoIcons.chevron_forward,
                                              color: kArrowGrey,
                                              size: 50.w,
                                            ),
                                            SizedBox(width: 40.w),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: buildMessageText(chat.lastMessage.content),
                                            ),
                                            SizedBox(width: 30.w),
                                            if (chat.unreadCount[userController.id.value] != null &&
                                                chat.unreadCount[userController.id.value] != 0)
                                              Container(
                                                height: 50.h,
                                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                                decoration: BoxDecoration(
                                                  color: kMainColor,
                                                  borderRadius: BorderRadius.circular(50.r),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${chat.unreadCount[userController.id.value]}',
                                                    style: TextStyle(
                                                      fontSize: 35.sp,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            SizedBox(width: 40.w),
                                          ],
                                        ),
                                        SizedBox(height: 20.w),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 190.w,
                        height: 2.h,
                        color: Colors.white,
                      ),
                      Container(
                        width: 1.sw - 190.w,
                        height: 2.h,
                        color: kDevideColor,
                      ),
                    ],
                  )
                ],
              );
            },
            childCount: chatController.chatList.length,
          ),
        ),
      ),
    );
  }
}
