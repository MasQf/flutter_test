import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/chat.dart';
import 'package:test/constants/color.dart';
import 'package:test/constants/text.dart';
import 'package:test/controllers/user.dart';
import 'package:test/pages/chat.dart';
import 'package:test/pages/chat_list.dart';
import 'package:test/pages/login.dart';

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
      body: Container(),
    );
  }
}
