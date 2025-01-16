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
      this.pressBack = _defaultPressBack});

  final String title;
  final bool canBack;
  final void Function() pressBack;

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
            // ClipRect 限制模糊范围
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 180.h,
                width: 1.sw,
                color: Colors.white.withOpacity(0.7), // 半透明背景
              ),
            ),
          ),
        ),
        Column(
          children: [
            SizedBox(height: 90.w),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 30.w),
                Container(
                  height: 80.w,
                  child: Center(
                    child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.chevron_back,
                              size: 70.w,
                              color: widget.canBack
                                  ? kMainColor
                                  : Colors.transparent,
                            ),
                            Text(
                              '返回',
                              style: TextStyle(
                                fontSize: 45.sp,
                                fontWeight: FontWeight.bold,
                                color: widget.canBack
                                    ? kMainColor
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          widget.canBack ? widget.pressBack() : null;
                        }),
                  ),
                ),
                Spacer(),
                Container(
                  height: 80.w,
                  child: Center(
                    child: Text(
                      widget.title,
                      style: kPageTitle,
                    ),
                  ),
                ),
                Spacer(),
                CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.chevron_back,
                          size: 70.w,
                          color: Colors.transparent,
                        ),
                        Text(
                          '返回',
                          style: TextStyle(
                            fontSize: 45.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      null;
                    }),
                SizedBox(width: 30.w),
              ],
            ),
          ],
        ),
      ]),
    );
  }
}
