import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/constants/color.dart';
import 'package:test/constants/text.dart';
import 'package:test/pages/chat.dart';
import 'package:test/pages/chat_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
                child: Text('ChatPage', style: kPageTitle),
                onPressed: () {
                  Get.to(() => ChatPage(), transition: Transition.cupertino);
                }),
          ],
        ),
      ),
    );
  }
}
