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
import 'package:test/models/item.dart';
import 'package:test/pages/common/scrolling_title_page.dart';
import 'package:test/pages/item_detail.dart';
import 'package:test/widgets/button/cup_button.dart';
import 'package:test/widgets/button/pressable_button.dart';

class SearchPage extends StatefulWidget {
  final String? keyword;
  const SearchPage({super.key, this.keyword});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ItemController itemController = Get.find<ItemController>();
  final UserController userController = Get.find<UserController>();

  final TextEditingController _searchController = TextEditingController();
  final RxList<ItemModel> searchResults = <ItemModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSearching = false.obs;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey key1 = GlobalKey();
  final GlobalKey key2 = GlobalKey();
  double _appBarOpacity = 0.0;
  double _titleScale = 1.0;
  bool _isBottomBelowOrEqualTop = false;

  @override
  void initState() {
    super.initState();
    if (widget.keyword != null && widget.keyword!.isNotEmpty) {
      _searchController.text = widget.keyword!;
      _performSearch(widget.keyword!);
    } else {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void checkPosition() {
    if (key1.currentContext == null || key2.currentContext == null) return;

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

  Future<void> _performSearch(String keyword) async {
    if (keyword.isEmpty) {
      searchResults.clear();
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    isSearching.value = true;

    try {
      final results = await ItemApi.search(keyword: keyword);
      searchResults.assignAll(results);
    } catch (e) {
      print("搜索错误: $e");
    } finally {
      isLoading.value = false;
      isSearching.value = false;
    }
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
              child: CustomScrollView(controller: _scrollController, slivers: [
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
                              '搜索',
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
                                    isLoading.value
                                        ? '搜索中...'
                                        : searchResults.isEmpty
                                            ? '无结果'
                                            : '${searchResults.length}个结果',
                                    style: TextStyle(
                                      color: kGrey,
                                      fontSize: 40.sp,
                                      letterSpacing: 6.w,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 40.h),
                                CupertinoSearchTextField(
                                  controller: _searchController,
                                  prefixIcon: Icon(
                                    CupertinoIcons.search,
                                    size: 50.w,
                                  ),
                                  suffixIcon: Icon(
                                    CupertinoIcons.xmark_circle_fill,
                                    size: 50.w,
                                  ),
                                  style: TextStyle(
                                    fontSize: 40.sp,
                                  ),
                                  placeholder: '搜索',
                                  onSubmitted: (value) {
                                    _performSearch(value);
                                  },
                                ),
                                SizedBox(height: 40.h),
                                Obx(
                                  () => isLoading.value
                                      ? Center(
                                          child: Column(
                                            children: [
                                              CupertinoActivityIndicator(
                                                  radius: 30.r),
                                              SizedBox(height: 10.h),
                                              Text(
                                                '正在搜索',
                                                style: TextStyle(
                                                  fontSize: 35.sp,
                                                  color: kGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : SizedBox(),
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
                            Container(
                              width: 300.w,
                              child: CupertinoButton(
                                onPressed: () {
                                  Get.back();
                                },
                                padding: EdgeInsets.zero,
                                child: Row(
                                  children: [
                                    SizedBox(width: 40.w),
                                    Row(
                                      children: [
                                        Container(
                                          width: 50.w,
                                          child: Icon(
                                            CupertinoIcons.chevron_back,
                                            size: 70.w,
                                            color: kMainColor,
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
                                  '搜索',
                                  style: kPageTitle,
                                ),
                              ),
                            ),
                            Spacer(),
                            Container(width: 300.w),
                          ],
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
    );
  }

  Widget sliverList() {
    return Obx(() {
      if (searchResults.isEmpty && !isLoading.value && isSearching.value) {
        return SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 80.w),
            padding: EdgeInsets.only(top: 100.h),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.search,
                    size: 100.w,
                    color: kGrey,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    '没有找到结果',
                    style: TextStyle(
                      fontSize: 45.sp,
                      color: kGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (searchResults.isEmpty && !isSearching.value) {
        return SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 80.w),
            padding: EdgeInsets.only(top: 100.h),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.square_stack_3d_up_slash_fill,
                    size: 200.w,
                    color: kGrey,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    '没有相关物品发布',
                    style: TextStyle(
                      fontSize: 45.sp,
                      color: kGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return SliverList.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          ItemModel item = searchResults[index];
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => ItemDetailPage(item: item),
                    transition: Transition.cupertino,
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 1.sw,
                      padding: EdgeInsets.only(
                          left: 80.w, right: 80.w, top: 60.h, bottom: 60.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          // 图片
                          PressableButton(
                            onPressed: () {
                              Get.to(
                                () => ItemDetailPage(item: item),
                                transition: Transition.cupertino,
                              );
                            },
                            child: Container(
                              height: 550.h,
                              width: 400.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    replaceLocalhost(item.images[0]),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 199, 199, 199),
                                    blurRadius: 20.w,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 60.w),
                          Container(
                            width: 1.sw - 160.w - 400.w - 60.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 200.h,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${item.name}',
                                        style: TextStyle(
                                          fontSize: 45.sp,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 2,
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        '${item.owner.name}',
                                        style: TextStyle(
                                          fontSize: 32.sp,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.description}',
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
                                              'RMB￥${item.price}',
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
              index != searchResults.length - 1
                  ? Container(
                      width: 1.sw,
                      height: 2.h,
                      margin: EdgeInsets.only(left: 80.w, right: 80.w),
                      color: kDevideColor,
                    )
                  : SizedBox(height: 120.h)
            ],
          );
        },
      );
    });
  }
}
