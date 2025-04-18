import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/api/item.dart';
import 'package:test/constants/color.dart';
import 'package:test/constants/text.dart';
import 'package:test/controllers/publish.dart';
import 'package:test/controllers/user.dart';
import 'package:test/models/item.dart';
import 'package:test/pages/item_detail.dart';
import 'package:test/pages/publish_item.dart';
import 'package:test/widgets/button/big_button.dart';
import 'package:test/widgets/button/cup_button.dart';
import 'package:test/widgets/button/pressable_button.dart';

// 定义排序方式枚举
enum SortMethod {
  latest, // 最近发布
  mostFavorites, // 最多收藏
  mostViews // 最多浏览
}

class PublishPage extends StatefulWidget {
  const PublishPage({super.key});

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage>
    with TickerProviderStateMixin {
  PublishController publishController = Get.put(PublishController());
  UserController userController = Get.find<UserController>();
  final ScrollController _scrollController = ScrollController();

  double _opacity = 0.0; // 用于控制导航栏透明度

  bool showControl = false;
  double dx = 0.w;
  double dy = 0.h;

  bool isGrid = true;

  // 当前排序方式
  SortMethod currentSortMethod = SortMethod.latest;

  late AnimationController _dotController;

  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  void _initializeAnimations() {
    // 初始化 AnimationController 和 Animation
    _animationControllers = List.generate(
      publishController.publishList.length,
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

  // 切换排序方式
  void _toggleSortMethod() {
    setState(() {
      // 按照最近发布 -> 最多收藏 -> 最多浏览 -> 最近发布的顺序循环
      switch (currentSortMethod) {
        case SortMethod.latest:
          currentSortMethod = SortMethod.mostFavorites;
          break;
        case SortMethod.mostFavorites:
          currentSortMethod = SortMethod.mostViews;
          break;
        case SortMethod.mostViews:
          currentSortMethod = SortMethod.latest;
          break;
      }

      // 应用新的排序方式
      _applySortMethod();
    });
  }

  // 应用排序方法
  void _applySortMethod() {
    switch (currentSortMethod) {
      case SortMethod.latest:
        // 按发布时间排序（最新的在前）
        publishController.publishList
            .sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortMethod.mostFavorites:
        // 按收藏数排序
        publishController.publishList
            .sort((a, b) => b.favoritesCount.compareTo(a.favoritesCount));
        break;
      case SortMethod.mostViews:
        // 按浏览量排序
        publishController.publishList
            .sort((a, b) => b.views.compareTo(a.views));
        break;
    }
  }

  // 获取当前排序方式的显示文本
  String _getSortMethodText() {
    switch (currentSortMethod) {
      case SortMethod.latest:
        return '最近发布';
      case SortMethod.mostFavorites:
        return '最多收藏';
      case SortMethod.mostViews:
        return '最多浏览';
    }
  }

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    // 加载数据并监听
    publishController
        .loadPublishList(userId: userController.id.value)
        .then((_) {
      _initializeAnimations(); // 数据加载完成后初始化动画
      _applySortMethod(); // 应用默认排序方式
      setState(() {}); // 刷新界面
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _dotController.dispose();
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTapDown(int index, TapDownDetails details) {
    _animationControllers[index].forward();
    showControl = false;
    _dotController.reverse();
  }

  void _onTapUp(int index, ItemModel item, TapUpDetails details) {
    _animationControllers[index].forward();
    showControl = false;
    _dotController.reverse();
    Future.delayed(const Duration(milliseconds: 200), () {
      _animationControllers[index].reverse();
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.to(
          () => ItemDetailPage(item: item, canBuy: false),
          transition: Transition.cupertino,
        );
      });
    });
  }

  void _onTapCancel(int index) {
    _animationControllers[index].reverse();
    showControl = false;
    _dotController.reverse();
  }

  String? _currentButtonId; // 当前激活弹窗的按钮ID

  void toggleControl(TapDownDetails details, String buttonId) {
    setState(() {
      final newDx = (details.globalPosition.dx * 2).w;
      final newDy = (details.globalPosition.dy * 2).h;

      // 如果当前是同一个按钮，则直接关闭弹窗
      if (showControl && _currentButtonId == buttonId) {
        showControl = false;
        _dotController.reverse(); // 收起动画
        return;
      }

      // 更新状态和位置
      dx = newDx;
      dy = newDy;
      _currentButtonId = buttonId;
      showControl = true;
      _dotController.forward(); // 展开动画
    });
  }

  /// 提取 double 类型的小数点左边和右边的部分
  Map<String, dynamic> extractParts(double value) {
    // 转换为字符串，方便分割
    String valueStr = value.toString();

    // 按小数点分割
    List<String> parts = valueStr.split('.');

    // 获取整数部分和小数部分
    String integerPartStr = parts[0]; // 左边部分
    String fractionalPartStr = parts.length > 1 ? parts[1] : "0"; // 右边部分

    // 返回整数部分和小数部分，字符串和数值两种形式
    return {
      'integerPartStr': integerPartStr, // 整数部分（字符串形式）
      'fractionalPartStr': fractionalPartStr, // 小数部分（字符串形式）
      'integerPart': int.parse(integerPartStr), // 整数部分（整数形式）
      'fractionalPart': int.parse(fractionalPartStr), // 小数部分（整数形式）
    };
  }

  Color _getCategoryColor(String category) {
    if (category == "闲置物品") {
      return Color(0xFF1b4588); // 蓝色
    } else if (category == "组织活动") {
      return Color(0xFFf09a37); // 橙色
    } else if (category == "校园跑腿") {
      return Colors.black; // 黑色
    } else {
      return kGrey; // 默认颜色
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          setState(() {
            showControl = false;
            _dotController.reverse();
          });
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification.metrics.axis == Axis.vertical) {
              // 监听垂直滚动位置
              double offset = notification.metrics.pixels;
              if (offset >= 445.w) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _opacity = 1;
                    _opacity = _opacity.clamp(0.0, 1.0); // 确保透明度在 [0, 1]
                  });
                });
              } else {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _opacity = 0;
                    _opacity = _opacity.clamp(0.0, 1.0); // 确保透明度在 [0, 1]
                  });
                });
              }
              showControl = false;
              _dotController.reverse();
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
                  child: CustomScrollView(
                    controller: _scrollController,
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
                              Container(
                                height: 130.w,
                                child: Text(
                                  '发布',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 90.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.w),
                              Container(
                                color: kDevideColor,
                                height: 2.w,
                                width: 1.sw,
                              ),
                              bigButton(CupertinoIcons.archivebox_fill, '闲置物品',
                                  () {
                                Get.to(
                                  () => PublishItemPage(
                                    category: '闲置物品',
                                  ),
                                  transition: Transition.cupertino,
                                );
                              }),
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
                                margin: EdgeInsets.symmetric(horizontal: 80.w),
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 1.sw,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 40.w),
                                      child: Text(
                                        '${publishController.publishList.length}件物品',
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
                                      padding:
                                          EdgeInsets.symmetric(vertical: 30.w),
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
                                            onPressed: () {
                                              _toggleSortMethod(); // 切换排序方式
                                            },
                                            padding: EdgeInsets.zero,
                                            child: Row(
                                              children: [
                                                Text(
                                                  _getSortMethodText(), // 显示当前排序方式
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
                                                showControl = false;
                                                _dotController.reverse();
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
                                  childAspectRatio: 493 / 815,
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
                                        bottom: 0,
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          PressableButton(
                                            onPressed: () {},
                                            child: GestureDetector(
                                              onTapDown: (details) =>
                                                  _onTapDown(index, details),
                                              onTapUp: (details) => _onTapUp(
                                                  index, item, details),
                                              onTapCancel: () =>
                                                  _onTapCancel(index),
                                              child: Container(
                                                width: 1.sw,
                                                height: 580.w,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                      replaceLocalhost(
                                                          item.images[0]),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  color: CupertinoColors
                                                      .extraLightBackgroundGray,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.r),
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
                                          SizedBox(height: 10.w),
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
                                              Text(
                                                '￥',
                                                style: TextStyle(
                                                  fontSize: 30.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: kMainColor,
                                                ),
                                              ),
                                              Text(
                                                '${extractParts(item.price)['integerPartStr']}',
                                                style: TextStyle(
                                                  fontSize: 60.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: kMainColor,
                                                ),
                                              ),
                                              Text(
                                                '.',
                                                style: TextStyle(
                                                  fontSize: 37.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: kMainColor,
                                                ),
                                              ),
                                              Text(
                                                extractParts(item.price)[
                                                    'fractionalPartStr'],
                                                style: TextStyle(
                                                  fontSize: 37.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: kMainColor,
                                                ),
                                              ),
                                              Spacer(),
                                              CupertinoButton(
                                                  padding: EdgeInsets.zero,
                                                  child: Icon(
                                                    CupertinoIcons.trash,
                                                    color: kGrey,
                                                    size: 60.w,
                                                  ),
                                                  onPressed: () {
                                                    publishController.deleteItem(
                                                        itemId:
                                                            _currentButtonId!);
                                                  })
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  childCount:
                                      publishController.publishList.length,
                                ),
                              ),
                            )
                          : Obx(
                              () => SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    ItemModel item =
                                        publishController.publishList[index];

                                    return Column(
                                      children: [
                                        Container(
                                            width: 1.sw,
                                            height: 260.w,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 40.w,
                                                horizontal: 80.w),
                                            color: Colors.transparent,
                                            child: Row(
                                              children: [
                                                PressableButton(
                                                  onPressed: () {},
                                                  child: GestureDetector(
                                                    onTapDown: (details) =>
                                                        _onTapDown(
                                                            index, details),
                                                    onTapUp: (details) =>
                                                        _onTapUp(index, item,
                                                            details),
                                                    onTapCancel: () =>
                                                        _onTapCancel(index),
                                                    child: Container(
                                                      height: double.infinity,
                                                      width: 200.w,
                                                      decoration: BoxDecoration(
                                                        color: kDevideColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.r),
                                                        image: DecorationImage(
                                                          image:
                                                              CachedNetworkImageProvider(
                                                            replaceLocalhost(
                                                                item.images[0]),
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    220,
                                                                    220,
                                                                    220),
                                                            blurRadius: 20.w,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 35.w),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 30.w),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: 600.w,
                                                        child: Text(
                                                          item.name,
                                                          style: TextStyle(
                                                            fontSize: 37.sp,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            height: 2.w,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 600.w,
                                                        child: Text(
                                                          item.description,
                                                          style: TextStyle(
                                                            fontSize: 35.sp,
                                                            color: kGrey,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 600.w,
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  '￥',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        30.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        kMainColor,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${extractParts(item.price)['integerPartStr']}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        50.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        kMainColor,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '.',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        37.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        kMainColor,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  extractParts(item
                                                                          .price)[
                                                                      'fractionalPartStr'],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        37.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        kMainColor,
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              10.w),
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          15.w,
                                                                      vertical:
                                                                          5.w),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: _getCategoryColor(
                                                                        item.category),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            200.r),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      item.category,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            30.sp,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      textHeightBehavior:
                                                                          TextHeightBehavior(
                                                                        applyHeightToFirstAscent:
                                                                            false,
                                                                        applyHeightToLastDescent:
                                                                            false,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                if (item
                                                                    .isNegotiable)
                                                                  Container(
                                                                    margin: EdgeInsets.only(
                                                                        right: 10
                                                                            .w),
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal: 15
                                                                            .w,
                                                                        vertical:
                                                                            5.w),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .green,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              200.r),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        '可议价',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              30.sp,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        textHeightBehavior:
                                                                            TextHeightBehavior(
                                                                          applyHeightToFirstAscent:
                                                                              false,
                                                                          applyHeightToLastDescent:
                                                                              false,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                SizedBox(
                                                                    width:
                                                                        30.w),
                                                              ],
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTapDown:
                                                                (TapDownDetails
                                                                    details) {
                                                              publishController
                                                                  .deleteItem(
                                                                      itemId:
                                                                          _currentButtonId!);
                                                            },
                                                            child: Icon(
                                                              CupertinoIcons
                                                                  .trash,
                                                              color: kGrey,
                                                              size: 60.w,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
                                        index <
                                                publishController
                                                        .publishList.length -
                                                    1
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
                                  childCount: publishController
                                      .publishList.length, // 列表项数量
                                ),
                              ),
                            ),
                    ],
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
