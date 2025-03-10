import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test/api/api.dart';
import 'package:test/api/user.dart';
import 'package:test/constants/color.dart';
import 'package:test/controllers/user.dart';
import 'package:test/enum/photo_type.dart';
import 'package:test/pages/favorite.dart';
import 'package:test/pages/photo_view.dart';
import 'package:test/pages/user/login.dart';
import 'package:test/utils/token.dart';
import 'package:test/widgets/button/cup_button.dart';
import 'package:dio/dio.dart' as oid;

class PersonalPage extends StatefulWidget {
  PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  final UserController userController = Get.find<UserController>();

  final ImagePicker _picker = ImagePicker();
  String avatar = '';
  String background = '';

  bool isLoading = false;

  Future<String> uploadFile(File file) async {
    final dio = Dio();

    try {
      // 检查文件是否存在
      if (!file.existsSync()) {
        debugPrint('文件不存在: ${file.path}');
        return '';
      }

      // 自动检测文件的 MIME 类型
      final mimeType = lookupMimeType(file.path);
      print('检测到的文件 MIME 类型: $mimeType');

      // 构建 headers
      dio.options.headers = {
        'Content-Type': 'multipart/form-data',
      };

      // 构建 FormData
      final formData = oid.FormData.fromMap({
        'file': await oid.MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last, // 设置文件名
          contentType: mimeType != null
              ? MediaType.parse(mimeType) // 设置正确的 MIME 类型
              : MediaType('application', 'octet-stream'), // 默认值
        ),
      });

      // 发送请求
      final response = await dio.post(
        '${BASE_URL}/upload_file',
        data: formData,
      );

      // 处理响应
      if (response.statusCode == 200) {
        print('上传成功: ${response.data}');
        return response.data['fileUrl'];
      } else {
        debugPrint('上传失败: ${response.statusCode}, 消息: ${response.data}');
      }
    } catch (e) {
      debugPrint('上传发生异常: $e');
    }
    return '';
  }

  /// 获取存储权限
  Future<bool> _getStoragePermission() async {
    final PermissionStatus status = defaultTargetPlatform == TargetPlatform.iOS
        ? await Permission.photosAddOnly.request()
        : await Permission.storage.request();
    return status.isGranted;
  }

  //  拍照处理逻辑
  Future<void> _takePhoto({required PhotoType type}) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      return;
    } // 取消

    final File imageFile = File(pickedFile.path);

    // 上传文件
    final String? imageUrl = await uploadFile(imageFile);
    if (imageUrl != null) {
      switch (type) {
        case PhotoType.avatar:
          setState(() {
            avatar = imageUrl;
          });
          if (avatar.isNotEmpty) {
            await UserApi.uploadAvator(userId: userController.id.value, avatar: avatar);
            userController.avatar.value = avatar;
          }
          break;

        case PhotoType.background:
          setState(() {
            background = imageUrl;
          });
          if (background.isNotEmpty) {
            await UserApi.uploadBackground(userId: userController.id.value, background: background);
            userController.background.value = background;
          }
          break;

        case PhotoType.image:
          break;
      }
    }
  }

  // 相册选择图片
  Future<void> _selectPhoto({required PhotoType type}) async {
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
        switch (type) {
          case PhotoType.avatar:
            setState(() {
              avatar = imageUrl;
            });
            if (avatar.isNotEmpty) {
              await UserApi.uploadAvator(userId: userController.id.value, avatar: avatar);
              userController.avatar.value = avatar;
            }
            break;

          case PhotoType.background:
            setState(() {
              background = imageUrl;
            });
            if (background.isNotEmpty) {
              await UserApi.uploadBackground(userId: userController.id.value, background: background);
              userController.background.value = background;
            }
            break;

          case PhotoType.image:
            break;
        }
      }
    } catch (e) {
      debugPrint('Error in _selectPhoto: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 修改头像或背景图片
  Future<void> _changeBackground({required PhotoType type, bool hasReview = false}) async {
    // 检查存储和位置权限
    final permissionState = await _getStoragePermission();
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
                          _takePhoto(type: type);
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
                      borderRadius: hasReview
                          ? BorderRadius.zero
                          : BorderRadius.only(
                              bottomLeft: Radius.circular(30.r),
                              bottomRight: Radius.circular(30.r),
                            ),
                      child: CupButton(
                        pressedColor: Color(0xFFdbdbdd),
                        onPressed: () {
                          Get.back();
                          _selectPhoto(type: type);
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
                    if (hasReview)
                      Container(
                        width: 1.sw,
                        color: kDevideColor,
                        height: 2.w,
                      ),
                    if (hasReview)
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.r),
                          bottomRight: Radius.circular(30.r),
                        ),
                        child: CupButton(
                          pressedColor: Color(0xFFdbdbdd),
                          onPressed: () {
                            Get.back();

                            switch (type) {
                              case PhotoType.avatar:
                                Get.to(
                                  () => PhotoViewPage(images: [avatar], initialIndex: 0, hasPage: false),
                                  transition: Transition.cupertino,
                                );
                              case PhotoType.background:
                                Get.to(
                                  () => PhotoViewPage(images: [background], initialIndex: 0, hasPage: false),
                                  transition: Transition.cupertino,
                                );
                              case PhotoType.image:
                                break;
                            }
                          },
                          child: Container(
                            width: 1.sw,
                            padding: EdgeInsets.symmetric(vertical: 30.w),
                            child: Center(
                              child: Text(
                                '查看',
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

  @override
  void initState() {
    super.initState();
    avatar = userController.avatar.value;
    background = userController.background.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      body: Container(
        width: 1.sw,
        decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: CachedNetworkImageProvider(replaceLocalhost(background)),
            //   fit: BoxFit.cover,
            // ),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 200.w),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                await _changeBackground(type: PhotoType.avatar, hasReview: avatar != '');
              },
              child: Container(
                width: 230.w,
                height: 230.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  image: avatar != ''
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(avatar),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: avatar != ''
                    ? null
                    : Center(
                        child: Icon(
                          CupertinoIcons.person_fill,
                          size: 190.w,
                          color: kGrey,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 30.w),
            Text(
              userController.name.value,
              style: TextStyle(
                fontSize: 60.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              userController.email.value,
              style: TextStyle(
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
                color: kGrey,
              ),
            ),
            SizedBox(height: 50.w),
            Container(
              width: 1.sw,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.symmetric(
                      horizontal: BorderSide(
                    color: kDevideColor,
                    width: 2.w,
                  ))),
              child: Column(
                children: [
                  infoButton(text: '用户名、电子邮件', onPressed: () {}),
                  infoButton(text: '密码与安全性', onPressed: () {}),
                  infoButton(
                      text: '收藏列表',
                      onPressed: () {
                        Get.to(
                          () => FavoritePage(),
                          transition: Transition.cupertino,
                        );
                      }),
                  infoButton(text: '评价', onPressed: () {}),
                  infoButton(text: '称号', onPressed: () {}),
                  infoButton(
                      text: '设置聊天背景',
                      onPressed: () {
                        _changeBackground(type: PhotoType.background, hasReview: background != '');
                      },
                      hasDevider: false),
                ],
              ),
            ),
            SizedBox(height: 80.w),
            CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  await removeToken();
                  Get.offAll(() => LoginPage());
                },
                child: Container(
                  width: 1.sw,
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 25.w),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.symmetric(
                          horizontal: BorderSide(
                        color: kDevideColor,
                        width: 2.w,
                      ))),
                  child: Center(
                    child: Text(
                      '退出登录',
                      style: TextStyle(
                        fontSize: 42.sp,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemRed,
                      ),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget infoButton({
    required String text,
    required void Function() onPressed,
    bool hasDevider = true,
  }) {
    return Column(
      children: [
        CupButton(
          onPressed: onPressed,
          pressedColor: kDevideColor,
          child: Container(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 40.w),
                    Expanded(
                      child: Container(
                        decoration:
                            BoxDecoration(border: hasDevider ? Border(bottom: BorderSide(color: kDevideColor)) : null),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 25.w),
                            Row(
                              children: [
                                Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 42.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  CupertinoIcons.chevron_forward,
                                  color: const Color(0xFFa4a4a9),
                                  size: 50.w,
                                ),
                                SizedBox(width: 40.w),
                              ],
                            ),
                            SizedBox(height: 25.w),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // if (hasDevider)
                //   Row(
                //     children: [
                //       Container(
                //         width: 40.w,
                //         height: 2.h,
                //         color: Colors.white,
                //       ),
                //       Container(
                //         width: 1.sw - 40.w,
                //         height: 2.h,
                //         color: kDevideColor,
                //       ),
                //     ],
                //   ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
