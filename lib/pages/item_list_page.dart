import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/constants/color.dart';
import 'package:test/constants/text.dart';
import 'package:test/controllers/item.dart';
import 'package:test/controllers/user.dart';
import 'package:test/models/item.dart';
import 'package:test/pages/item_detail.dart';
import 'package:test/widgets/button/cup_button.dart';
import 'package:test/widgets/button/pressable_button.dart';

enum ListType {
  latest, // 最近发布
  favoriteRank, // 收藏榜单
  viewRank // 浏览榜单
}

class ItemListPage extends StatefulWidget {
  final String title;
  final ListType listType;

  const ItemListPage({Key? key, required this.title, required this.listType})
      : super(key: key);

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final ItemController itemController = Get.find<ItemController>();
  final UserController userController = Get.find<UserController>();

  bool isLoading = true;
  int currentPage = 1;
  bool hasMoreData = true;
  final int pageSize = 3;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey key1 = GlobalKey();
  final GlobalKey key2 = GlobalKey();
  double _appBarOpacity = 0.0;
  double _titleScale = 1.0;
  bool _isBottomBelowOrEqualTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    loadData();
  }

  void _scrollListener() {
    // 提前触发加载更多的滚动阈值（减小阈值值以便更快加载）
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 300.h) {
      if (hasMoreData && !isLoading) {
        print(
            "触发滚动加载：${_scrollController.position.pixels}/${_scrollController.position.maxScrollExtent}");
        loadMoreData();
      }
    }
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      currentPage = 1; // 重置页码
      hasMoreData = true; // 重置加载状态
    });

    try {
      switch (widget.listType) {
        case ListType.latest:
          print("初始加载最新列表数据");
          await itemController.loadFullLatestList(page: 1, size: pageSize);
          // 由于每次只加载3个，可能需要立即加载第二页
          _checkAndLoadMoreIfNeeded();
          break;
        case ListType.favoriteRank:
          print("初始加载收藏榜单数据");
          await itemController.loadFullFavoriteRankingList(
              page: 1, size: pageSize);
          // 由于每次只加载3个，可能需要立即加载第二页
          _checkAndLoadMoreIfNeeded();
          break;
        case ListType.viewRank:
          print("初始加载浏览榜单数据");
          await itemController.loadFullViewRankingList(page: 1, size: pageSize);
          // 由于每次只加载3个，可能需要立即加载第二页
          _checkAndLoadMoreIfNeeded();
          break;
      }
    } catch (e) {
      print("加载数据错误: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // 检查是否需要自动加载更多内容
  void _checkAndLoadMoreIfNeeded() {
    // 延迟执行一次检查，确保UI已经构建完成
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted && _scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double viewportHeight = _scrollController.position.viewportDimension;

        print("初始滚动状态: $currentScroll/$maxScroll, 视窗高度: $viewportHeight");

        // 如果内容高度不足以填满视窗的2倍，自动加载更多
        if (maxScroll < viewportHeight * 1.5 && hasMoreData && !isLoading) {
          print("内容不足，自动加载更多");
          loadMoreData();
        }
      }
    });
  }

  Future<void> loadMoreData() async {
    if (isLoading || !hasMoreData) return;

    setState(() {
      isLoading = true;
    });

    try {
      currentPage++;
      print("开始加载更多数据: 第$currentPage页");

      int initialCount = 0;

      switch (widget.listType) {
        case ListType.latest:
          initialCount = itemController.fullLatestList.length;
          await itemController.loadFullLatestList(
              page: currentPage, size: pageSize);
          // 检查是否还有更多数据
          if (initialCount == itemController.fullLatestList.length) {
            setState(() {
              hasMoreData = false;
            });
            print("最新列表没有更多数据了");
          } else {
            final loadedCount =
                itemController.fullLatestList.length - initialCount;
            print(
                "成功加载了$loadedCount项新数据，当前总计${itemController.fullLatestList.length}项");

            // 如果加载的数据少于pageSize，说明已经没有更多数据了
            if (loadedCount < pageSize) {
              setState(() {
                hasMoreData = false;
              });
              print("最新列表数据已加载完毕");
            }
          }
          break;
        case ListType.favoriteRank:
          initialCount = itemController.fullFavoriteRankingList.length;
          await itemController.loadFullFavoriteRankingList(
              page: currentPage, size: pageSize);
          // 检查是否还有更多数据
          if (initialCount == itemController.fullFavoriteRankingList.length) {
            setState(() {
              hasMoreData = false;
            });
            print("收藏榜单没有更多数据了");
          } else {
            final loadedCount =
                itemController.fullFavoriteRankingList.length - initialCount;
            print(
                "成功加载了$loadedCount项新数据，当前总计${itemController.fullFavoriteRankingList.length}项");

            // 如果加载的数据少于pageSize，说明已经没有更多数据了
            if (loadedCount < pageSize) {
              setState(() {
                hasMoreData = false;
              });
              print("收藏榜单数据已加载完毕");
            }
          }
          break;
        case ListType.viewRank:
          initialCount = itemController.fullViewRankingList.length;
          await itemController.loadFullViewRankingList(
              page: currentPage, size: pageSize);
          // 检查是否还有更多数据
          if (initialCount == itemController.fullViewRankingList.length) {
            setState(() {
              hasMoreData = false;
            });
            print("浏览榜单没有更多数据了");
          } else {
            final loadedCount =
                itemController.fullViewRankingList.length - initialCount;
            print(
                "成功加载了$loadedCount项新数据，当前总计${itemController.fullViewRankingList.length}项");

            // 如果加载的数据少于pageSize，说明已经没有更多数据了
            if (loadedCount < pageSize) {
              setState(() {
                hasMoreData = false;
              });
              print("浏览榜单数据已加载完毕");
            }
          }
          break;
      }
    } catch (e) {
      print("加载更多数据错误: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
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

  List<ItemModel> get currentList {
    switch (widget.listType) {
      case ListType.latest:
        return itemController.fullLatestList;
      case ListType.favoriteRank:
        return itemController.fullFavoriteRankingList;
      case ListType.viewRank:
        return itemController.fullViewRankingList;
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
                              widget.title,
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
                                    '${currentList.length}项',
                                    style: TextStyle(
                                      color: kGrey,
                                      fontSize: 40.sp,
                                      letterSpacing: 6.w,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 40.h),
                                if (isLoading && currentList.isEmpty)
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
                if (isLoading && currentList.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.h),
                      child: Center(
                        child: Column(
                          children: [
                            CupertinoActivityIndicator(radius: 25.r),
                            SizedBox(height: 10.h),
                            Text(
                              '加载更多内容...',
                              style: TextStyle(
                                fontSize: 35.sp,
                                color: kGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!isLoading && !hasMoreData)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.h),
                      child: Center(
                        child: Text(
                          '已经到底了',
                          style: TextStyle(
                            fontSize: 35.sp,
                            color: kGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                // 底部填充，确保底部内容可见
                SliverToBoxAdapter(
                  child: SizedBox(height: 50.h),
                ),
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
                            // 左侧返回按钮
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
                                  widget.title,
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
      if (currentList.isEmpty && !isLoading) {
        return SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 80.w),
            padding: EdgeInsets.only(top: 100.h),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.cube_box,
                    size: 100.w,
                    color: kGrey,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    '暂无数据',
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
        itemCount: currentList.length,
        itemBuilder: (context, index) {
          ItemModel item = currentList[index];
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
              index != currentList.length - 1
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
