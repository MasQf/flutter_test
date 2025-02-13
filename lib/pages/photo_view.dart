import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:test/api/api.dart';
import 'package:test/constants/color.dart';

class PhotoViewPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final bool hasPage;

  PhotoViewPage({
    required this.images,
    required this.initialIndex,
    this.hasPage = true,
  });

  @override
  _PhotoViewPageState createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              itemCount: widget.images.length,
              pageController: _pageController,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider:
                      NetworkImage(replaceLocalhost(widget.images[index])),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                        child: Icon(CupertinoIcons.exclamationmark_triangle,
                            color: Colors.red));
                  },
                );
              },
              loadingBuilder: (context, event) => Center(
                child: CupertinoActivityIndicator(),
              ),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            if (widget.hasPage)
              Positioned(
                  bottom: 150.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.images.length, (index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 100),
                          margin: EdgeInsets.symmetric(horizontal: 5.w),
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == index
                                ? Colors.white
                                : kGrey.withOpacity(0.5),
                          ),
                        );
                      }),
                    ),
                  )),
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
                      child:
                          Icon(Icons.close, color: Colors.white, size: 60.w)),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
