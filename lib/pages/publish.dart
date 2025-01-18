import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/constants/color.dart';
import 'package:test/constants/text.dart';
import 'package:test/controllers/publish.dart';
import 'package:test/controllers/user.dart';
import 'package:test/models/item.dart';
import 'package:test/pages/item_detail.dart';
import 'package:test/widgets/cup_button.dart';

class PublishPage extends StatefulWidget {
  const PublishPage({super.key});

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage>
    with TickerProviderStateMixin {
  PublishController publishController = Get.put(PublishController());
  UserController userController = Get.find<UserController>();

  double _opacity = 0.0; // 用于控制导航栏透明度

  String _coordinates = "点击屏幕获取坐标";
  bool showControl = false;
  double dx = 0.w;
  double dy = 0.h;

  bool isGrid = true;

  late AnimationController _dotController;
  late AnimationController _imageController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    publishController.loadPublishList(userId: userController.id.value);
    _dotController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _imageController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _dotController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _onTapUp(TapUpDetails details) {
    _imageController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _imageController.reverse();
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.to(() => ItemDetailPage(), transition: Transition.cupertino);
      });
    });
  }

  void _onTapCancel() {
    _imageController.reverse();
  }

  void toggleControl() {
    print('toggle pressed');
    setState(() {
      showControl = !showControl;
      if (showControl) {
        _dotController.forward(); // 展开动画
      } else {
        _dotController.reverse(); // 收起动画
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification.metrics.axis == Axis.vertical) {
            // 监听垂直滚动位置
            double offset = notification.metrics.pixels;
            if (offset >= 500.w) {
              setState(() {
                _opacity = 1;
                _opacity = _opacity.clamp(0.0, 1.0); // 确保透明度在 [0, 1]
              });
            } else {
              setState(() {
                _opacity = 0;
                _opacity = _opacity.clamp(0.0, 1.0); // 确保透明度在 [0, 1]
              });
            }
          }
          return false;
        },
        child: Stack(
          children: [
            Container(
              // margin: EdgeInsets.symmetric(horizontal: 80.w),
              child: CustomScrollView(
                slivers: [
                  SliverStickyHeader(
                    header: Container(
                      padding: EdgeInsets.only(top: 0.1.sh),
                      margin: EdgeInsets.symmetric(horizontal: 80.w),
                      color: Colors.white,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '发布',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 90.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.w),
                          Container(
                            color: kDevideColor,
                            height: 2.w,
                            width: 1.sw,
                          ),
                          publishButton(
                              CupertinoIcons.archivebox_fill, '闲置物品', () {}),
                          Container(
                            color: kDevideColor,
                            height: 2.w,
                            width: 1.sw,
                          ),
                          publishButton(
                              CupertinoIcons.hare_fill, '校园跑腿', () {}),
                          Container(
                            color: kDevideColor,
                            height: 2.w,
                            width: 1.sw,
                          ),
                          publishButton(
                              CupertinoIcons.person_3_fill, '组团活动', () {}),
                          Container(
                            color: kDevideColor,
                            height: 2.w,
                            width: 1.sw,
                          ),
                        ],
                      ),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Container(
                            padding: EdgeInsets.only(bottom: 80.w),
                            margin: EdgeInsets.symmetric(horizontal: 80.w),
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  width: 1.sw,
                                  padding: EdgeInsets.symmetric(vertical: 40.w),
                                  child: Text(
                                    '7件物品、1个跑腿、1个活动',
                                    style: TextStyle(
                                      fontSize: 40.sp,
                                      fontWeight: FontWeight.bold,
                                      color: kGrey,
                                    ),
                                  ),
                                ),
                                Container(
                                  color: kDevideColor,
                                  height: 2.w,
                                  width: 1.sw,
                                ),
                                Container(
                                  width: 1.sw,
                                  padding: EdgeInsets.symmetric(vertical: 30.w),
                                  child: Row(
                                    children: [
                                      Text(
                                        '排序方式',
                                        style: TextStyle(
                                          fontSize: 35.sp,
                                          color: kGrey,
                                        ),
                                      ),
                                      SizedBox(width: 30.w),
                                      CupertinoButton(
                                        onPressed: () {},
                                        padding: EdgeInsets.zero,
                                        child: Row(
                                          children: [
                                            Text(
                                              '最近发布',
                                              style: TextStyle(
                                                fontSize: 35.sp,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(width: 20.w),
                                            Icon(
                                              CupertinoIcons.chevron_down,
                                              size: 30.w,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isGrid = !isGrid;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(10.w),
                                          decoration: BoxDecoration(
                                            color: isGrid
                                                ? Colors.transparent
                                                : Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                          ),
                                          child: Icon(
                                            CupertinoIcons.list_bullet,
                                            size: 70.w,
                                            color: isGrid
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: 1,
                      ),
                    ),
                  ),
                  isGrid
                      ? Obx(
                          () => SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 60.w,
                              childAspectRatio: 493 / 765,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                ItemModel item =
                                    publishController.publishList[index];
                                // 计算左右间距
                                double leftMargin =
                                    index % 2 == 0 ? 80.w : 0; // 左侧元素加左边距
                                double rightMargin =
                                    index % 2 == 1 ? 80.w : 0; // 右侧元素加右边距
                                return Container(
                                    margin: EdgeInsets.only(
                                      left: leftMargin, // 左侧动态边距
                                      right: rightMargin, // 右侧动态边距
                                      top: index < 2 ? 50.w : 0,
                                      bottom: index > 7 ? 80.w : 0,
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTapUp: _onTapUp,
                                          onTapCancel: _onTapCancel,
                                          child: ScaleTransition(
                                            scale: _animation,
                                            child: Container(
                                              width: 1.sw,
                                              height: 580.w,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    replaceLocalhost(
                                                        item.images[0]),
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                                color: CupertinoColors
                                                    .extraLightBackgroundGray,
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color.fromARGB(
                                                        255, 220, 220, 220),
                                                    blurRadius: 20.w,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20.w),
                                        Container(
                                          width: double.infinity,
                                          child: Text(
                                            item.name,
                                            style: TextStyle(
                                              fontSize: 42.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Spacer(),
                                            GestureDetector(
                                              onTapDown:
                                                  (TapDownDetails details) {
                                                // 获取点击位置的坐标
                                                setState(() {
                                                  _coordinates =
                                                      "X: ${details.globalPosition.dx}, Y: ${details.globalPosition.dy}";
                                                  dx = (details.globalPosition
                                                              .dx *
                                                          2)
                                                      .w;
                                                  dy = (details.globalPosition
                                                              .dy *
                                                          2)
                                                      .h;
                                                });
                                                toggleControl();
                                                print(_coordinates);
                                              },
                                              child: Baseline(
                                                baseline: 40.w,
                                                baselineType:
                                                    TextBaseline.alphabetic,
                                                child: Icon(
                                                  CupertinoIcons.ellipsis,
                                                  color: kGrey,
                                                  size: 70.w,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ));
                              },
                              childCount: publishController.publishList.length,
                            ),
                          ),
                        )
                      : Obx(
                          () => SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Column(
                                  children: [
                                    Container(
                                        width: 1.sw,
                                        height: 230.w,
                                        margin: EdgeInsets.symmetric(
                                            vertical: 40.w, horizontal: 80.w),
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            Container(
                                              height: double.infinity,
                                              width: 200.w,
                                              decoration: BoxDecoration(
                                                color: kDevideColor,
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color.fromARGB(
                                                        255, 220, 220, 220),
                                                    blurRadius: 20.w,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        )),
                                    index < 9 - 1
                                        ? Container(
                                            width: 1.sw,
                                            height: 2.w,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 80.w),
                                            color: kDevideColor,
                                          )
                                        : SizedBox(height: 50.w),
                                  ],
                                );
                              },
                              childCount: 9, // 列表项数量
                            ),
                          ),
                        ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Stack(
                children: [
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
                        SizedBox(height: 100.w),
                        AnimatedOpacity(
                          opacity: _opacity,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: Text(
                            '发布',
                            style: kPageTitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _dotController,
              builder: (context, child) {
                double opacity = _dotController.value;
                return Positioned(
                  top: dy > 0.5.sh ? dy - 280.h : dy + 40.h,
                  right: 40.w,
                  child: AnimatedOpacity(
                    opacity: opacity,
                    duration: Duration(milliseconds: 50),
                    child: Container(
                      width: 0.7.sw,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 500.w,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.r),
                              topRight: Radius.circular(30.r),
                            ),
                            child: CupButton(
                              normalColor: Colors.white,
                              onPressed: () {},
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 40.w,
                                  vertical: 25.w,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '查看',
                                      style: TextStyle(
                                        fontSize: 42.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      CupertinoIcons.eye,
                                      size: 60.w,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1.sw,
                            height: 20.w,
                            color: kDevideColor,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30.r),
                              bottomRight: Radius.circular(30.r),
                            ),
                            child: CupButton(
                              normalColor: Colors.white,
                              onPressed: () {},
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 40.w,
                                  vertical: 25.w,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30.r),
                                    bottomRight: Radius.circular(30.r),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '删除',
                                      style: TextStyle(
                                        fontSize: 42.sp,
                                        fontWeight: FontWeight.bold,
                                        color: CupertinoColors.destructiveRed,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      CupertinoIcons.trash,
                                      size: 60.w,
                                      color: CupertinoColors.destructiveRed,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget publishButton(IconData? icon, String data, void Function() onPressed) {
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
              data,
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
}
