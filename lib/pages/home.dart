import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/constants/color.dart';
import 'package:test/controllers/user.dart';
import 'package:test/pages/chat_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      body: Container(
        child: CupertinoButton(
          child: Text('Chat With 845749043'),
          onPressed: () {
            Get.to(() => ChatDetailPage(
                  senderId: userController.id.value,
                  receiverId: '677ccaa3517b789f761d9067',
                  targetName: '845749043',
                ));
          },
        ),
      ),
    );
  }
}
