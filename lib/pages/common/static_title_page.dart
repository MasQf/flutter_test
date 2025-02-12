import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/constants/color.dart';
import 'package:test/widgets/head_bar.dart';

class StaticTitlePage extends StatelessWidget {
  final Widget? sliver;
  final String? title;
  final bool? canBack;
  final void Function() pressBack;
  final ScrollController? controller;
  final String? background;

  const StaticTitlePage({
    super.key,
    this.sliver,
    this.title = '',
    this.canBack = false,
    this.pressBack = _defaultPressBack,
    this.controller,
    this.background,
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
          if (background != null)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    replaceLocalhost(background!),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
