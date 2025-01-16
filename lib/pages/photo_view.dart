import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
                  imageProvider: NetworkImage(widget.images[index]),
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
                    child: IntrinsicWidth(
                      child: Container(
                        height: 50.h,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(184, 212, 212, 212),
                            borderRadius: BorderRadius.circular(20.r)),
                        child: Center(
                          child: Text(
                            '${_currentIndex + 1} of ${widget.images.length}',
                            style:
                                TextStyle(fontSize: 30.sp, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  )),
            Positioned(
                right: 50.w,
                height: 300.h,
                child: CupertinoButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 90.w,
                    color: Colors.white,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
