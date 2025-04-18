import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/api/item.dart';
import 'package:test/api/trade.dart';
import 'package:test/constants/color.dart';
import 'package:test/controllers/deal.dart';
import 'package:test/controllers/user.dart';
import 'package:test/models/item.dart';
import 'package:test/pages/campus_map_page.dart';
import 'package:test/pages/chat/chat_detail.dart';
import 'package:test/pages/photo_view.dart';
import 'package:test/widgets/button/cup_button.dart';
import 'package:test/widgets/expandable_text.dart';

class ItemDetailPage extends StatefulWidget {
  final ItemModel item;
  final bool canBuy;

  const ItemDetailPage({
    super.key,
    required this.item,
    this.canBuy = true,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final UserController userController = Get.find<UserController>();
  final DealController dealController = Get.find<DealController>();

  final double imageHeight = 0.7.sh;
  late ItemModel item;

  final ScrollController _scrollController = ScrollController();

  Future<void> _loadItem() async {
    item = await ItemApi.item(itemId: widget.item.id);
    setState(() {});
  }

  late PageController _bannerController;
  int _bannerIndex = 0;

  // late PageController _commentController;
  // int _commentIndex = 0;

  final GlobalKey deviderKey = GlobalKey();
  double topHeight = 0;

  // 默认初始值
  DateTime _date = DateTime.now();
  Duration _time = Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute);

  // 显示日期和时间选择器
  Future<void> _showDateTimePicker(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 0.4.sh,
          color: CupertinoColors.white,
          child: Column(
            children: [
              SizedBox(height: 40.h),
              Row(
                children: [
                  // 日期选择器
                  Container(
                    width: 0.5.sw,
                    height: 400.h,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: _date,
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() {
                          _date = newDate;
                        });
                      },
                    ),
                  ),
                  // 时间选择器
                  Container(
                    width: 0.5.sw,
                    height: 400.h,
                    child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.hm,
                      initialTimerDuration: _time,
                      onTimerDurationChanged: (Duration newDuration) {
                        setState(() {
                          _time = newDuration;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 80.h),
              // 确认按钮
              CupertinoButton(
                onPressed: () {
                  setState(() {
                    dealController.date.value = DateTime(
                      _date.year,
                      _date.month,
                      _date.day,
                      _time.inHours,
                      _time.inMinutes % 60,
                    );
                  });
                  Get.back();
                },
                padding: EdgeInsets.zero,
                child: Container(
                  width: 1.sw,
                  height: 130.h,
                  margin: EdgeInsets.symmetric(horizontal: 80.w),
                  decoration: BoxDecoration(
                    color: kMainColor,
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: Center(
                    child: Text(
                      '确认',
                      style: TextStyle(
                        fontSize: 50.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    item = widget.item;

    _bannerController = PageController(initialPage: 0);
    // _commentController = PageController(initialPage: 0);
    ItemApi.view(itemId: item.id); // 浏览数+1
    _loadItem();
    _scrollController.addListener(_checkIfContainerReachesTop);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkIfContainerReachesTop);
    _scrollController.dispose();
    _bannerController.dispose();
    // _commentController.dispose();
    super.dispose();
  }

  void _checkIfContainerReachesTop() {
    // 获取 devider 的渲染对象
    final RenderBox? renderBox = deviderKey.currentContext?.findRenderObject() as RenderBox;
    if (renderBox == null) return;

    // 获取 devider 在屏幕中的位置
    final Offset containerPosition = renderBox.localToGlobal(Offset.zero);

    // // 获取 devider 的高度
    // final double containerHeight = renderBox.size.height;

    // 判断 devider 是否触碰到了屏幕顶部
    if (containerPosition.dy <= 0) {
      setState(() {
        topHeight = 200.h;
      });
    } else {
      setState(() {
        topHeight = 0;
      });
    }
  }

  void _showBuy({required ItemModel item}) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: false,
        // barrierColor: Colors.black.withOpacity(0),
        builder: (context) {
          return Container(
            width: 1.sw,
            height: 0.7.sh,
            decoration: BoxDecoration(
              color: kBackColor,
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: Offset(0, -3),
                )
              ],
            ),
            child: Stack(
              children: [
                Container(
                  width: 1.sw,
                  padding: EdgeInsets.only(top: 170.h),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Row(
                          children: [
                            CupertinoButton(
                              onPressed: () {
                                Get.to(
                                  PhotoViewPage(images: item.images, initialIndex: 0),
                                  transition: Transition.cupertino,
                                );
                              },
                              padding: EdgeInsets.zero,
                              child: Container(
                                width: 300.w,
                                height: 300.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        replaceLocalhost(item.images[0]),
                                      ),
                                      fit: BoxFit.cover,
                                    )),
                              ),
                            ),
                            SizedBox(width: 30.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 1.sw - 80.w - 300.w - 30.w,
                                  child: Text(
                                    item.description,
                                    style: TextStyle(
                                      fontSize: 35.sp,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'RMB￥${item.price}',
                                  style: TextStyle(
                                    fontSize: 45.sp,
                                    fontWeight: FontWeight.bold,
                                    color: kMainColor,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Container(
                        width: 1.sw,
                        height: 2.h,
                        color: kDevideColor,
                      ),
                      CupButton(
                        onPressed: () {
                          Get.to(() => CampusMapPage(), transition: Transition.cupertino);
                        },
                        child: Container(
                          width: 1.sw,
                          height: 200.h,
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Row(
                            children: [
                              Text(
                                '📍',
                                style: TextStyle(fontSize: 80.w),
                              ),
                              Container(
                                width: 0.68.sw,
                                child: Obx(
                                  () => Text(
                                    dealController.location.value != '' ? dealController.location.value : '选择交易地点',
                                    style: TextStyle(
                                      fontSize: 40.sp,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Icon(
                                CupertinoIcons.chevron_forward,
                                size: 70.w,
                                color: kArrowGrey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 1.sw,
                        height: 2.h,
                        color: kDevideColor,
                      ),
                      CupButton(
                          onPressed: () {
                            _showDateTimePicker(context);
                          },
                          child: Container(
                            width: 1.sw,
                            height: 200.h,
                            padding: EdgeInsets.symmetric(horizontal: 40.w),
                            child: Row(
                              children: [
                                Text(
                                  ' 📅 ',
                                  style: TextStyle(fontSize: 60.w),
                                ),
                                Container(
                                  width: 0.68.sw,
                                  child: Obx(
                                    () => Text(
                                      dealController.date.value != null
                                          ? '交易时间:\n ${dealController.formatDate}'
                                          : '尚未选择交易时间',
                                      style: TextStyle(
                                        fontSize: 40.sp,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  CupertinoIcons.chevron_forward,
                                  size: 70.w,
                                  color: kArrowGrey,
                                ),
                              ],
                            ),
                          )),
                      Spacer(),
                      CupertinoButton(
                        onPressed: () async {
                          Get.back();
                          Get.back();
                          await TradeApi.createTrade(
                              sellerId: item.owner.id,
                              buyerId: userController.id.value,
                              itemId: item.id,
                              location: dealController.location.value,
                              tradeTime: dealController.formatDate);
                        },
                        padding: EdgeInsets.zero,
                        child: Container(
                          width: 1.sw,
                          height: 130.h,
                          margin: EdgeInsets.symmetric(horizontal: 80.w),
                          decoration: BoxDecoration(
                            color: kMainColor,
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: Center(
                            child: Text(
                              '发起',
                              style: TextStyle(
                                fontSize: 50.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 150.h),
                    ],
                  ),
                ),
                Container(
                  width: 1.sw,
                  height: 130.h,
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: kDevideColor, width: 2.w))),
                  child: Stack(
                    children: [
                      Positioned(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.r),
                            topRight: Radius.circular(30.r),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                            child: Container(
                              width: 1.sw,
                              height: 130.w,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.w),
                          child: Row(
                            children: [
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {},
                                child: Text(
                                  '完成',
                                  style: TextStyle(
                                    fontSize: 45.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Text(
                                '发起交易',
                                style: TextStyle(
                                  fontSize: 45.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Spacer(),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text(
                                  '取消',
                                  style: TextStyle(
                                    fontSize: 45.sp,
                                    fontWeight: FontWeight.bold,
                                    color: kMainColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void _showFavoriteDialog(BuildContext context, {bool isFavorite = true}) {
    // 创建一个OverlayEntry
    OverlayEntry? overlayEntry;

    // 透明度状态
    double opacity = 0.0;

    // 更新透明度并触发重建
    void updateOpacity(double newOpacity) {
      opacity = newOpacity;
      overlayEntry?.markNeedsBuild(); // 强制重建OverlayEntry
    }

    overlayEntry = OverlayEntry(
      builder: (context) => IgnorePointer(
        ignoring: true,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Stack(
              children: [
                AnimatedOpacity(
                  opacity: opacity, // 动态透明度
                  duration: Duration(milliseconds: 200),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                      child: Container(
                        width: ((1080 - 160) / 1080).sw - 80.w,
                        height: 0.4.sh,
                        color: Colors.white.withOpacity(0.7), // 半透明背景
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: opacity, // 动态透明度
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    width: ((1080 - 160) / 1080).sw - 80.w,
                    height: 0.45.sh,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.r),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 80.h),
                        Icon(
                          isFavorite ? CupertinoIcons.text_badge_checkmark : CupertinoIcons.text_badge_minus,
                          color: Color(0xFF555555),
                          size: 300.w,
                        ),
                        SizedBox(height: 130.h),
                        Text(
                          isFavorite ? '已收藏' : '已移除',
                          style: TextStyle(
                            fontSize: 60.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          isFavorite ? '已收藏至"个人"的"收藏列表"中。' : '已从"收藏列表"移除。',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40.sp,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 插入OverlayEntry
    Overlay.of(context).insert(overlayEntry);

    Future.delayed(Duration(milliseconds: 10), () {
      updateOpacity(1.0);
    });

    // 开始透明度动画
    Future.delayed(Duration(milliseconds: 2500), () {
      updateOpacity(0.0);

      // 等待动画完成后移除OverlayEntry
      Future.delayed(Duration(milliseconds: 500), () {
        overlayEntry?.remove();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CupertinoScrollbar(
            controller: _scrollController,
            thickness: 10.w,
            thicknessWhileDragging: 16.w,
            radius: Radius.circular(10.r),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  banner(), // 轮播图
                  Container(
                    width: 1.sw,
                    padding: EdgeInsets.symmetric(vertical: 80.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 80.w),
                          child: Column(
                            children: [
                              Text(
                                item.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 80.sp,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 30.h),
                              CupertinoButton(
                                onPressed: () {
                                  //
                                },
                                padding: EdgeInsets.zero,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    item.owner.avatar != ''
                                        ? Container(
                                            width: 90.w,
                                            height: 90.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  replaceLocalhost(item.owner.avatar),
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: 90.w,
                                            height: 90.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: kDevideColor,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                CupertinoIcons.person_fill,
                                                size: 60.w,
                                                color: kGrey,
                                              ),
                                            ),
                                          ),
                                    SizedBox(width: 20.w),
                                    Text(
                                      '${item.owner.name}',
                                      style: TextStyle(
                                        fontSize: 50.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Icon(
                                      CupertinoIcons.chevron_forward,
                                      color: kArrowGrey,
                                      size: 50.w,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 50.h),
                              //
                              if (widget.canBuy)
                                CupertinoButton(
                                  onPressed: () {
                                    _showBuy(item: item);
                                  },
                                  padding: EdgeInsets.zero,
                                  child: Container(
                                    width: 1.sw,
                                    padding: EdgeInsets.symmetric(vertical: 30.h),
                                    decoration: BoxDecoration(
                                      color: kMainColor,
                                      border: Border.all(
                                        color: kMainColor,
                                        width: 5.w,
                                      ),
                                      borderRadius: BorderRadius.circular(200.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '购买',
                                          style: TextStyle(
                                            fontSize: 45.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 20.w),
                                        Container(
                                          width: 4.w,
                                          height: 50.h,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 20.w),
                                        Text(
                                          'RMB￥${item.price}',
                                          style: TextStyle(
                                            fontSize: 45.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              SizedBox(height: 30.w),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: CupertinoButton(
                                      onPressed: () {
                                        if (!item.isFavorite) {
                                          _showFavoriteDialog(context);
                                          setState(() {
                                            item.isFavorite = true;
                                          });
                                          ItemApi.favorite(itemId: item.id);
                                        } else {
                                          _showFavoriteDialog(context, isFavorite: false);
                                          setState(() {
                                            item.isFavorite = false;
                                          });
                                          ItemApi.unFavorite(itemId: item.id);
                                        }
                                      },
                                      padding: EdgeInsets.zero,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 30.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: kMainColor,
                                            width: 5.w,
                                          ),
                                          borderRadius: BorderRadius.circular(200.r),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              item.isFavorite
                                                  ? CupertinoIcons.checkmark_circle_fill
                                                  : CupertinoIcons.plus_circle_fill,
                                              size: 50.w,
                                              color: kMainColor,
                                            ),
                                            SizedBox(width: 10.w),
                                            Text(
                                              item.isFavorite ? '已收藏' : '收藏',
                                              style: TextStyle(
                                                fontSize: 45.sp,
                                                color: kMainColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (widget.canBuy) SizedBox(width: 30.w),
                                  if (widget.canBuy)
                                    Expanded(
                                      flex: 1,
                                      child: CupertinoButton(
                                        onPressed: () {
                                          Get.to(
                                            () => ChatDetailPage(
                                              senderId: userController.id.value,
                                              receiverId: item.owner.id,
                                              targetName: item.owner.name,
                                              targetAvatar: item.owner.avatar,
                                            ),
                                            transition: Transition.cupertino,
                                          );
                                        },
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 30.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: kMainColor,
                                              width: 5.w,
                                            ),
                                            borderRadius: BorderRadius.circular(200.r),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                CupertinoIcons.ellipses_bubble_fill,
                                                size: 50.w,
                                                color: kMainColor,
                                              ),
                                              SizedBox(width: 10.w),
                                              Text(
                                                '想要',
                                                style: TextStyle(
                                                  fontSize: 45.sp,
                                                  color: kMainColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 80.w),
                        Container(
                          key: deviderKey,
                          width: 1.sw,
                          height: 2.w,
                          margin: EdgeInsets.symmetric(horizontal: 80.w),
                          color: kDevideColor,
                        ),
                        SizedBox(height: 80.w),
                        description(), // 描述
                        SizedBox(height: 80.w),
                        info(), // 信息
                        SizedBox(height: 80.w),
                        Container(
                          width: 1.sw,
                          height: 2.w,
                          margin: EdgeInsets.symmetric(horizontal: 80.w),
                          color: kDevideColor,
                        ),
                        // comment(), // 用户留言
                        SizedBox(height: 80.w),
                        // Container(
                        //   width: 1.sw,
                        //   height: 2.w,
                        //   margin: EdgeInsets.symmetric(horizontal: 80.w),
                        //   color: kDevideColor,
                        // ),
                        // SizedBox(height: 1000.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 顶部价格
          Positioned(
            top: 0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              height: topHeight,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: kDevideColor, width: 2.w),
                ),
              ),
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
          ),
          Positioned(
            top: 0,
            child: AnimatedContainer(
                duration: Duration(milliseconds: 100),
                height: topHeight,
                padding: EdgeInsets.fromLTRB(40.w, 0, 40.w, 20.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: kDevideColor, width: 2.w),
                  ),
                ),
                child: Container(
                  child: Row(
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: CupertinoButton(
                          onPressed: () {
                            _showBuy(item: item);
                          },
                          padding: EdgeInsets.zero,
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 0.4.sw),
                            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: kMainColor,
                              borderRadius: BorderRadius.circular(200.r),
                            ),
                            child: Text(
                              'RMB￥${item.price}',
                              style: TextStyle(
                                fontSize: 45.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 0.45.sw),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Text(
                            '${item.name}',
                            style: TextStyle(
                              fontSize: 45.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
          // 关闭按钮
          Positioned(
            right: 50.w,
            top: 85.h,
            child: Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Center(child: Icon(Icons.close, color: Colors.white, size: 60.w)),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget banner() {
    return Column(
      children: [
        Container(
          height: 0.7.sh,
          width: 1.sw,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: item.images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.to(() => PhotoViewPage(images: item.images, initialIndex: index), transition: Transition.fadeIn);
                },
                child: Image.network(
                  replaceLocalhost(item.images[index]),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                ),
              );
            },
            onPageChanged: (index) {
              setState(() {
                _bannerIndex = index;
              });
            },
          ),
        ),
        SizedBox(height: 20.w),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(item.images.length, (index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 100),
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _bannerIndex == index ? Colors.black : kGrey.withOpacity(0.5),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget description() {
    return Container(
      padding: EdgeInsets.all(80.w),
      decoration: BoxDecoration(
        color: Color(0xFFf2f1f6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF8c8b90),
                  width: 5.w,
                ),
              ),
            ),
            child: Text(
              '描述',
              style: TextStyle(
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 5.w,
              ),
            ),
          ),
          SizedBox(height: 30.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                CupertinoIcons.text_quote,
                size: 110.w,
                color: kGrey,
              ),
              SizedBox(width: 30.w),
              Expanded(
                child: ExpandableText(
                  text: item.description,
                  style: TextStyle(
                    fontSize: 40.sp,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget info() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 类型
          Container(
            padding: EdgeInsets.fromLTRB(160.w, 0, 80.w, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: kDevideColor, width: 2.w),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '类型',
                  style: TextStyle(
                    fontSize: 37.sp,
                    color: kGrey,
                  ),
                ),
                SizedBox(height: 10.h),
                if (item.category == '闲置物品')
                  Column(
                    children: [
                      Container(
                        height: 100.h,
                        child: Icon(
                          CupertinoIcons.archivebox_fill,
                          size: 90.w,
                          color: kMainColor,
                        ),
                      ),
                      Text(
                        '闲置物品',
                        style: TextStyle(
                          fontSize: 33.sp,
                          color: kMainColor,
                        ),
                      ),
                    ],
                  ),
                if (item.category == '校园跑腿')
                  Column(
                    children: [
                      Container(
                        height: 100.h,
                        child: Icon(
                          CupertinoIcons.hare_fill,
                          size: 90.w,
                          color: kMainColor,
                        ),
                      ),
                      Text(
                        '校园跑腿',
                        style: TextStyle(
                          fontSize: 33.sp,
                          color: kMainColor,
                        ),
                      ),
                    ],
                  ),
                if (item.category == '组织活动')
                  Column(
                    children: [
                      Container(
                        height: 100.h,
                        child: Icon(
                          CupertinoIcons.person_3_fill,
                          size: 90.w,
                          color: kMainColor,
                        ),
                      ),
                      Text(
                        '组织活动',
                        style: TextStyle(
                          fontSize: 33.sp,
                          color: kMainColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ), // 发布日期
          // 发布日期
          Container(
            padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: kDevideColor, width: 2.w),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '发布日期',
                  style: TextStyle(
                    fontSize: 37.sp,
                    color: kGrey,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 100.h,
                  child: Text(
                    '${item.createdAt.month}月${item.createdAt.day}日',
                    style: TextStyle(
                      fontSize: 65.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${item.createdAt.year}年',
                  style: TextStyle(
                    fontSize: 33.sp,
                  ),
                ),
              ],
            ),
          ),
          // 修改日期
          Container(
            padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: kDevideColor, width: 2.w),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '修改日期',
                  style: TextStyle(
                    fontSize: 37.sp,
                    color: kGrey,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 100.h,
                  child: Text(
                    '${item.updatedAt.month}月${item.updatedAt.day}日',
                    style: TextStyle(
                      fontSize: 65.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${item.updatedAt.year}年',
                  style: TextStyle(
                    fontSize: 33.sp,
                  ),
                ),
              ],
            ),
          ),
          // 收藏
          Container(
            padding: EdgeInsets.fromLTRB(80.w, 0, 80.w, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: kDevideColor, width: 2.w),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '收藏',
                  style: TextStyle(
                    fontSize: 37.sp,
                    color: kGrey,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 100.h,
                  child: Text(
                    '${item.favoritesCount}',
                    style: TextStyle(
                      fontSize: 65.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '人',
                  style: TextStyle(
                    fontSize: 33.sp,
                  ),
                ),
              ],
            ),
          ),
          // 浏览
          Container(
            padding: EdgeInsets.fromLTRB(80.w, 0, 160.w, 0),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                Text(
                  '浏览',
                  style: TextStyle(
                    fontSize: 37.sp,
                    color: kGrey,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 100.h,
                  child: Text(
                    '${item.views}',
                    style: TextStyle(
                      fontSize: 65.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '次',
                  style: TextStyle(
                    fontSize: 33.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget comment() {
  //   return PageView.builder(
  //     controller: _commentController,
  //     itemCount: 2,
  //     onPageChanged: (index) {
  //       setState(() {
  //         _commentIndex = index;
  //       });
  //     },
  //     itemBuilder: (context, index) {},
  //   );
  // }
}
