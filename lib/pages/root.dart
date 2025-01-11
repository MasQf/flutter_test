import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test/constants/color.dart';
import 'package:test/pages/chat_list.dart';
import 'package:test/pages/home.dart';
import 'package:test/pages/personal.dart';
import 'package:test/pages/reset_password.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _pageIndex = 0;
  late List<Widget> _pages;

  void onItemTapped(int index) {
    setState(() {
      _pageIndex = index; // 更新当前选中的索引
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      ResetPasswordPage(),
      ChatListPage(),
      PersonalPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      body: IndexedStack(
        index: _pageIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 180.h, // 设置导航栏高度
        decoration: BoxDecoration(
            color: Colors.transparent, // 设置背景颜色
            border: Border(
                top: BorderSide(color: Color.fromARGB(255, 212, 212, 212)))),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRect(
                // ClipRect 限制模糊范围
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 50), // 高斯模糊参数
                  child: Container(
                    height: 180.h,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Column(
                      children: [
                        Icon(
                          _pageIndex == 0
                              ? CupertinoIcons.house_fill
                              : CupertinoIcons.house,
                          size: 80.w,
                          color: _pageIndex == 0 ? kMainColor : kGrey,
                        ),
                        Text(
                          '首页',
                          style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                              color: _pageIndex == 0 ? kMainColor : kGrey),
                        ),
                      ],
                    ),
                    onPressed: () => onItemTapped(0),
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Column(
                      children: [
                        Icon(
                          _pageIndex == 1
                              ? CupertinoIcons.star_fill
                              : CupertinoIcons.star,
                          size: 80.w,
                          color: _pageIndex == 1 ? kMainColor : kGrey,
                        ),
                        Text(
                          '发布',
                          style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                              color: _pageIndex == 1 ? kMainColor : kGrey),
                        ),
                      ],
                    ),
                    onPressed: () => onItemTapped(1),
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Icon(
                            _pageIndex == 2
                                ? CupertinoIcons.chat_bubble_fill
                                : CupertinoIcons.chat_bubble,
                            size: 80.w,
                            color: _pageIndex == 2 ? kMainColor : kGrey,
                          ),
                        ),
                        Text(
                          '消息',
                          style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                              color: _pageIndex == 2 ? kMainColor : kGrey),
                        ),
                      ],
                    ),
                    onPressed: () => onItemTapped(2),
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Icon(
                            _pageIndex == 3
                                ? CupertinoIcons.person_fill
                                : CupertinoIcons.person,
                            size: 80.w,
                            color: _pageIndex == 3 ? kMainColor : kGrey,
                          ),
                        ),
                        Text(
                          '我的',
                          style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                              color: _pageIndex == 3 ? kMainColor : kGrey),
                        ),
                      ],
                    ),
                    onPressed: () => onItemTapped(3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
