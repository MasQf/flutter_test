import 'dart:io';

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
import 'package:test/constants/text.dart';
import 'package:test/controllers/user.dart';
import 'package:test/pages/login.dart';
import 'package:test/utils/token.dart';
import 'package:test/widgets/cup_button.dart';
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
  Future<void> _takePhoto() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      return;
    } // 取消

    final File imageFile = File(pickedFile.path);

    // 上传文件
    final String? imageUrl = await uploadFile(imageFile);
    if (imageUrl != null) {
      setState(() {
        avatar = imageUrl;
      });

      if (avatar != '') {
        await UserApi.uploadAvator(
            userId: userController.id.value, avatar: avatar);
        userController.avatar.value = avatar;
      }
    }
  }

  // 相册选择图片
  Future<void> _selectPhoto() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

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
          avatar = imageUrl;
        });
        if (avatar != '') {
          await UserApi.uploadAvator(
              userId: userController.id.value, avatar: avatar);
          userController.avatar.value = avatar;
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

  // 添加图片
  Future<void> _addImage({bool hasReview = false}) async {
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
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(bottom: 100.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                child: Container(
                  width: 1.sw,
                  height: 100.h,
                  color: Colors.white,
                  child: Center(
                    child: Text('拍摄', style: kContentTitle),
                  ),
                ),
                onPressed: () async {
                  Get.back();
                  // 拍照
                  await _takePhoto();
                },
              ),
              Container(
                width: 1.sw,
                height: 2.h,
                color: Color.fromARGB(132, 238, 238, 238),
              ),
              CupertinoButton(
                child: Container(
                  width: 1.sw,
                  height: 100.h,
                  color: Colors.white,
                  child: Center(
                    child: Text('从手机相册选择', style: kContentTitle),
                  ),
                ),
                onPressed: () async {
                  Get.back();
                  await _selectPhoto();
                },
              ),
              Container(
                width: 1.sw,
                height: hasReview ? 2.h : 20.h,
                color: Color.fromARGB(132, 238, 238, 238),
              ),
              // if (hasReview) ...[
              //   CupertinoButton(
              //     child: Container(
              //       width: 1.sw,
              //       height: 100.h,
              //       color: Colors.white,
              //       child: Center(
              //         child: Text('预览', style: kContentTitle),
              //       ),
              //     ),
              //     onPressed: () {
              //       Get.back();
              //       Get.to(
              //           () => PhotoViewPage(images: [avatar], initialIndex: 0),
              //           transition: Transition.cupertino);
              //     },
              //   ),
              //   Container(
              //     width: 1.sw,
              //     height: 20.h,
              //     color: Color.fromARGB(132, 238, 238, 238),
              //   ),
              // ],
              CupertinoButton(
                child: Container(
                  width: 1.sw,
                  height: 100.h,
                  color: Colors.white,
                  child: Center(
                    child: Text('取消', style: kContentTitle),
                  ),
                ),
                onPressed: () async {
                  Get.back();
                },
              ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      body: Container(
        width: 1.sw,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 200.w),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                await _addImage();
              },
              child: Container(
                width: 230.w,
                height: 230.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  image: avatar != ''
                      ? DecorationImage(
                          image: NetworkImage(avatar),
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
                  infoButton(text: '称号', onPressed: () {}, hasDevider: false),
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.w, vertical: 25.w),
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
    return CupButton(
      onPressed: onPressed,
      child: Container(
        child: Row(
          children: [
            SizedBox(width: 40.w),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: hasDevider
                      ? Border(
                          bottom: BorderSide(
                          color: kDevideColor,
                          width: 2.w,
                        ))
                      : null,
                ),
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
      ),
    );
  }
}
