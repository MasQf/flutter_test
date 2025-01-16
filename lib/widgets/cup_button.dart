import 'package:flutter/cupertino.dart';

class CupButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color normalColor;
  final Color pressedColor;
  final BorderRadiusGeometry? borderRadius;

  const CupButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.normalColor = CupertinoColors.white,
    this.pressedColor = const Color(0xFFd1d1d5),
    this.borderRadius,
  }) : super(key: key);

  @override
  _CupButtonState createState() => _CupButtonState();
}

class _CupButtonState extends State<CupButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (mounted) {
          setState(() => _isPressed = true);
        }
      },
      onTapCancel: () {
        if (mounted) {
          setState(() => _isPressed = false);
        }
      },
      onTapUp: (_) {
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() => _isPressed = false);
          }
        });
        widget.onPressed();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          color: _isPressed ? widget.pressedColor : widget.normalColor,
        ),
        child: widget.child,
      ),
    );
  }
}
