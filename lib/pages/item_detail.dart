import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
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
  PageController _pageController = PageController();
  final double imageHeight = 0.7.sh;

  late ItemModel item;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    item = widget.item;
    _currentIndex = 0;
  }

  @override
  void dispose() {
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
                banner(),
                Container(
                  width: 1.sw,
                  padding: EdgeInsets.symmetric(vertical: 80.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 0.9.sw,
                        padding: EdgeInsets.symmetric(horizontal: 80.w),
                        child: Text(
                          item.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 80.sp,
                            fontWeight: FontWeight.bold,
                            height: 2.3.w,
                          ),
                        ),
                      ),
                      SizedBox(height: 40.w),
                      Container(
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
                            SizedBox(height: 20.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(CupertinoIcons.text_quote),
                                Expanded(
                                  child: ExpandableText(
                                    text: item.description,
                                    style: TextStyle(
                                      fontSize: 40.sp,
                                      color: Colors.black,
                                      height: 2.8.w,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
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
            controller: _pageController,
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
                _currentIndex = index;
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
                color: _currentIndex == index
                    ? Colors.black
                    : kGrey.withOpacity(0.5),
              ),
            );
          }),
        ),
      ],
    );
  }
}
