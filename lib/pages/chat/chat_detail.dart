import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test/api/api.dart';
import 'package:test/api/chat.dart';
import 'package:test/api/user.dart';
import 'package:test/constants/color.dart';
import 'package:test/controllers/chat.dart';
import 'package:test/controllers/user.dart';
import 'package:test/enum/message_type.dart';
import 'package:test/enum/photo_type.dart';
import 'package:test/models/message.dart';
import 'package:test/pages/photo_view.dart';
import 'package:test/services/socket.dart';
import 'package:test/widgets/chat_bubble.dart';
import 'package:test/widgets/button/cup_button.dart';
import 'package:test/pages/common/static_title_page.dart';
import 'package:dio/dio.dart' as oid;

class ChatDetailPage extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String targetName;
  final String targetAvatar;

  const ChatDetailPage({
    required this.senderId,
    required this.receiverId,
    required this.targetName,
    this.targetAvatar = '',
  });

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final SocketService _socketService = SocketService();
  final TextEditingController _messageController = TextEditingController();
  final UserController userController = Get.find<UserController>();
  ChatController chatController = Get.put(ChatController());
  final ScrollController _scrollController = ScrollController();

  late String _roomId;
  late String _senderId;
  late String _receiverId;
  List<MessageModel> _messages = [];

  FocusNode _focusNode = FocusNode();

  bool isLoading = true;

  final ImagePicker _picker = ImagePicker();
  List<String> _images = [];

  Future<void> loadDetailList({required String roomId}) async {
    try {
      final newDetailList = await ChatApi.detail(roomId: roomId);
      if (mounted) {
        setState(() {
          _messages.assignAll(newDetailList.reversed.toList());
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error Load Chat Detail List: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _senderId = widget.senderId;
    _receiverId = widget.receiverId;
    // Sort the list first and then join it to create the roomId
    List<String> ids = [_senderId, _receiverId];
    ids.sort();
    _roomId = ids.join('_');

    // 加载历史消息
    loadDetailList(roomId: _roomId);

    // 连接到 Socket.IO 服务器
    _socketService.connect('http://10.0.2.2:3000');
    // 加入房间
    _socketService.joinRoom(_roomId);
    // 重置未读消息数
    _socketService.resetUnreadCount(_roomId, _senderId);
    // 监听接收消息
    _socketService.receiveMessage((message) {
      MessageModel msg = MessageModel.fromJson(message);
      if (mounted) {
        setState(() {
          _messages.insert(0, msg);
        });
      }
    });
  }

  @override
  void deactivate() {
    print('deactivate...');
    super.deactivate();
  }

  @override
  void dispose() {
    // 离开房间
    _socketService.leaveRoom(_roomId);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage({MessageType messageType = MessageType.text}) {
    if (messageType == MessageType.text) {
      final String content = _messageController.text.trim();
      MessageModel msg = MessageModel(
        roomId: _roomId,
        senderId: _senderId,
        receiverId: _receiverId,
        content: content,
        type: 'text',
        time: DateTime.now().toIso8601String(),
      );
      if (content.isNotEmpty && mounted) {
        _socketService.sendMessage(msg);
        _messageController.clear();
      }
    } else if (messageType == MessageType.image) {
      final String content = jsonEncode(_images);
      MessageModel msg = MessageModel(
        roomId: _roomId,
        senderId: _senderId,
        receiverId: _receiverId,
        content: content,
        type: 'image',
        time: DateTime.now().toIso8601String(),
      );
      if (content.isNotEmpty && mounted) {
        _socketService.sendMessage(msg);
        _images.clear();
      }
    }
  }

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
    // 检查存储和位置权限
    final permissionState = await _getStoragePermission();
    if (!permissionState) {
      // 权限被拒绝 打开手机上该App的权限设置页面
      openAppSettings();
      return;
    }
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      return;
    } // 取消

    setState(() {
      isLoading = true;
    });

    try {
      final File imageFile = File(pickedFile.path);

      // 上传文件
      final String? imageUrl = await uploadFile(imageFile);
      if (imageUrl != null) {
        _images.add(imageUrl);
      }
    } catch (e) {
      debugPrint('Error in _takePhoto: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectPhotos() async {
    // 检查存储和位置权限
    final permissionState = await _getStoragePermission();
    if (!permissionState) {
      // 权限被拒绝 打开手机上该App的权限设置页面
      openAppSettings();
      return;
    }

    // 使用 pickMultiImage 来选择多张图片
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles == null || pickedFiles.isEmpty) return; // 用户取消选择或未选择图片

    setState(() {
      isLoading = true;
    });

    try {
      for (var pickedFile in pickedFiles) {
        final File imageFile = File(pickedFile.path);

        // 上传每一张图片
        final String? imageUrl = await uploadFile(imageFile);
        if (imageUrl != null) {
          _images.add(imageUrl);
        }
      }
      print("_images now: ${_images}");
    } catch (e) {
      debugPrint('Error in _selectPhotos: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showInfo({String? avatar, required String name}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      barrierColor: Colors.black.withOpacity(0),
      builder: (context) {
        return Container(
          width: 1.sw,
          height: 0.85.sh,
          decoration: BoxDecoration(
            color: kBackColor,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: Offset(0, -3),
              )
            ],
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: 1.sw,
                  padding: EdgeInsets.only(top: 200.w),
                  child: Column(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (avatar != null) {
                            Get.to(
                              () => PhotoViewPage(
                                images: [avatar],
                                initialIndex: 0,
                                hasPage: false,
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 230.w,
                          height: 230.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            image: (avatar?.isNotEmpty ?? false)
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(avatar!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (avatar?.isNotEmpty ?? false)
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
                        name,
                        style: TextStyle(
                          fontSize: 60.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 50.w),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 60.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Column(
                          children: [
                            infoButton(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r),
                                topRight: Radius.circular(30.r),
                              ),
                              onPressed: () {},
                              title: '发布',
                            ),
                            infoButton(
                              onPressed: () {},
                              title: '评价',
                            ),
                            infoButton(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30.r),
                                bottomRight: Radius.circular(30.r),
                              ),
                              onPressed: () {},
                              title: '称号',
                              hasDevider: false,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 80.w),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 60.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Column(
                          children: [
                            infoButton(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r),
                                topRight: Radius.circular(30.r),
                              ),
                              onPressed: () {},
                              title: '发布',
                              hasDevider: true,
                            ),
                            infoButton(
                              onPressed: () {},
                              title: '评价',
                              hasDevider: true,
                            ),
                            infoButton(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30.r),
                                bottomRight: Radius.circular(30.r),
                              ),
                              onPressed: () {},
                              title: '称号',
                              hasDevider: false,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 80.w),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 60.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Column(
                          children: [
                            infoButton(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r),
                                topRight: Radius.circular(30.r),
                              ),
                              onPressed: () {},
                              title: '发布',
                              hasDevider: true,
                            ),
                            infoButton(
                              onPressed: () {},
                              title: '评价',
                              hasDevider: true,
                            ),
                            infoButton(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30.r),
                                bottomRight: Radius.circular(30.r),
                              ),
                              onPressed: () {},
                              title: '称号',
                              hasDevider: false,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 80.w),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 60.w),
                        child: infoButton(
                          borderRadius: BorderRadius.circular(30.r),
                          onPressed: () {},
                          title: '举报',
                          titleColor: CupertinoColors.destructiveRed,
                          hasDevider: false,
                        ),
                      ),
                      SizedBox(height: 150.w),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1.sw,
                height: 130.w,
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: kDevideColor, width: 2.w))),
                child: Stack(
                  children: [
                    Positioned(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                          child: Container(
                            width: 1.sw,
                            height: 130.w,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.w),
                        child: Row(
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {},
                              child: Text(
                                '完成',
                                style: TextStyle(
                                  fontSize: 45.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                            Spacer(),
                            Text(
                              '个人信息',
                              style: TextStyle(
                                fontSize: 45.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Spacer(),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Get.back();
                              },
                              child: Text(
                                '完成',
                                style: TextStyle(
                                  fontSize: 45.sp,
                                  fontWeight: FontWeight.bold,
                                  color: kMainColor,
                                ),
                              ),
                            ),
                          ],
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
  Widget build(BuildContext context) {
    // 获取键盘高度
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // 根据键盘是否弹出动态调整高度
    final bottomBoxHeight =
        _images.isNotEmpty ? (keyboardHeight > 0 ? 0.35.sh : 0.4.sh) : (keyboardHeight > 0 ? 120.h : 200.h);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StaticTitlePage(
                  title: widget.targetName,
                  canBack: true,
                  controller: _scrollController,
                  pressBack: () {
                    chatController.loadChatList(userId: _senderId);
                    Get.back();
                  },
                  background: userController.background.value,
                  isReverse: true,
                  // 加载
                  // SliverToBoxAdapter(
                  //     child: Column(
                  //     children: [
                  //       SizedBox(height: 30.w),
                  //       myBubble(),
                  //       targetBubble(),
                  //       myBubble(),
                  //       targetBubble(),
                  //     ],
                  //   ))
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: _messages.length,
                      (context, index) {
                        final MessageModel message = _messages[index];
                        final isMe = message.senderId == _senderId;

                        return isMe
                            ? Container(
                                width: 1.sw,
                                margin: EdgeInsets.only(bottom: 40.h, top: index == _messages.length - 1 ? 40.h : 0),
                                padding: EdgeInsets.symmetric(horizontal: 30.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ChatBubble(
                                      isSentByMe: true,
                                      message: message.content,
                                      messageType: message.type == 'text' ? MessageType.text : MessageType.image,
                                    ),
                                    SizedBox(width: 30.w),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        _showInfo(avatar: userController.avatar.value, name: userController.name.value);
                                      },
                                      child: Container(
                                        width: 100.w,
                                        height: 100.w,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10.r),
                                            image: userController.avatar.value != ''
                                                ? DecorationImage(
                                                    image: CachedNetworkImageProvider(userController.avatar.value),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null),
                                        child: userController.avatar.value != ''
                                            ? null
                                            : Center(
                                                child: Icon(
                                                  CupertinoIcons.person_fill,
                                                  size: 100.w,
                                                  color: kGrey,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                width: 1.sw,
                                margin: EdgeInsets.only(bottom: 40.h, top: index == _messages.length - 1 ? 40.h : 0),
                                padding: EdgeInsets.symmetric(horizontal: 30.w),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        _showInfo(avatar: widget.targetAvatar, name: widget.targetName);
                                      },
                                      child: Container(
                                        width: 100.w,
                                        height: 100.w,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10.r),
                                            image: widget.targetAvatar != ''
                                                ? DecorationImage(
                                                    image: CachedNetworkImageProvider(widget.targetAvatar),
                                                    fit: BoxFit.cover)
                                                : null),
                                        child: widget.targetAvatar != ''
                                            ? null
                                            : Center(
                                                child: Icon(
                                                  CupertinoIcons.person_fill,
                                                  size: 100.w,
                                                  color: kGrey,
                                                ),
                                              ),
                                      ),
                                    ),
                                    SizedBox(width: 30.w),
                                    ChatBubble(
                                      isSentByMe: false,
                                      message: message.content,
                                      messageType: message.type == 'text' ? MessageType.text : MessageType.image,
                                    ),
                                  ],
                                ),
                              );
                      },
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 1.sw,
                height: bottomBoxHeight,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border(top: BorderSide(color: kDevideColor)),
                ),
                child: Stack(children: [
                  Positioned.fill(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                        child: Container(
                          height: 200.h,
                          width: 1.sw,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(height: 10.w),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 50.w),
                          Column(
                            children: [
                              if (_images.isNotEmpty) SizedBox(height: 550.h),
                              Row(
                                children: [
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      _takePhoto();
                                    },
                                    child: Icon(
                                      CupertinoIcons.camera_fill,
                                      color: kGrey,
                                      size: 80.w,
                                    ),
                                  ),
                                  SizedBox(width: 60.w),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      _selectPhotos();
                                    },
                                    child: Icon(
                                      CupertinoIcons.photo_fill,
                                      color: kGrey,
                                      size: 80.w,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(width: 50.w),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      _images.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(50.r),
                                              child: AnimatedContainer(
                                                duration: Duration(milliseconds: 200),
                                                width: 1.sw,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(50.r),
                                                  border: Border.all(
                                                    color: CupertinoColors.placeholderText,
                                                    width: 2.w,
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    // 已选图片
                                                    _selectedImages(),
                                                    Container(
                                                      width: 1.sw,
                                                      height: 2.h,
                                                      color: kDevideColor,
                                                    ),
                                                    Container(
                                                      height: 90.h,
                                                      width: 1.sw,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 600.w,
                                                            child: CupertinoTextField(
                                                              controller: _messageController,
                                                              focusNode: _focusNode,
                                                              placeholder: '信息',
                                                              placeholderStyle: TextStyle(
                                                                fontSize: 40.sp,
                                                                color: CupertinoColors.placeholderText,
                                                              ),
                                                              cursorHeight: 50.h,
                                                              style: TextStyle(
                                                                fontSize: 40.sp,
                                                                color: Colors.black,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: Colors.transparent,
                                                                borderRadius: BorderRadius.circular(50.r),
                                                                border: Border.all(
                                                                  color: Colors.transparent,
                                                                  width: 2.w,
                                                                ),
                                                              ),
                                                              padding: EdgeInsets.symmetric(
                                                                  horizontal: 30.w, vertical: 15.h),
                                                            ),
                                                          ),
                                                          CupertinoButton(
                                                            padding: EdgeInsets.zero,
                                                            onPressed: () {
                                                              if (_images.isNotEmpty) {
                                                                _sendMessage(messageType: MessageType.image);
                                                              } else {
                                                                _sendMessage();
                                                              }
                                                            },
                                                            child: Container(
                                                              width: 80.w,
                                                              height: 80.w,
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: CupertinoColors.activeGreen,
                                                              ),
                                                              child: Center(
                                                                child: Icon(
                                                                  CupertinoIcons.arrow_up,
                                                                  color: Colors.white,
                                                                  size: 60.w,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 700.w,
                                              decoration: BoxDecoration(
                                                color: CupertinoColors.white,
                                                borderRadius: BorderRadius.circular(50.r),
                                                border: Border.all(
                                                  color: CupertinoColors.placeholderText,
                                                  width: 2.w,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 600.w,
                                                    child: CupertinoTextField(
                                                      controller: _messageController,
                                                      focusNode: _focusNode,
                                                      placeholder: '信息',
                                                      placeholderStyle: TextStyle(
                                                        fontSize: 40.sp,
                                                        color: CupertinoColors.placeholderText,
                                                      ),
                                                      cursorHeight: 50.h,
                                                      style: TextStyle(
                                                        fontSize: 40.sp,
                                                        color: Colors.black,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: CupertinoColors.white,
                                                        borderRadius: BorderRadius.circular(50.r),
                                                        border: Border.all(
                                                          color: Colors.transparent,
                                                          width: 2.w,
                                                        ),
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                                                    ),
                                                  ),
                                                  CupertinoButton(
                                                    padding: EdgeInsets.zero,
                                                    onPressed: () {
                                                      if (_images.isNotEmpty) {
                                                        _sendMessage(messageType: MessageType.image);
                                                      } else {
                                                        _sendMessage();
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 80.w,
                                                      height: 80.w,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: CupertinoColors.activeGreen,
                                                      ),
                                                      child: Center(
                                                        child: Icon(
                                                          CupertinoIcons.arrow_up,
                                                          color: Colors.white,
                                                          size: 60.w,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 50.w),
                        ],
                      ),
                    ],
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectedImages() {
    return Container(
      height: 550.w,
      child: CustomScrollView(
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  String item = _images[index];
                  return Container(
                    child: GestureDetector(
                      onTap: () {
                        Get.to(
                          () => PhotoViewPage(images: _images, initialIndex: index),
                          transition: Transition.cupertino,
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            height: 600.h,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  replaceLocalhost(item),
                                ),
                                fit: BoxFit.cover,
                              ),
                              color: CupertinoColors.extraLightBackgroundGray,
                              borderRadius: BorderRadius.circular(40.r),
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
                              ))
                        ],
                      ),
                    ),
                  );
                },
                childCount: _images.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                // 保持原有网格配置
                mainAxisSpacing: 20.w,
                crossAxisSpacing: 40.w,
                crossAxisCount: 1,
                childAspectRatio: 2 / 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget myBubble() {
    return Container(
      margin: EdgeInsets.only(bottom: 30.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ChatBubble(
            isSentByMe: true,
            message: '',
            width: 0.5.sw,
            height: 300.h,
            myColor: Colors.white,
          ),
          SizedBox(width: 30.w),
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.person_fill,
                size: 100.w,
                color: kGrey,
              ),
            ),
          ),
          SizedBox(width: 30.w),
        ],
      ),
    );
  }

  Widget targetBubble() {
    return Container(
      margin: EdgeInsets.only(bottom: 30.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(width: 30.w),
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.person_fill,
                size: 100.w,
                color: kGrey,
              ),
            ),
          ),
          SizedBox(width: 30.w),
          ChatBubble(
            isSentByMe: false,
            message: '',
            width: 0.5.sw,
            height: 300.h,
          ),
        ],
      ),
    );
  }

  Widget infoButton({
    BorderRadiusGeometry? borderRadius,
    required void Function() onPressed,
    required String title,
    Color? titleColor = Colors.black,
    bool? hasDevider = true,
  }) {
    return CupButton(
        borderRadius: borderRadius,
        onPressed: onPressed,
        child: Container(
          width: 1.sw,
          child: Row(
            children: [
              SizedBox(width: 40.w),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: (hasDevider ?? false)
                        ? Border(
                            bottom: BorderSide(color: kDevideColor, width: 2.w),
                          )
                        : null,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20.w),
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 45.sp,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            CupertinoIcons.chevron_forward,
                            color: kGrey,
                            size: 60.w,
                          ),
                          SizedBox(width: 30.w),
                        ],
                      ),
                      SizedBox(height: 20.w),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
