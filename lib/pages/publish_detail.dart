import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/constants/color.dart';
import 'package:test/models/item.dart';

class PublishDetailPage extends StatefulWidget {
  final ItemModel item;
  final List<ItemModel> itemList; // 添加物品列表
  final int initialIndex; // 添加初始索引

  const PublishDetailPage({
    super.key,
    required this.item,
    required this.itemList,
    required this.initialIndex,
  });

  @override
  State<PublishDetailPage> createState() => _PublishDetailPageState();
}

class _PublishDetailPageState extends State<PublishDetailPage> {
  final double imageHeight = 0.7.sh;
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.itemList.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final item = widget.itemList[index];
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // 封面图片
                    Hero(
                      tag: '${item.id}',
                      child: Container(
                        height: imageHeight,
                        width: 1.sw,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(replaceLocalhost(item.images[0])),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1.sw,
                      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 80.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 0.9.sw,
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 80.sp,
                                fontWeight: FontWeight.bold,
                                height: 2.3.w,
                              ),
                            ),
                          ),
                          SizedBox(height: 40.w),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.bold,
                              color: kGrey,
                              height: 2.5.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
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
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.white;
    var path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
