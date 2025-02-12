import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test/constants/color.dart';
import 'package:test/widgets/button/cup_button.dart';

Widget bigButton(IconData? icon, String text, void Function() onPressed) {
  return CupButton(
    onPressed: onPressed,
    child: Container(
      width: 1.sw,
      padding: EdgeInsets.symmetric(vertical: 30.w),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF8a8a8d), size: 80.w),
          SizedBox(width: 20.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 45.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Spacer(),
          Icon(
            CupertinoIcons.chevron_forward,
            size: 60.w,
            color: kGrey,
          ),
        ],
      ),
    ),
  );
}
