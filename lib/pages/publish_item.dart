import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test/api/api.dart';
import 'package:test/api/publish.dart';
import 'package:test/constants/color.dart';
import 'package:test/controllers/publish.dart';
import 'package:test/controllers/user.dart';
import 'package:test/pages/common/scrolling_title_page.dart';
import 'package:test/pages/photo_view.dart';
import 'package:test/utils/upload.dart';
import 'package:test/widgets/button/cup_button.dart';

class PublishItemPage extends StatefulWidget {
  final String category;
  const PublishItemPage({super.key, required this.category});

  @override
  State<PublishItemPage> createState() => _PublishItemPageState();
}

class _PublishItemPageState extends State<PublishItemPage> {
  final UserController userController = Get.find<UserController>();
  final PublishController publishController = Get.find<PublishController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _desController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  List<String> _images = [];
  double _photoListHeight = 310.h;

  bool isNegotiable = true;

  //  拍照
  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      return;
    } // 取消

    final File imageFile = File(pickedFile.path);

    // 上传文件
    final String? imageUrl = await uploadFile(imageFile);
    if (imageUrl != null) {}
  }

  // 相册选择图片
  Future<void> _selectPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return; // 用户取消选择

    setState(() {
      isLoading = true;
    });

    try {
      final File imageFile = File(pickedFile.path);

      // 上传文件
      final String? imageUrl = await uploadFile(imageFile);
      if (imageUrl != null) {
        setState(() {
          _images.add(imageUrl);
          _updateHeight();
        });
      }
    } catch (e) {
      debugPrint('Error in _selectPhoto: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addPhoto() async {
    // 检查存储和位置权限
    final permissionState = await getStoragePermission();
    if (!permissionState) {
      // 权限被拒绝 打开手机上该App的权限设置页面
      openAppSettings();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      barrierColor: Colors.black.withOpacity(0.2),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: 1.sw,
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                width: 1.sw,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                      child: CupButton(
                        pressedColor: Color(0xFFdbdbdd),
                        onPressed: () {
                          Get.back();
                          _takePhoto();
                        },
                        child: Container(
                          width: 1.sw,
                          padding: EdgeInsets.symmetric(vertical: 30.w),
                          child: Center(
                            child: Text(
                              '拍照',
                              style: TextStyle(
                                fontSize: 55.sp,
                                fontWeight: FontWeight.bold,
                                color: kBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1.sw,
                      color: kDevideColor,
                      height: 2.w,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.r),
                        bottomRight: Radius.circular(30.r),
                      ),
                      child: CupButton(
                        pressedColor: Color(0xFFdbdbdd),
                        onPressed: () {
                          Get.back();
                          _selectPhoto();
                        },
                        child: Container(
                          width: 1.sw,
                          padding: EdgeInsets.symmetric(vertical: 30.w),
                          child: Center(
                            child: Text(
                              '选取照片',
                              style: TextStyle(
                                fontSize: 55.sp,
                                fontWeight: FontWeight.bold,
                                color: kBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.w),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30.r),
                      child: CupButton(
                        pressedColor: Color(0xFFdbdbdd),
                        onPressed: () {
                          Get.back();
                        },
                        child: Container(
                          width: 1.sw,
                          padding: EdgeInsets.symmetric(vertical: 30.w),
                          child: Center(
                            child: Text(
                              '取消',
                              style: TextStyle(
                                fontSize: 55.sp,
                                fontWeight: FontWeight.bold,
                                color: kBlue,
                              ),
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
        );
      },
    );
  }

  void _updateHeight() {
    if (_images.length >= 3 && _images.length <= 5) {
      _photoListHeight = 620.h;
    } else if (_images.length > 5 && _images.length <= 9) {
      _photoListHeight = 930.h;
    } else {
      _photoListHeight = 310.h;
    }
  }

  void _publish() async {
    String name = _nameController.text;
    double price = double.parse(_priceController.text);
    String description = _desController.text;
    String category = widget.category;
    List<String> images = _images;
    String ownerId = userController.id.value;
    bool status = true;
    String location = '校内';
    bool canNegotiable = isNegotiable;

    bool success = await PublishApi.publish(
      name: name,
      price: price,
      description: description,
      category: category,
      images: images,
      ownerId: ownerId,
      status: status,
      location: location,
      isNegotiable: canNegotiable,
    );

    if (success) {
      await publishController.loadPublishList(userId: userController.id.value);
      Get.back();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _desController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: ScrollingTitlePage(
        title: widget.category,
        titleAdapter: [
          SizedBox(height: 40.h),
          Container(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 40.w, vertical: 30.h),
            margin: EdgeInsets.symmetric(horizontal: 80.w),
            decoration: BoxDecoration(
              color: kBackColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: TextField(
              controller: _nameController,
              maxLines: 2,
              maxLength: 40,
              scrollPhysics: NeverScrollableScrollPhysics(),
              style: TextStyle(
                fontSize: 40.sp,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: '起一个引人注目的标题',
                hintStyle: TextStyle(
                  fontSize: 40.sp,
                  color: kGrey,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counterStyle: TextStyle(
                  fontSize: 30.sp,
                  color: kGrey,
                ),
              ),
            ),
          ),
          SizedBox(height: 40.h),
          PhotoList(),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 40.w, vertical: 30.h),
            margin: EdgeInsets.symmetric(horizontal: 80.w),
            decoration: BoxDecoration(
              color: kBackColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: TextField(
              controller: _desController,
              maxLines: 11,
              maxLength: 220,
              scrollPhysics: NeverScrollableScrollPhysics(),
              style: TextStyle(
                fontSize: 40.sp,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: '描述一下物品的品牌型号、购买渠道...',
                hintStyle: TextStyle(
                  fontSize: 40.sp,
                  color: kGrey,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counterStyle: TextStyle(
                  fontSize: 30.sp,
                  color: kGrey,
                ),
              ),
            ),
          ),
          SizedBox(height: 40.h),
          Container(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 40.w, vertical: 20.h),
            margin: EdgeInsets.symmetric(horizontal: 80.w),
            decoration: BoxDecoration(
              color: kBackColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Container(
                  child: Text(
                    '价格￥',
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      color: kMainColor,
                    ),
                  ),
                ),
                Spacer(),
                IntrinsicWidth(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 400.w,
                    ),
                    height: 90.h,
                    child: TextField(
                      controller: _priceController,
                      maxLines: 1,
                      maxLength: 10,
                      scrollPhysics: NeverScrollableScrollPhysics(),
                      style: TextStyle(
                        fontSize: 40.sp,
                        color: Colors.black,
                      ),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          fontSize: 45.sp,
                          color: kGrey,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        counterStyle: TextStyle(
                          fontSize: 0.sp,
                          color: kGrey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(height: 40.h),
          Container(
            padding: EdgeInsets.fromLTRB(40.w, 20.h, 20.w, 20.h),
            margin: EdgeInsets.symmetric(horizontal: 80.w),
            child: Row(
              children: [
                Text(
                  '可议价',
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                    color: kMainColor,
                  ),
                ),
                Spacer(),
                CupertinoSwitch(
                  value: isNegotiable,
                  activeColor: CupertinoColors.activeBlue,
                  onChanged: (bool? value) {
                    setState(() {
                      isNegotiable = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 0.3.sh),
        ],
        canBack: true,
        actionButton: PublishButton(),
      ),
    );
  }

  Widget PublishButton() {
    return CupertinoButton(
        padding: EdgeInsets.zero,
        child: Container(
          width: 180.w,
          height: 80.h,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              '发布',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 45.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        onPressed: () {
          _publish();
        });
  }

  Widget PhotoList() {
    return Center(
      child: Container(
        height: _photoListHeight,
        width: 1.sw - 160.w,
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _images.length < 9 ? _images.length + 1 : _images.length,
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 30.w,
            crossAxisSpacing: 30.w,
          ),
          itemBuilder: (context, index) {
            if (index < _images.length) {
              String item = _images[index];

              return Stack(
                children: [
                  CupertinoButton(
                    onPressed: () {
                      Get.to(
                        () => PhotoViewPage(images: _images, initialIndex: index),
                        transition: Transition.cupertino,
                      );
                    },
                    padding: EdgeInsets.zero,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kBackColor,
                        borderRadius: BorderRadius.circular(10.r),
                        image: DecorationImage(
                          image: NetworkImage(
                            replaceLocalhost(item),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10.w,
                    top: 10.w,
                    child: CupertinoButton(
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            _images.removeAt(index);
                            _updateHeight();
                          });
                        }
                      },
                      padding: EdgeInsets.zero,
                      child: Container(
                        width: 70.w,
                        height: 70.w,
                        child: Center(
                          child: Icon(Icons.close_rounded, color: Colors.white, size: 50.w),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: kGrey.withOpacity(0.5),
                                blurRadius: 2.r,
                              )
                            ]),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return CupertinoButton(
                onPressed: () {
                  _addPhoto();
                },
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: BoxDecoration(
                    color: kBackColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.plus,
                      color: kGrey,
                      size: 180.w,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
