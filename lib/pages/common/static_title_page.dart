import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/constants/color.dart';
import 'package:test/widgets/head_bar.dart';

class StaticTitlePage extends StatefulWidget {
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
  State<StaticTitlePage> createState() => _StaticTitlePageState();
}

class _StaticTitlePageState extends State<StaticTitlePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      body: Stack(
        children: [
          if (widget.background != null)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    replaceLocalhost(widget.background!),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          CupertinoScrollbar(
            controller: widget.controller,
            thickness: 10.w,
            thicknessWhileDragging: 16.w,
            radius: Radius.circular(10.r),
            child: CustomScrollView(
              controller: widget.controller,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(top: 180.h),
                  sliver: widget.sliver,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: HeadBar(
              title: widget.title ?? '',
              canBack: widget.canBack ?? false,
              pressBack: widget.pressBack,
            ),
          ),
        ],
      ),
    );
  }
}
