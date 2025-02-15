import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/api/item.dart';
import 'package:test/constants/color.dart';
import 'package:test/models/item.dart';
import 'package:test/pages/photo_view.dart';
import 'package:test/widgets/expandable_text.dart';

class ItemDetailPage extends StatefulWidget {
  final ItemModel item;

  const ItemDetailPage({
    super.key,
    required this.item,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final double imageHeight = 0.7.sh;
  late ItemModel item;

  Future<void> _loadItem() async {
    item = await ItemApi.item(itemId: widget.item.id);
    setState(() {});
  }

  late PageController _bannerController;
  int _bannerIndex = 0;

  // late PageController _commentController;
  // int _commentIndex = 0;

  @override
  void initState() {
    super.initState();
    item = widget.item;

    _bannerController = PageController(initialPage: 0);
    // _commentController = PageController(initialPage: 0);
    ItemApi.view(itemId: item.id); // 浏览数+1
    _loadItem();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    // _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
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
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
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
                            CupertinoButton(
                              onPressed: () {},
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
                                    onPressed: () {},
                                    padding: EdgeInsets.zero,
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 30.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: kMainColor,
                                          width: 5.w,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(200.r),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons.plus_circle_fill,
                                            size: 50.w,
                                            color: kMainColor,
                                          ),
                                          SizedBox(width: 10.w),
                                          Text(
                                            '收藏',
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
                                if (item.isNegotiable) SizedBox(width: 30.w),
                                if (item.isNegotiable)
                                  Expanded(
                                    flex: 1,
                                    child: CupertinoButton(
                                      onPressed: () {},
                                      padding: EdgeInsets.zero,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 30.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: kMainColor,
                                            width: 5.w,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(200.r),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .ellipses_bubble_fill,
                                              size: 50.w,
                                              color: kMainColor,
                                            ),
                                            SizedBox(width: 10.w),
                                            Text(
                                              '议价',
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
                            SizedBox(height: 80.w),
                            Container(
                              width: 1.sw,
                              height: 2.w,
                              color: kDevideColor,
                            )
                          ],
                        ),
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
                      Container(
                        width: 1.sw,
                        height: 2.w,
                        margin: EdgeInsets.symmetric(horizontal: 80.w),
                        color: kDevideColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 关闭按钮
          Positioned(
            right: 50.w,
            top: 50.w,
            child: Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Center(
                    child: Icon(Icons.close, color: Colors.white, size: 60.w)),
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
                  Get.to(
                      () => PhotoViewPage(
                          images: item.images, initialIndex: index),
                      transition: Transition.fadeIn);
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
                color: _bannerIndex == index
                    ? Colors.black
                    : kGrey.withOpacity(0.5),
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
          )
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
