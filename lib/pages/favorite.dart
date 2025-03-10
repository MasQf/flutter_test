import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/api/item.dart';
import 'package:test/constants/color.dart';
import 'package:test/constants/text.dart';
import 'package:test/controllers/item.dart';
import 'package:test/controllers/user.dart';
import 'package:test/models/favorite.dart';
import 'package:test/pages/item_detail.dart';
import 'package:test/widgets/button/cup_button.dart';
import 'package:test/widgets/button/pressable_button.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final ItemController itemController = Get.find<ItemController>();
  final UserController userController = Get.find<UserController>();

  bool isLoading = true;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey key1 = GlobalKey();
  final GlobalKey key2 = GlobalKey();
  double _appBarOpacity = 0.0;
  double _titleScale = 1.0;
  bool _isBottomBelowOrEqualTop = false;

  bool isEditing = false; // 是否处于编辑状态
  double _notEditOpacity = 1.0;
  double _editOpacity = 0.0;

  double _imageHeight = 550.h;
  double _imageWidth = 400.w;

  Future<void> loadFavorite() async {
    await itemController.loadFavoriteList();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    loadFavorite();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void checkPosition() {
    final RenderBox renderBox1 =
        key1.currentContext?.findRenderObject() as RenderBox;
    final position1 = renderBox1.localToGlobal(Offset.zero);
    final size1 = renderBox1.size;
    final bottom1 = position1.dy + size1.height; // 第一个 Container 的底部

    final RenderBox renderBox2 =
        key2.currentContext?.findRenderObject() as RenderBox;
    final position2 = renderBox2.localToGlobal(Offset.zero);
    final top2 = position2.dy; // 第二个 Container 的顶部

    _isBottomBelowOrEqualTop = bottom1 >= top2;
  }

  void toggleEditing() {
    setState(() {
      _editOpacity == 1.0 ? _editOpacity = 0.0 : _editOpacity = 1.0;
      _notEditOpacity == 1.0 ? _notEditOpacity = 0.0 : _notEditOpacity = 1.0;
      isEditing = !isEditing;
      _imageHeight = isEditing ? (550 * 0.7).h : 550.h;
      _imageWidth = isEditing ? (400 * 0.7).w : 400.w;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification.metrics.axis == Axis.vertical) {
            double offset = notification.metrics.pixels;
            checkPosition();
            if (_isBottomBelowOrEqualTop) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _appBarOpacity = 1;
                  _appBarOpacity = _appBarOpacity.clamp(0.0, 1.0);
                });
              });
            } else {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _appBarOpacity = 0;
                  _appBarOpacity = _appBarOpacity.clamp(0.0, 1.0);
                  _titleScale = 1.0;
                });
              });
            }

            if (offset <= 0) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _titleScale = (1 - offset / 200).clamp(1.0, 1.2);
                });
              });
            }
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
                child:
                    CustomScrollView(controller: _scrollController, slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.only(top: 0.1.sh),
                      color: Colors.white,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.scale(
                            scale: _titleScale,
                            child: Container(
                              height: 130.w,
                              margin: EdgeInsets.symmetric(horizontal: 80.w),
                              child: Text(
                                '收藏列表',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 90.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.w),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 80.w),
                            child: Column(
                              children: [
                                Container(
                                  key: key2,
                                  color: kDevideColor,
                                  height: 2.h,
                                  width: 1.sw,
                                ),
                              ],
                            ),
                          ),
                          Column(children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 80.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 40.h),
                                  Obx(
                                    () => Text(
                                      '${itemController.favoriteList.length}项',
                                      style: TextStyle(
                                        color: kGrey,
                                        fontSize: 40.sp,
                                        letterSpacing: 6.w,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 40.h),
                                  if (isLoading)
                                    Center(
                                      child: Column(
                                        children: [
                                          CupertinoActivityIndicator(
                                              radius: 30.r),
                                          SizedBox(height: 10.h),
                                          Text(
                                            '正在载入',
                                            style: TextStyle(
                                              fontSize: 35.sp,
                                              color: kGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ])
                        ],
                      ),
                    ),
                  ),
                  sliverList(),
                ]),
              ),
            ),
            Positioned(
              key: key1,
              top: 0,
              left: 0,
              right: 0,
              child: Stack(
                children: [
                  _appBarOpacity == 1
                      ? Positioned(
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
                        )
                      : Positioned(
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
                          color: kDevideColor.withOpacity(_appBarOpacity),
                          width: 2.w,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 90.h),
                        Row(
                          children: [
                            // **左侧返回按钮动态切换为 "全选"**
                            Container(
                              width: 300.w,
                              child: CupertinoButton(
                                onPressed: () {
                                  if (isEditing) {
                                    // 处于编辑状态时，点击 "全选"
                                    print("全选按钮点击");
                                  } else {
                                    // 非编辑状态，点击返回
                                    Get.back();
                                  }
                                },
                                padding: EdgeInsets.zero,
                                child: Row(
                                  children: [
                                    SizedBox(width: 40.w),
                                    Stack(
                                      children: [
                                        AnimatedOpacity(
                                          opacity: _notEditOpacity,
                                          duration: Duration(milliseconds: 200),
                                          curve: Curves.easeInOut,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 50.w,
                                                child: Icon(
                                                  CupertinoIcons.chevron_back,
                                                  size: 70.w,
                                                  color: isEditing
                                                      ? Colors.transparent
                                                      : kMainColor,
                                                ),
                                              ),
                                              Text(
                                                '返回',
                                                style: TextStyle(
                                                  fontSize: 45.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: kMainColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        AnimatedOpacity(
                                          opacity: _editOpacity,
                                          duration: Duration(milliseconds: 200),
                                          curve: Curves.easeInOut,
                                          child: Text(
                                            '全选',
                                            style: TextStyle(
                                              fontSize: 45.sp,
                                              fontWeight: FontWeight.bold,
                                              color: kMainColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Spacer(),
                            AnimatedOpacity(
                              opacity: _appBarOpacity,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: Container(
                                height: 80.h,
                                child: Text(
                                  '收藏列表',
                                  style: kPageTitle,
                                ),
                              ),
                            ),
                            Spacer(),
                            // **右侧 “编辑” 按钮切换成 “完成”**
                            Container(
                              width: 300.w,
                              child: CupertinoButton(
                                onPressed: toggleEditing,
                                padding: EdgeInsets.zero,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Stack(
                                      children: [
                                        AnimatedOpacity(
                                          opacity: _editOpacity,
                                          duration: Duration(milliseconds: 200),
                                          curve: Curves.easeInOut,
                                          child: Text(
                                            '完成',
                                            style: TextStyle(
                                              fontSize: 45.sp,
                                              fontWeight: FontWeight.bold,
                                              color: kMainColor,
                                            ),
                                          ),
                                        ),
                                        AnimatedOpacity(
                                          opacity: _notEditOpacity,
                                          duration: Duration(milliseconds: 200),
                                          curve: Curves.easeInOut,
                                          child: Text(
                                            '编辑',
                                            style: TextStyle(
                                              fontSize: 45.sp,
                                              fontWeight: FontWeight.bold,
                                              color: kMainColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 40.w),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isEditing)
              Positioned(
                bottom: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(
                      height: 210.h,
                      width: 1.sw,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            if (isEditing)
              Positioned(
                bottom: 0,
                child: bottomBar(),
              ),
          ],
        ),
      ),
    );
  }

  Widget sliverList() {
    return SliverList.builder(
      itemCount: itemController.favoriteList.length,
      itemBuilder: (context, index) {
        FavoriteModel item = itemController.favoriteList[index];
        return Obx(
          () => Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    item.item.isSelected = !item.item.isSelected;
                  });
                },
                child: Row(
                  children: [
                    if (isEditing)
                      Row(
                        children: [
                          SizedBox(width: 50.w),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                                color: item.item.isSelected
                                    ? kMainColor
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: item.item.isSelected
                                      ? kMainColor
                                      : kArrowGrey,
                                  width: 6.w,
                                )),
                            child: Center(
                              child: Icon(
                                CupertinoIcons.checkmark,
                                color: Colors.white,
                                size: 40.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    Container(
                      width: isEditing ? 1.sw - 80.w - 50.w : 1.sw,
                      padding: EdgeInsets.only(
                          left: isEditing ? 40.w : 80.w,
                          right: 80.w,
                          top: 60.h,
                          bottom: 60.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          // 图片
                          Stack(
                            children: [
                              PressableButton(
                                onPressed: () {
                                  if (isEditing) {
                                    setState(() {
                                      item.item.isSelected =
                                          !item.item.isSelected;
                                    });
                                  } else {
                                    Get.to(
                                      () => ItemDetailPage(item: item.item),
                                      transition: Transition.cupertino,
                                    );
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  height: _imageHeight,
                                  width: _imageWidth,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        replaceLocalhost(item.item.images[0]),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color.fromARGB(255, 199, 199, 199),
                                        blurRadius: 20.w,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isEditing && !item.item.isSelected)
                                Positioned.fill(
                                    child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ))
                            ],
                          ),
                          SizedBox(width: isEditing ? 40.w : 60.w),
                          Container(
                            width: 1.sw - 160.w - 400.w - 60.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  height: isEditing ? _imageHeight : 200.h,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${item.item.name}',
                                        style: TextStyle(
                                          fontSize: 45.sp,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 2,
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        '${item.item.owner.name}',
                                        style: TextStyle(
                                          fontSize: 32.sp,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isEditing)
                                  Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          '${item.item.description}',
                                          style: TextStyle(
                                            fontSize: 32.sp,
                                            color: kGrey,
                                          ),
                                          maxLines: 4,
                                        ),
                                        SizedBox(height: 30.h),
                                        PressableButton(
                                          onPressed: () {},
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5.h),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(50.r),
                                              border: Border.all(
                                                color: kMainColor,
                                                width: 5.w,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'RMB￥${item.item.price}',
                                                style: TextStyle(
                                                  fontSize: 32.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              index != itemController.favoriteList.length - 1
                  ? Container(
                      width: 1.sw,
                      height: 2.h,
                      margin: EdgeInsets.only(
                          left: isEditing ? 150.w : 80.w, right: 80.w),
                      color: kDevideColor,
                    )
                  : SizedBox(height: isEditing ? 250.h : 120.h)
            ],
          ),
        );
      },
    );
  }

  Widget bottomBar() {
    return Container(
      width: 1.sw,
      height: 210.h,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: kDevideColor,
            width: 2.w,
          ),
        ),
      ),
      padding: EdgeInsets.only(left: 40.w, right: 40.w, top: 30.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(),
          itemController.hasSelectedFavorites()
              ? CupertinoButton(
                  onPressed: () async {
                    deleteFavorites();
                    setState(() {});
                  },
                  pressedOpacity: 0.4,
                  padding: EdgeInsets.zero,
                  child: Icon(
                    CupertinoIcons.trash,
                    color: kMainColor,
                    size: 80.w,
                  ),
                )
              : CupertinoButton(
                  onPressed: () {},
                  pressedOpacity: 1,
                  padding: EdgeInsets.zero,
                  child: Icon(
                    CupertinoIcons.trash,
                    color: kIconGrey,
                    size: 80.w,
                  ),
                ),
        ],
      ),
    );
  }

  void deleteFavorites() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      barrierColor: Colors.black.withOpacity(0.2),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: 1.sw,
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                width: 1.sw,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                      child: CupButton(
                        pressedColor: Color(0xFFdbdbdd),
                        onPressed: () {},
                        child: Container(
                          width: 1.sw,
                          padding: EdgeInsets.symmetric(vertical: 30.w),
                          child: Center(
                            child: Text(
                              '从此列表中移除。',
                              style: TextStyle(
                                fontSize: 35.sp,
                                color: kGrey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1.sw,
                      color: kDevideColor,
                      height: 2.w,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.r),
                        bottomRight: Radius.circular(30.r),
                      ),
                      child: CupButton(
                        pressedColor: Color(0xFFdbdbdd),
                        onPressed: () async {
                          Get.back();
                          await itemController.removeSelectedFavorites();
                        },
                        child: Container(
                          width: 1.sw,
                          padding: EdgeInsets.symmetric(vertical: 30.w),
                          child: Center(
                            child: Text(
                              '从“收藏列表”移除',
                              style: TextStyle(
                                fontSize: 55.sp,
                                fontWeight: FontWeight.bold,
                                color: kBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.w),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30.r),
                      child: CupButton(
                        pressedColor: Color(0xFFdbdbdd),
                        onPressed: () {
                          Get.back();
                        },
                        child: Container(
                          width: 1.sw,
                          padding: EdgeInsets.symmetric(vertical: 30.w),
                          child: Center(
                            child: Text(
                              '取消',
                              style: TextStyle(
                                fontSize: 55.sp,
                                fontWeight: FontWeight.bold,
                                color: kBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
