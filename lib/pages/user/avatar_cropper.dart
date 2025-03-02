import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

/// 主页面：选择图片、拖动调整，点击确认按钮进行裁剪
class AvatarCropperPage extends StatefulWidget {
  @override
  _AvatarCropperPageState createState() => _AvatarCropperPageState();
}

class _AvatarCropperPageState extends State<AvatarCropperPage> {
  File? _imageFile;
  Size? _imageNaturalSize; // 图片原始尺寸
  ui.Image? _uiImage; // 用于绘制裁剪的 ui.Image
  Offset _offset = Offset.zero; // 背景图片平移偏移
  bool _isOffsetInitialized = false; // 是否已初始化图片偏移
  final ImagePicker _picker = ImagePicker();
  final double cropDiameter = 0.9.sw; // 裁剪圆形区域直径

  /// 选择图片，并获取图片尺寸及 ui.Image
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      File file = File(picked.path);
      Size naturalSize = await _getImageSize(file);
      ui.Image loadedUiImage = await _loadUiImage(file);
      setState(() {
        _imageFile = file;
        _imageNaturalSize = naturalSize;
        _uiImage = loadedUiImage;
        _isOffsetInitialized = false;
        _offset = Offset.zero;
      });
    }
  }

  /// 获取图片自然尺寸
  Future<Size> _getImageSize(File file) async {
    final bytes = await file.readAsBytes();
    final completer = Completer<Size>();
    ui.decodeImageFromList(bytes, (image) {
      completer.complete(Size(image.width.toDouble(), image.height.toDouble()));
    });
    return completer.future;
  }

  /// 获取 ui.Image 对象
  Future<ui.Image> _loadUiImage(File file) async {
    final bytes = await file.readAsBytes();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, (image) {
      completer.complete(image);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    // 未选择图片时显示选择按钮
    if (_imageFile == null || _imageNaturalSize == null) {
      return Scaffold(
        appBar: AppBar(title: Text("头像裁剪")),
        body: Center(
          child: ElevatedButton(
            onPressed: _pickImage,
            child: Text("选择图片"),
          ),
        ),
      );
    }

    // 利用 LayoutBuilder 获取屏幕尺寸
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final imageAspect =
            _imageNaturalSize!.width / _imageNaturalSize!.height;
        double displayedWidth, displayedHeight;
        if (imageAspect > (screenWidth / screenHeight)) {
          // 图片较宽：宽度铺满屏幕，高度按比例缩放
          displayedWidth = screenWidth;
          displayedHeight = screenWidth / imageAspect;
        } else {
          // 图片较高：高度铺满屏幕，宽度按比例缩放
          displayedHeight = screenHeight;
          displayedWidth = screenHeight * imageAspect;
        }

// 默认居中显示图片
        Offset defaultOffset = Offset(
          (screenWidth - displayedWidth) / 2,
          (screenHeight - displayedHeight) / 2,
        );
        if (!_isOffsetInitialized) {
          _offset = defaultOffset;
          _isOffsetInitialized = true;
        }

// 裁剪圆圈的参数（屏幕中心）
        final circleCenter = Offset(screenWidth / 2, screenHeight / 2);
        final r = cropDiameter / 2;

// 计算允许的拖动范围，确保圆圈（圆心在屏幕中心）边缘不会超出图片的边缘
        double allowedMinX, allowedMaxX;
        if (displayedWidth < cropDiameter) {
          // 图片宽度不足以完全覆盖裁剪圆，固定偏移，禁止横向拖动
          allowedMinX = allowedMaxX = defaultOffset.dx;
        } else {
          allowedMinX = circleCenter.dx + r - displayedWidth;
          allowedMaxX = circleCenter.dx - r;
        }

        double allowedMinY, allowedMaxY;
        if (displayedHeight < cropDiameter) {
          // 图片高度不足以完全覆盖裁剪圆，固定偏移，禁止纵向拖动
          allowedMinY = allowedMaxY = defaultOffset.dy;
        } else {
          allowedMinY = circleCenter.dy + r - displayedHeight;
          allowedMaxY = circleCenter.dy - r;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("头像裁剪"),
            actions: [
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () async {
                  // 点击按钮时，根据当前参数裁剪圆形区域内的图片
                  final screenSize = MediaQuery.of(context).size;
                  final sw = screenSize.width;
                  final sh = screenSize.height;
                  // 重新计算图片显示尺寸（与上面一致）
                  double dw, dh;
                  if (imageAspect > (sw / sh)) {
                    dw = sw;
                    dh = sw / imageAspect;
                  } else {
                    dh = sh;
                    dw = sh * imageAspect;
                  }
                  // 裁剪区域在屏幕中位于中心，左上角坐标：
                  final cropTopLeft = Offset(
                      sw / 2 - cropDiameter / 2, sh / 2 - cropDiameter / 2);
                  // 相对于裁剪区域，图片的平移偏移：
                  final relativeOffset = _offset - cropTopLeft;

                  // 使用 PictureRecorder 在 offscreen Canvas 上绘制裁剪区域
                  final recorder = ui.PictureRecorder();
                  final canvas = Canvas(recorder,
                      Rect.fromLTWH(0, 0, cropDiameter, cropDiameter));

                  // 先剪裁为圆形
                  Path clipPath = Path()
                    ..addOval(Rect.fromLTWH(0, 0, cropDiameter, cropDiameter));
                  canvas.clipPath(clipPath);

                  // 目标区域：将图片绘制到 offscreen Canvas 时的位置
                  final destRect = Rect.fromLTWH(
                      relativeOffset.dx, relativeOffset.dy, dw, dh);
                  // 源区域：整个图片
                  final srcRect = Rect.fromLTWH(0, 0,
                      _uiImage!.width.toDouble(), _uiImage!.height.toDouble());
                  canvas.drawImageRect(_uiImage!, srcRect, destRect, Paint());

                  // 完成绘制并获取裁剪后的 ui.Image
                  final picture = recorder.endRecording();
                  final croppedImage = await picture.toImage(
                      cropDiameter.toInt(), cropDiameter.toInt());

                  // 跳转到新页面，展示裁剪后的头像
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CroppedAvatarPage(croppedImage: croppedImage),
                    ),
                  );
                },
              )
            ],
          ),
          body: Stack(
            children: [
              // 背景图片：全屏显示，并允许拖动
              Positioned.fill(
                child: GestureDetector(
                  onPanUpdate: (details) {
                    Offset newOffset = _offset + details.delta;
                    // 限制偏移，确保圆形区域始终处于图片内部
                    double clampedX =
                        newOffset.dx.clamp(allowedMinX, allowedMaxX);
                    double clampedY =
                        newOffset.dy.clamp(allowedMinY, allowedMaxY);
                    setState(() {
                      _offset = Offset(clampedX, clampedY);
                    });
                  },
                  child: Transform.translate(
                    offset: _offset,
                    child: SizedBox(
                      width: displayedWidth,
                      height: displayedHeight,
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              // 裁剪蒙层：全屏覆盖，但使用 IgnorePointer 忽略手势，使下层的拖动生效
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: CropperOverlayPainter(cropDiameter: cropDiameter),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// CustomPainter：绘制半透明遮罩和中央裁剪圆形区域边框
class CropperOverlayPainter extends CustomPainter {
  final double cropDiameter;
  CropperOverlayPainter({required this.cropDiameter});

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final circleRect =
        Rect.fromCircle(center: center, radius: cropDiameter / 2);

    // 整个屏幕蒙层
    final overlayPath = Path()..addRect(fullRect);
    // 中心圆形区域
    final circlePath = Path()..addOval(circleRect);
    // 从蒙层中减去圆形区域
    final finalPath =
        Path.combine(PathOperation.difference, overlayPath, circlePath);

    canvas.drawPath(finalPath, Paint()..color = Colors.black.withOpacity(0.5));
    // // 绘制白色边框提示裁剪区域
    // canvas.drawOval(
    //   circleRect,
    //   Paint()
    //     ..color = Colors.white
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = 2,
    // );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 新页面：展示裁剪后的头像
class CroppedAvatarPage extends StatelessWidget {
  final ui.Image croppedImage;
  const CroppedAvatarPage({Key? key, required this.croppedImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("裁剪后头像")),
      body: Center(
        child: RawImage(image: croppedImage),
      ),
    );
  }
}
