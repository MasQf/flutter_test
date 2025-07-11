import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/api/item.dart';
import 'package:test/constants/color.dart';
import 'package:test/controllers/item.dart';
import 'package:test/controllers/user.dart';
import 'package:test/models/item.dart';
import 'package:test/pages/common/scrolling_title_page.dart';
import 'package:test/pages/item_detail.dart';
import 'package:test/pages/item_list_page.dart';
import 'package:test/pages/search.dart';
import 'package:test/widgets/button/cup_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  UserController userController = Get.find<UserController>();
  ItemController itemController = Get.put(ItemController());

  // 排行榜
  late PageController _rankingPageController;
  late Map<String, dynamic> rankingMap = {};
  List<ItemModel> favoriteList = [];
  List<ItemModel> viewList = [];
  int _rankingIndex = 0;

  // 按压图片动画
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

  Future<void> loadRankingList() async {
    rankingMap = await ItemApi.rankingList();
    favoriteList = (rankingMap['favoritesItems'] as List<dynamic>?)
            ?.map((json) => ItemModel.fromJson(json))
            .toList() ??
        [];
    viewList = (rankingMap['viewsItems'] as List<dynamic>?)
            ?.map((json) => ItemModel.fromJson(json))
            .toList() ??
        [];
  }

  Future<void> _loadData() async {
    // 加载最近发布列表数据
    itemController.loadLatestList().then((_) {
      _initializeAnimations(); // 确保动画控制器初始化
    });
    //加载排行榜
    await loadRankingList();
    setState(() {});
  }

  double _getRankingMargin(int currentIndex, int expectIndex) {
    if (currentIndex < expectIndex || currentIndex > expectIndex) {
      return 40.w;
    }
    return 0; // 当前页面无偏移
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _rankingPageController =
        PageController(viewportFraction: (1080 - 160) / 1080);
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    _rankingPageController.dispose();
    super.dispose();
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
          () => ItemDetailPage(item: item),
          transition: Transition.cupertino,
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
      titleAdapter: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 80.w),
          child: Column(
            children: [
              // bigButton(CupertinoIcons.text_justifyleft, '浏览分区', () {}),
              SizedBox(height: 20.h),
              CupertinoSearchTextField(
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
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    Get.to(
                      () => SearchPage(keyword: value),
                      transition: Transition.cupertino,
                    );
                  }
                },
              ),
            ],
          ),
        ),

        recent(), // 最近发布
        ranking(), //排行榜
      ],
    );
  }

  // 排行榜
  Widget ranking() {
    return Container(
      width: 1.sw,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [kDevideColor.withOpacity(0.6), Colors.white],
        ),
      ),
      padding: EdgeInsets.fromLTRB(0, 90.w, 0, 60.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 80.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '排行榜',
                  style: TextStyle(
                    fontSize: 60.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.w),
          // 内容
          Container(
            height: 0.54.sh,
            child: PageView.builder(
                controller: _rankingPageController,
                itemCount: 2,
                onPageChanged: (index) {
                  setState(() {
                    _rankingIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      {
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: _getRankingMargin(_rankingIndex, index),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 1.sw,
                                height: 2.w,
                                color: kDevideColor,
                              ),
                              SizedBox(height: 30.w),
                              Text(
                                '收藏',
                                style: TextStyle(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 5.w,
                                ),
                              ),
                              if (favoriteList.isNotEmpty)
                                Column(
                                  children: List.generate(favoriteList.length,
                                      (index) {
                                    var item = favoriteList[index];
                                    return CupButton(
                                      normalColor: Colors.transparent,
                                      onPressed: () {
                                        Get.to(
                                          () => ItemDetailPage(item: item),
                                          transition: Transition.cupertino,
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 40.w),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 150.w,
                                                  height: 200.w,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        replaceLocalhost(
                                                          item.images[0],
                                                        ),
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color.fromARGB(
                                                            255, 199, 199, 199),
                                                        blurRadius: 20.w,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.r),
                                                  ),
                                                ),
                                                SizedBox(width: 50.w),
                                                Text(
                                                  '${index + 1}',
                                                  style: TextStyle(
                                                    fontSize: 80.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 50.w),
                                                Container(
                                                  width: 0.5.sw,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.name,
                                                        style: TextStyle(
                                                          fontSize: 37.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        item.owner.name,
                                                        style: TextStyle(
                                                          fontSize: 30.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: kGrey,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 40.w),
                                            Container(
                                              width: 1.sw,
                                              height: 2.w,
                                              color: kDevideColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              SizedBox(height: 20.h),
                              Row(
                                children: [
                                  CupertinoButton(
                                    onPressed: () {
                                      Get.to(
                                        () => ItemListPage(
                                          title: '收藏榜单',
                                          listType: ListType.favoriteRank,
                                        ),
                                        transition: Transition.cupertino,
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    child: Text(
                                      '查看更多',
                                      style: TextStyle(
                                        fontSize: 37.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.chevron_forward,
                                    color: kArrowGrey,
                                    size: 40.w,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    case 1:
                      {
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: _getRankingMargin(_rankingIndex, index),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 1.sw,
                                height: 2.w,
                                color: kDevideColor,
                              ),
                              SizedBox(height: 30.w),
                              Text(
                                '浏览',
                                style: TextStyle(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 5.w,
                                ),
                              ),
                              if (viewList.isNotEmpty)
                                Column(
                                  children:
                                      List.generate(viewList.length, (index) {
                                    var item = viewList[index];
                                    return CupButton(
                                      normalColor: Colors.transparent,
                                      onPressed: () {
                                        Get.to(
                                          () => ItemDetailPage(item: item),
                                          transition: Transition.cupertino,
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 40.w),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 150.w,
                                                  height: 200.w,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        replaceLocalhost(
                                                          item.images[0],
                                                        ),
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color.fromARGB(
                                                            255, 199, 199, 199),
                                                        blurRadius: 20.w,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.r),
                                                  ),
                                                ),
                                                SizedBox(width: 50.w),
                                                Text(
                                                  '${index + 1}',
                                                  style: TextStyle(
                                                    fontSize: 80.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 50.w),
                                                Container(
                                                  width: 0.5.sw,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.name,
                                                        style: TextStyle(
                                                          fontSize: 37.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        item.owner.name,
                                                        style: TextStyle(
                                                          fontSize: 30.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: kGrey,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 40.w),
                                            Container(
                                              width: 1.sw,
                                              height: 2.w,
                                              color: kDevideColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              SizedBox(height: 20.h),
                              Row(
                                children: [
                                  CupertinoButton(
                                    onPressed: () {
                                      Get.to(
                                        () => ItemListPage(
                                          title: '浏览榜单',
                                          listType: ListType.viewRank,
                                        ),
                                        transition: Transition.cupertino,
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    child: Text(
                                      '查看更多',
                                      style: TextStyle(
                                        fontSize: 37.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.chevron_forward,
                                    color: kArrowGrey,
                                    size: 40.w,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                  }
                  return null;
                }),
          ),
        ],
      ),
    );
  }

  // 最近发布模块
  Widget recent() {
    return Container(
      width: 1.sw,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [kDevideColor.withOpacity(0.6), Colors.white],
        ),
      ),
      padding: EdgeInsets.fromLTRB(0, 90.w, 0, 60.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 80.w),
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
                  'Recently published.',
                  style: TextStyle(
                    fontSize: 37.sp,
                    color: kGrey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50.w),
          Obx(
            () => Container(
              height: 700.w,
              child: CustomScrollView(
                scrollDirection: Axis.horizontal,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.only(left: 80.w), // 左侧留白
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          ItemModel item = itemController.latestList[index];
                          return Container(
                            child: GestureDetector(
                              onTapDown: (details) =>
                                  _onTapDown(index, details),
                              onTapUp: (details) =>
                                  _onTapUp(index, item, details),
                              onTapCancel: () => _onTapCancel(index),
                              child: ScaleTransition(
                                scale: _animations[index],
                                child: Container(
                                  height: 300.h,
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
                                        color:
                                            Color.fromARGB(255, 220, 220, 220),
                                        blurRadius: 20.w,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: itemController.latestList.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        // 保持原有网格配置
                        mainAxisSpacing: 40.w,
                        crossAxisSpacing: 40.w,
                        crossAxisCount: 2,
                        childAspectRatio: 2 / 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 80.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 80.w),
            child: Column(
              children: [
                Container(
                  width: 1.sw,
                  height: 2.w,
                  color: kGrey.withOpacity(0.2),
                ),
                SizedBox(height: 20.w),
                Row(
                  children: [
                    CupertinoButton(
                      onPressed: () {
                        Get.to(
                          () => ItemListPage(
                            title: '最近发布',
                            listType: ListType.latest,
                          ),
                          transition: Transition.cupertino,
                        );
                      },
                      padding: EdgeInsets.zero,
                      child: Text(
                        '查看更多',
                        style: TextStyle(
                          fontSize: 37.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_forward,
                      color: kArrowGrey,
                      size: 40.w,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
