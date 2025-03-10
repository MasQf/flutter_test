import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CenteredPageView extends StatefulWidget {
  @override
  _CenteredPageViewState createState() => _CenteredPageViewState();
}

class _CenteredPageViewState extends State<CenteredPageView> {
  final PageController _pageController = PageController(viewportFraction: 0.6);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _currentPage = _pageController.initialPage;
    });

    _pageController.addListener(() {
      if (!_pageController.hasClients ||
          !_pageController.position.hasContentDimensions) {
        return; // 避免未完成布局时报错
      }
      int newPage = (_pageController.page ?? 0).round();
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _snapToPage() {
    if (!_pageController.hasClients) return;
    int targetPage = (_pageController.page ?? 0).round();
    _pageController.animateToPage(
      targetPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 200,
          width: 50,
          child: GestureDetector(
            onPanEnd: (_) => _snapToPage(), // 松手后自动对齐
            child: PageView.builder(
              controller: _pageController,
              itemCount: 10,
              physics: BouncingScrollPhysics(), // 让滑动更自由
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.blue : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Item $index',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
