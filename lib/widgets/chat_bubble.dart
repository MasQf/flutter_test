import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatBubblePainter extends CustomPainter {
  final bool isSentByMe;
  final Color myColor;
  final Color targetColor;

  ChatBubblePainter({
    required this.isSentByMe,
    this.myColor = const Color(0xFF3478f6),
    this.targetColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // canvas 是由 CustomPaint 创建并传递给 CustomPainter 的 paint 方法,无需手动创建
    // 如果CustomPaint没有指明size,则painter中的size由child提供
    final paint = Paint()
      ..color = isSentByMe ? myColor : targetColor
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isSentByMe) {
      path.moveTo(20, 0);
      path.lineTo(size.width - 20, 0);
      path.arcToPoint(
        Offset(size.width, 20),
        radius: Radius.circular(20),
      );
      path.lineTo(size.width, size.height - 12);
      path.arcToPoint(
        Offset(size.width + 12, size.height),
        radius: Radius.circular(12),
        clockwise: false,
      );
      path.arcToPoint(
        Offset(size.width - 5, size.height - 5),
        radius: Radius.circular(40),
      );
      path.arcToPoint(
        Offset(size.width - 20, size.height),
        radius: Radius.circular(20),
      );
      path.lineTo(20, size.height);
      path.arcToPoint(
        Offset(0, size.height - 20),
        radius: Radius.circular(20),
      );
      path.lineTo(0, 20);
      path.arcToPoint(
        Offset(20, 0),
        radius: Radius.circular(20),
      );
      path.close();
    } else {
      path.moveTo(20, 0);
      path.lineTo(size.width - 20, 0);
      path.arcToPoint(
        Offset(size.width, 20),
        radius: Radius.circular(20),
      );
      path.lineTo(size.width, size.height - 20);
      path.arcToPoint(
        Offset(size.width - 20, size.height),
        radius: Radius.circular(20),
      );
      path.lineTo(20, size.height);
      path.arcToPoint(
        Offset(5, size.height - 5),
        radius: Radius.circular(20),
      );
      path.arcToPoint(
        Offset(-12, size.height),
        radius: Radius.circular(40),
      );
      path.arcToPoint(
        Offset(0, size.height - 12),
        radius: Radius.circular(12),
        clockwise: false,
      );
      path.lineTo(0, 20);
      path.arcToPoint(
        Offset(20, 0),
        radius: Radius.circular(20),
      );
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class ChatBubble extends StatelessWidget {
  final bool isSentByMe;
  final String message;
  final double? width;
  final double? height;
  final Color? myColor;
  final Color? targetColor;

  ChatBubble({
    required this.isSentByMe,
    required this.message,
    this.width,
    this.height,
    this.myColor = const Color(0xFF3478f6),
    this.targetColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ChatBubblePainter(
        isSentByMe: isSentByMe,
        myColor: myColor ?? const Color(0xFF3478f6),
        targetColor: targetColor ?? Colors.white,
      ),
      child: Container(
        width: width,
        height: height,
        constraints: BoxConstraints(
          minWidth: 110.w,
          minHeight: 90.w,
          maxWidth: 0.5.sw,
          maxHeight: 0.5.sw,
        ),
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.w),
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: Center(
              child: Text(
                message,
                style: TextStyle(
                  color: isSentByMe ? Colors.white : Colors.black,
                  fontSize: 37.sp,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
