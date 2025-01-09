import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/constants/color.dart';
import 'package:test/constants/text.dart';
import 'package:test/controllers/chat.dart';
import 'package:test/controllers/user.dart';
import 'package:test/models/chat.dart';
import 'package:test/pages/chat.dart';
import 'package:test/utils/date.dart';
import 'package:test/widgets/glass_page.dart';

class ChatListPage extends StatefulWidget {
  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  ChatController chatController = Get.put(ChatController());
  UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    chatController.loadChatList(userId: userController.id.value);
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: '消息',
      canBack: false,
      sliver: Obx(
        () => SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              ChatModel chat = chatController.chatList[index];
              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Get.to(
                    () => ChatPage(
                      senderId: userController.id.value,
                      receiverId: chat.targetUser.id,
                      targetName: chat.targetUser.name,
                    ),
                    transition: Transition.cupertino,
                  );
                },
                child: Container(
                  width: 1.sw,
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 30.w),
                        child: Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            color: kBackColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Icon(
                              CupertinoIcons.person_fill,
                              size: 110.w,
                              color: kGrey,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 30.w),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 30.w),
                        decoration: BoxDecoration(
                            border: index == chatController.chatList.length - 1
                                ? null
                                : Border(
                                    bottom: BorderSide(
                                    color: kBackColor,
                                    width: 1.w,
                                  ))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 570.w,
                                  child: Text(
                                    chat.targetUser.name,
                                    style: kPageTitle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 30.w),
                                Text(
                                  formatDate(chat.lastMessage.time),
                                  style: TextStyle(
                                    fontSize: 32.sp,
                                    color: kGrey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Container(
                              width: 0.7.sw,
                              child: Text(
                                chat.lastMessage.content,
                                style: TextStyle(
                                  fontSize: 40.sp,
                                  fontWeight: FontWeight.bold,
                                  color: kGrey,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: chatController.chatList.length,
          ),
        ),
      ),
    );
  }
}
