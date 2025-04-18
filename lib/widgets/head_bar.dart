import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/constants/color.dart';
import 'package:test/constants/text.dart';

class HeadBar extends StatefulWidget {
  const HeadBar(
      {super.key,
      required this.title,
      this.canBack = false,
      this.pressBack = _defaultPressBack,
      this.rightWidget});

  final String title;
  final bool canBack;
  final void Function() pressBack;
  final Widget? rightWidget;

  static void _defaultPressBack() {
    Get.back();
  }

  @override
  State<HeadBar> createState() => _HeadBarState();
}

class _HeadBarState extends State<HeadBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 180.h,
      // padding: EdgeInsets.fromLTRB(30.w, 95.w, 30.w, 5.w),
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
              bottom: BorderSide(
            color: Color.fromARGB(255, 216, 216, 216),
            width: 1.w,
          ))),
      child: Stack(children: [
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
        Center(
          child: Column(
            children: [
              SizedBox(height: 90.h),
              Container(
                height: 80.h,
                child: Text(
                  widget.title,
                  style: kPageTitle,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            SizedBox(height: 80.h),
            CupertinoButton(
              onPressed: () {
                widget.canBack ? widget.pressBack() : null;
              },
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 20.w),
                  Container(
                    width: 50.w,
                    child: Icon(
                      CupertinoIcons.chevron_back,
                      size: 70.w,
                      color: widget.canBack ? kMainColor : Colors.transparent,
                    ),
                  ),
                  Text(
                    '返回',
                    style: TextStyle(
                      fontSize: 45.sp,
                      fontWeight: FontWeight.bold,
                      color: widget.canBack ? kMainColor : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // 右侧组件
        if (widget.rightWidget != null)
          Positioned(
            top: 80.h,
            right: 20.w,
            child: widget.rightWidget!,
          ),
      ]),
    );
  }
}
