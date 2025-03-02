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
  final List<Widget> children;

  const ScrollingTitlePage({super.key, required this.title, required this.children});

  @override
  State<ScrollingTitlePage> createState() => _ScrollingTitlePageState();
}

class _ScrollingTitlePageState extends State<ScrollingTitlePage> {
  UserController userController = Get.find<UserController>();

  final ScrollController _scrollController = ScrollController();

  double _opacity = 0.0;
  double _scale = 1.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification.metrics.axis == Axis.vertical) {
            double offset = notification.metrics.pixels;
            if (offset >= 152.h) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _opacity = 1;
                  _opacity = _opacity.clamp(0.0, 1.0);
                });
              });
            } else if (offset <= 0) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _scale = (1 - offset / 200).clamp(1.0, 1.2);
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
                          Column(
                            children: widget.children,
                          )
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Stack(
                children: [
                  if (_opacity == 1)
                    Positioned(
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
                    ),
                  if (_opacity != 1)
                    Positioned(
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
