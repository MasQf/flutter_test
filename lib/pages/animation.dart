import 'dart:math';

import 'package:flutter/material.dart';

class ParabolaAnimationPage extends StatefulWidget {
  @override
  _ParabolaAnimationPageState createState() => _ParabolaAnimationPageState();
}

class _ParabolaAnimationPageState extends State<ParabolaAnimationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  double startX = 0.0; // 起始 x 坐标
  double startY = 10.0; // 起始 y 坐标（y = -x^2 - x + 10 的最大值）

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // 动画持续时间
    );

    _animation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('实现 -x^2 - x + 10'),
      ),
      body: Stack(
        children: [
          // 动画移动的图片
          Positioned(
            left: _getXPosition(_animation.value),
            top: _getYPosition(_animation.value),
            child: Image.asset(
              'assets/images/cate1.jpg',
              width: 50,
              height: 50,
            ),
          ),
          // 控制按钮
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 50.0),
              child: ElevatedButton(
                onPressed: () {
                  _controller.forward(from: 0);
                },
                child: Text('开始动画'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 根据 x 计算 y 值
  double _getYPosition(double x) {
    // y = -x^2 - x + 10
    return -pow(x, 2) - x + 10;
  }

  /// 根据 x 映射到屏幕位置
  double _getXPosition(double x) {
    // 将数学坐标映射到屏幕坐标
    double screenWidth = MediaQuery.of(context).size.width;
    return (x + 5) * (screenWidth / 10); // 假设 x 的范围为 [-5, 5]
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
