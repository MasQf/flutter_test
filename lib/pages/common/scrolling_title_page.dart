import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/constants/color.dart';
import 'package:test/constants/text.dart';
import 'package:test/controllers/user.dart';

class ScrollingTitlePage extends StatefulWidget {
  final String title;
  final List<Widget> titleAdapter;
  final bool canBack;
  final SliverList? sliverList;
  final Widget? actionButton;

  const ScrollingTitlePage({
    super.key,
    required this.title,
    required this.titleAdapter,
    this.canBack = false,
    this.sliverList,
    this.actionButton,
  });

  @override
  State<ScrollingTitlePage> createState() => _ScrollingTitlePageState();
}

class _ScrollingTitlePageState extends State<ScrollingTitlePage> {
  UserController userController = Get.find<UserController>();

  final ScrollController _scrollController = ScrollController();
  final GlobalKey key1 = GlobalKey(); // 用于第一个 Container
  final GlobalKey key2 = GlobalKey(); // 用于第二个 Container

  double _opacity = 0.0;
  double _notEditOpacity = 1.0;
  double _editOpacity = 0.0;
  double _scale = 1.0;
  bool isBottomBelowOrEqualTop = false;

  bool isEditing = false; // 是否处于编辑状态

  void checkPosition() {
    final RenderBox renderBox1 = key1.currentContext?.findRenderObject() as RenderBox;
    final position1 = renderBox1.localToGlobal(Offset.zero);
    final size1 = renderBox1.size;
    final bottom1 = position1.dy + size1.height; // 第一个 Container 的底部

    final RenderBox renderBox2 = key2.currentContext?.findRenderObject() as RenderBox;
    final position2 = renderBox2.localToGlobal(Offset.zero);
    final top2 = position2.dy; // 第二个 Container 的顶部

    isBottomBelowOrEqualTop = bottom1 >= top2;
  }

  void toggleEditing() {
    setState(() {
      _editOpacity == 1.0 ? _editOpacity = 0.0 : _editOpacity = 1.0;
      _notEditOpacity == 1.0 ? _notEditOpacity = 0.0 : _notEditOpacity = 1.0;
      isEditing = !isEditing;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification.metrics.axis == Axis.vertical) {
            double offset = notification.metrics.pixels;
            checkPosition();
            if (isBottomBelowOrEqualTop) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _opacity = 1;
                  _opacity = _opacity.clamp(0.0, 1.0);
                });
              });
            } else {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _opacity = 0;
                  _opacity = _opacity.clamp(0.0, 1.0);
                  _scale = 1.0;
                });
              });
            }

            if (offset <= 0) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _scale = (1 - offset / 200).clamp(1.0, 1.2);
                });
              });
            }
          }
          return false;
        },
        child: Stack(
          children: [
            CupertinoScrollbar(
              controller: _scrollController,
              thickness: 10.w,
              thicknessWhileDragging: 16.w,
              radius: Radius.circular(10.r),
              child: Container(
                child: CustomScrollView(controller: _scrollController, slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.only(top: 0.1.sh),
                      color: Colors.white,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.scale(
                            scale: _scale,
                            child: Container(
                              height: 130.w,
                              margin: EdgeInsets.symmetric(horizontal: 80.w),
                              child: Text(
                                widget.title,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 90.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.w),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 80.w),
                            child: Column(
                              children: [
                                Container(
                                  key: key2,
                                  color: kDevideColor,
                                  height: 2.h,
                                  width: 1.sw,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.titleAdapter,
                          )
                        ],
                      ),
                    ),
                  ),
                  if (widget.sliverList != null) widget.sliverList!,
                ]),
              ),
            ),
            Positioned(
              key: key1,
              top: 0,
              left: 0,
              right: 0,
              child: Stack(
                children: [
                  _opacity == 1
                      ? Positioned(
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                              child: Container(
                                height: 180.h,
                                width: 1.sw,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        )
                      : Positioned(
                          child: Container(
                            height: 180.h,
                            width: 1.sw,
                            color: Colors.white,
                          ),
                        ),
                  Container(
                    height: 180.h,
                    width: 1.sw,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: kDevideColor.withOpacity(_opacity),
                          width: 2.w,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 90.h),
                        Row(
                          children: [
                            Container(
                              width: 300.w,
                              height: 80.h,
                              child: widget.canBack
                                  ? CupertinoButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      padding: EdgeInsets.zero,
                                      child: Row(
                                        children: [
                                          SizedBox(width: 40.w),
                                          Stack(
                                            children: [
                                              AnimatedOpacity(
                                                opacity: _notEditOpacity,
                                                duration: Duration(milliseconds: 200),
                                                curve: Curves.easeInOut,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 50.w,
                                                      child: Icon(
                                                        CupertinoIcons.chevron_back,
                                                        size: 70.w,
                                                        color: isEditing ? Colors.transparent : kMainColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      '返回',
                                                      style: TextStyle(
                                                        fontSize: 45.sp,
                                                        fontWeight: FontWeight.bold,
                                                        color: kMainColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              AnimatedOpacity(
                                                opacity: _editOpacity,
                                                duration: Duration(milliseconds: 200),
                                                curve: Curves.easeInOut,
                                                child: Text(
                                                  '全选',
                                                  style: TextStyle(
                                                    fontSize: 45.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: kMainColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  : null,
                            ),
                            Spacer(),
                            AnimatedOpacity(
                              opacity: _opacity,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: Container(
                                height: 80.h,
                                child: Text(
                                  widget.title,
                                  style: kPageTitle,
                                ),
                              ),
                            ),
                            Spacer(),
                            Container(
                              width: 300.w,
                              height: 80.h,
                              child: Center(
                                child: widget.actionButton,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
