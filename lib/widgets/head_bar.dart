import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/constants/color.dart';
import 'package:test/constants/text.dart';

class HeadBar extends StatefulWidget {
  const HeadBar({super.key, required this.title, this.canBack = false});

  final String title;
  final bool canBack;

  @override
  State<HeadBar> createState() => _HeadBarState();
}

class _HeadBarState extends State<HeadBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 180.h,
      padding: EdgeInsets.fromLTRB(30.w, 95.w, 30.w, 5.w),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(
            color: Color.fromARGB(255, 216, 216, 216),
            width: 1.w,
          ))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.canBack)
          CupertinoButton(
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.chevron_back,
                    size: 70.w,
                    color: kMainColor,
                  ),
                  Text(
                    '返回',
                    style: TextStyle(
                      fontSize: 45.sp,
                      fontWeight: FontWeight.bold,
                      color: kMainColor,
                    ),
                  )
                ],
              ),
              onPressed: () {
                Get.back();
              }),
        Spacer(),
        Text(
          widget.title,
          style: kPageTitle,
        ),
        Spacer(),
        if (widget.canBack)
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
                  )
                ],
              ),
              onPressed: () {}),
      ]),
    );
  }
}
