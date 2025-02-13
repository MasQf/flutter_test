import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/constants/color.dart';
import 'package:test/models/item.dart';
import 'package:test/pages/photo_view.dart';

class PublishDetailPage extends StatefulWidget {
  final ItemModel item;
  final List<ItemModel> itemList; // 添加物品列表
  final int initialItemIndex; // 添加初始索引

  const PublishDetailPage({
    super.key,
    required this.item,
    required this.itemList,
    required this.initialItemIndex,
  });

  @override
  State<PublishDetailPage> createState() => _PublishDetailPageState();
}

class _PublishDetailPageState extends State<PublishDetailPage> {
  final double imageHeight = 0.7.sh;
  late PageController _itemPageController;
  late PageController _pageNumberController;
  late int _currentItemIndex = 0;
  late int _currentNumberIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentItemIndex = widget.initialItemIndex;
    _currentNumberIndex = 0;
    _itemPageController = PageController(initialPage: _currentItemIndex);
    _pageNumberController = PageController(initialPage: _currentNumberIndex);
  }

  @override
  void dispose() {
    _itemPageController.dispose();
    _pageNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _itemPageController,
            itemCount: widget.itemList.length,
            onPageChanged: (itemIndex) {
              setState(() {
                _currentItemIndex = itemIndex;
                _currentNumberIndex = 0;
              });
            },
            itemBuilder: (context, index) {
              final item = widget.itemList[index];
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 0.7.sh,
                      width: 1.sw,
                      child: PageView.builder(
                        controller: _pageNumberController,
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
                            _currentNumberIndex = index;
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
                            color: _currentNumberIndex == index
                                ? Colors.black
                                : kGrey.withOpacity(0.5),
                          ),
                        );
                      }),
                    ),
                    Container(
                      width: 1.sw,
                      padding: EdgeInsets.symmetric(
                          horizontal: 40.w, vertical: 80.w),
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
