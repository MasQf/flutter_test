import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/constants/color.dart';
import 'package:test/constants/text.dart';
import 'package:test/controllers/item.dart';
import 'package:test/controllers/user.dart';
import 'package:test/models/item.dart';
import 'package:test/pages/common/scrolling_title_page.dart';
import 'package:test/pages/publish_detail.dart';
import 'package:test/widgets/button/big_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  UserController userController = Get.find<UserController>();
  ItemController itemController = Get.put(ItemController());

  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  void _initializeAnimations() {
    // 初始化 AnimationController 和 Animation
    _animationControllers = List.generate(
      itemController.latestList.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );

    _animations = _animationControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    itemController.loadLatestList().then((_) {
      _initializeAnimations(); // 数据加载完成后初始化动画
      setState(() {}); // 刷新界面
    });
  }

  void _onTapDown(int index, TapDownDetails details) {
    _animationControllers[index].forward();
  }

  void _onTapUp(int index, ItemModel item, TapUpDetails details) {
    _animationControllers[index].forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _animationControllers[index].reverse();
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.to(
          () => PublishDetailPage(
            item: item,
            itemList: itemController.latestList.cast<ItemModel>().toList(),
            initialIndex: index,
          ),
          transition: Transition.cupertino,
          curve: Curves.easeInOut,
          opaque: false,
        );
      });
    });
  }

  void _onTapCancel(int index) {
    _animationControllers[index].reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollingTitlePage(
      title: '发现',
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 80.w),
          child: Column(
            children: [
              Container(
                color: kDevideColor,
                height: 2.w,
                width: 1.sw,
              ),
              bigButton(CupertinoIcons.text_justifyleft, '浏览分区', () {}),
              Container(
                color: kDevideColor,
                height: 2.w,
                width: 1.sw,
              ),
            ],
          ),
        ),
        Container(
          width: 1.sw,
          padding: EdgeInsets.fromLTRB(80.w, 90.w, 80.w, 80.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '最近发布',
                style: TextStyle(
                  fontSize: 60.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5.w),
              Text(
                'Recently released.',
                style: TextStyle(
                  fontSize: 37.sp,
                  color: kGrey,
                ),
              ),
              Obx(
                () => Container(
                  height: 800.w,
                  child: GridView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 40.w,
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 1.2,
                    ),
                    itemCount: itemController.latestList.length,
                    itemBuilder: (context, index) {
                      ItemModel item = itemController.latestList[index];
                      return Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTapDown: (details) =>
                                  _onTapDown(index, details),
                              onTapUp: (details) =>
                                  _onTapUp(index, item, details),
                              onTapCancel: () => _onTapCancel(index),
                              child: ScaleTransition(
                                scale: _animations[index],
                                child: Hero(
                                  tag: 'home${item.id}',
                                  child: Container(
                                    width: 1.sw,
                                    height: 300.w,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          replaceLocalhost(item.images[0]),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      color: CupertinoColors
                                          .extraLightBackgroundGray,
                                      borderRadius: BorderRadius.circular(10.r),
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
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
