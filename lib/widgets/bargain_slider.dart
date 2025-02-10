import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test/constants/color.dart';

class BargainSlider extends StatefulWidget {
  final double minPrice; // 最低价格
  final double maxPrice; // 最高价格
  final Function(double) onPriceChanged; // 价格改变回调
  final double sliderWidth;
  final double sliderHeight;

  const BargainSlider({
    Key? key,
    required this.minPrice,
    required this.maxPrice,
    required this.onPriceChanged,
    this.sliderWidth = 50,
    this.sliderHeight = 700,
  }) : super(key: key);

  @override
  State<BargainSlider> createState() => _BargainSliderState();
}

class _BargainSliderState extends State<BargainSlider> {
  late double _currentPrice;
  late double _sliderPosition;
  // 砍价条总宽度
  double sliderWidth = 50.w;
  // 砍价条总高度
  double sliderHeight = 700.h;

  bool isDragging = false; // 添加拖动状态

  // 检查是否在可拖动区域内（包括横线和圆形）
  bool _isInDraggableArea(Offset position, Size size) {
    // 圆形中心点
    final circleCenter = Offset(-(size.width * 5), _sliderPosition + 50.h);
    // 计算触摸点到圆心的距离
    final distance = (position - circleCenter).distance;
    // 如果在圆形范围内或者在横线上
    return distance <= 30.w || (position.dy >= _sliderPosition + 45.h && position.dy <= _sliderPosition + 55.h);
  }

  @override
  void initState() {
    super.initState();
    _currentPrice = (widget.maxPrice - widget.minPrice) * 0.8;
    sliderWidth = widget.sliderWidth.w;
    sliderHeight = widget.sliderHeight.h;
    _sliderPosition = 0.2 * sliderHeight;
  }

  // double _priceToPosition(double price) {
  //   return 0.2 * sliderHeight;
  // }

  double _positionToPrice(double position) {
    return widget.maxPrice - (position / sliderHeight) * (widget.maxPrice - widget.minPrice);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _sliderPosition = (_sliderPosition + details.delta.dy).clamp(0, sliderHeight);
          _currentPrice = _positionToPrice(_sliderPosition);
          widget.onPriceChanged(_currentPrice);
        });
      },
      child: Container(
        width: sliderWidth,
        height: sliderHeight,
        color: Colors.transparent,
        child: CustomPaint(
          painter: BargainPainter(
            minPrice: widget.minPrice,
            maxPrice: widget.maxPrice,
            currentPrice: _currentPrice,
            sliderPosition: _sliderPosition,
          ),
        ),
      ),
    );
  }
}

class BargainPainter extends CustomPainter {
  final double minPrice;
  final double maxPrice;
  final double currentPrice;
  final double sliderPosition;

  BargainPainter({
    required this.minPrice,
    required this.maxPrice,
    required this.currentPrice,
    required this.sliderPosition,
  });

  // 边宽度
  double sideWidth = 7.w;
  // 背景条边框宽度
  double bgBoderWidth = 2.5.w;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kDevideColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(-(size.width / 2) - 100.w, -(bgBoderWidth * 3));
    path.lineTo((size.width / 2) + 100.w, -(bgBoderWidth * 3));
    path.arcToPoint(
      Offset((size.width / 2) + 100.w, 0),
      radius: Radius.circular(40.r),
    );
    path.lineTo((size.width / 2) + 40.w, 0);
    path.arcToPoint(
      Offset((size.width / 2) + (bgBoderWidth * 3), 40.w),
      radius: Radius.circular(40.r),
      clockwise: false,
    );
    path.lineTo((size.width / 2) + (bgBoderWidth * 3), size.height - 40.w);
    path.arcToPoint(
      Offset((size.width / 2) + (bgBoderWidth * 3) + 40.w, size.height),
      radius: Radius.circular(40.r),
      clockwise: false,
    );
    path.lineTo((size.width / 2) + 100.w, size.height);
    path.arcToPoint(
      Offset((size.width / 2) + 100.w, size.height + (bgBoderWidth * 3)),
      radius: Radius.circular(40.r),
    );
    path.lineTo(-(size.width / 2) - 100.w, size.height + (bgBoderWidth * 3));

    path.arcToPoint(
      Offset(-(size.width / 2) - 100.w, size.height),
      radius: Radius.circular(40.r),
    );
    path.lineTo(-(size.width / 2) - (bgBoderWidth * 3) - 40.w, size.height);
    path.arcToPoint(
      Offset(-(size.width / 2) - (bgBoderWidth * 3), size.height - 40.w),
      radius: Radius.circular(40.r),
      clockwise: false,
    );
    path.lineTo(-(size.width / 2) - (bgBoderWidth * 3), 40.w);
    path.arcToPoint(
      Offset(-(size.width / 2) - (bgBoderWidth * 3) - 40.w, 0),
      radius: Radius.circular(40.r),
      clockwise: false,
    );
    path.lineTo(-(size.width / 2) - 100.w, 0);
    path.arcToPoint(
      Offset(-(size.width / 2) - 100.w, (bgBoderWidth * 3)),
      radius: Radius.circular(40.r),
    );

    canvas.drawPath(path, paint);

    // // 背景条边框
    // final bgLinePaint = Paint()
    //   ..color = kGrey
    //   ..style = PaintingStyle.fill;

    // final bgBorderpath = Path();
    // bgBorderpath.moveTo(-(size.width / 2) - bgBoderWidth, -bgBoderWidth);
    // bgBorderpath.lineTo((size.width / 2) + bgBoderWidth, -bgBoderWidth);
    // bgBorderpath.lineTo((size.width / 2) + bgBoderWidth, size.height + bgBoderWidth);
    // bgBorderpath.lineTo(-(size.width / 2) - bgBoderWidth, size.height + bgBoderWidth);
    // canvas.drawPath(bgBorderpath, bgLinePaint);

    // 背景条
    final bgPaint = Paint()
      ..color = kDevideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width;

    canvas.drawLine(
      Offset(0, 0),
      Offset(0, size.height),
      bgPaint,
    );

    // 最大价格
    final maxPricePainter = TextPainter(
      text: TextSpan(
        text: maxPrice.toStringAsFixed(2),
        style: TextStyle(
          fontFamily: 'KaushanScript',
          color: Colors.white,
          fontSize: 45.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    maxPricePainter.layout();
    maxPricePainter.paint(
      canvas,
      Offset(3 * size.width + 50.w, -30.w),
    );

    // 最小价格
    final minPricePainter = TextPainter(
      text: TextSpan(
        text: minPrice.toStringAsFixed(2),
        style: TextStyle(
          fontFamily: 'KaushanScript',
          color: Colors.white,
          fontSize: 45.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    minPricePainter.layout();
    minPricePainter.paint(
      canvas,
      Offset(3 * size.width + 50.w, size.height - 30.w),
    );

    // 已选择部分
    final selectedPaint = Paint()
      ..color = kMainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width;

    canvas.drawLine(
      Offset(0, sliderPosition),
      Offset(0, size.height),
      selectedPaint,
    );

    // 推荐条阴影
    final recommendShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..strokeWidth = 10.w
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5); //模糊

    canvas.drawLine(
      Offset(-(2.5 * size.width), 0.2 * size.height + 4.w), // 稍微偏移一点位置
      Offset(2.5 * size.width, 0.2 * size.height + 4.w),
      recommendShadowPaint,
    );

    // 推荐价位横条(80%)
    final recommendPaint = Paint()
      ..color = kDevideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = bgBoderWidth * 2;

    canvas.drawLine(
      Offset(-(2.5 * size.width), 0.2 * size.height),
      Offset(2.5 * size.width, 0.2 * size.height),
      recommendPaint,
    );

    // 推荐价格
    final recommendPricePainter = TextPainter(
      text: TextSpan(
        text: (maxPrice - (maxPrice - minPrice) * 0.2).toStringAsFixed(2),
        style: TextStyle(
          fontFamily: 'KaushanScript',
          color: Colors.amber,
          fontSize: 35.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    recommendPricePainter.layout();
    recommendPricePainter.paint(
      canvas,
      Offset(3 * size.width, 0.2 * size.height - 25.w),
    );

    // 滑块阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..strokeWidth = 10.w
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5); //模糊

    canvas.drawLine(
      Offset(-(size.width * 5), sliderPosition + 4.w), // 稍微偏移一点位置
      Offset((size.width / 2), sliderPosition + 4.w),
      shadowPaint,
    );

    // 滑块边框
    // final borderPaint = Paint()
    //   ..color = Colors.grey
    //   ..style = PaintingStyle.fill
    //   ..strokeWidth = 15.w;

    // canvas.drawLine(
    //   Offset(-(size.width * 2) - bgBoderWidth, sliderPosition), // 稍微偏移一点位置
    //   Offset((size.width * 2) + bgBoderWidth, sliderPosition),
    //   borderPaint,
    // );

    // 滑块
    final sliderPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill
      ..strokeWidth = bgBoderWidth * 2;

    canvas.drawLine(
      Offset(-(size.width * 5), sliderPosition),
      Offset((size.width / 2) + (bgBoderWidth * 3), sliderPosition),
      sliderPaint,
    );

    // 价格
    // 价格
    final priceText = '${currentPrice.toStringAsFixed(2)}';
    final pricePainter = TextPainter(
      text: TextSpan(
        text: priceText,
        style: TextStyle(
          fontFamily: 'KaushanScript',
          color: currentPrice.toStringAsFixed(2) == (maxPrice - (maxPrice - minPrice) * 0.2).toStringAsFixed(2)
              ? Colors.amber
              : Colors.white,
          fontSize: 45.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

// 计算文本布局
    pricePainter.layout();

// 根据文本宽度动态调整绘制位置
    final textWidth = pricePainter.width;
    pricePainter.paint(
      canvas,
      Offset(-5 * size.width - textWidth - 30.w, sliderPosition - 30.w),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
