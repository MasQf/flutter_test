import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/constants/color.dart';
import 'package:test/widgets/head_bar.dart';

class GlassPage extends StatelessWidget {
  final Widget? sliver;
  final String? title;
  final bool? canBack;
  final void Function() pressBack;
  final ScrollController? controller;

  const GlassPage({
    super.key,
    this.sliver,
    this.title = '',
    this.canBack = false,
    this.pressBack = _defaultPressBack,
    this.controller,
  });

  static void _defaultPressBack() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: controller,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(top: 180.h),
                sliver: sliver,
              ),
            ],
          ),
          Positioned(
            top: 0,
            child: HeadBar(
              title: title ?? '',
              canBack: canBack ?? false,
              pressBack: pressBack,
            ),
          ),
        ],
      ),
    );
  }
}
