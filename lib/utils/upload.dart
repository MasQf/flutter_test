import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test/api/api.dart';
import 'package:dio/dio.dart' as oid;

/// 获取存储权限
Future<bool> getStoragePermission() async {
  final PermissionStatus status = defaultTargetPlatform == TargetPlatform.iOS
      ? await Permission.photosAddOnly.request()
      : await Permission.storage.request();
  return status.isGranted;
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
