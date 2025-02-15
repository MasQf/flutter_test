import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;

  const ExpandableText({
    Key? key,
    required this.text,
    required this.style,
    this.maxLines = 4,
  }) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  late String displayText; // 要展示的文本
  bool isOverflow = false; // 是否超出 maxLines 限制
  double opacity = 0.0; // 控制隐藏文字的透明度

  @override
  void initState() {
    super.initState();
    _calculateText();
  }

  void _calculateText() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: 1.sw); // 计算宽度

    if (textPainter.didExceedMaxLines) {
      setState(() {
        isOverflow = true;
        displayText = _getTruncatedText();
      });
    } else {
      displayText = widget.text;
    }
  }

  /// **获取截断的文本，保证 "更多" 按钮在末尾**
  String _getTruncatedText() {
    final words = widget.text.split('');
    String truncatedText = "";

    for (var word in words) {
      final newText = truncatedText + word;
      final textPainter = TextPainter(
        text: TextSpan(
          text: "$newText...",
          style: widget.style,
          children: [
            TextSpan(
              text: "更多",
              style: TextStyle(
                color: Colors.black,
                fontSize: widget.style.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        maxLines: widget.maxLines,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: 1.sw);

      if (textPainter.didExceedMaxLines) {
        break;
      } else {
        truncatedText = newText;
      }
    }
    return truncatedText;
  }

  /// **展开文本**
  void _expandText() {
    setState(() {
      isExpanded = true;
    });
    // 开始透明度动画
    Future.delayed(Duration.zero, () {
      setState(() {
        opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: isExpanded ? widget.text : displayText,
            style: widget.style,
            children: (!isExpanded && isOverflow) // 只在未展开且超出时显示 "更多"
                ? [
                    TextSpan(
                      text: "...更多",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: widget.style.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = _expandText,
                    ),
                  ]
                : [],
          ),
        ),
      ],
    );
  }
}
