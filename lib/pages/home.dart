import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/constants/color.dart';
import 'package:test/constants/text.dart';
import 'package:test/pages/animation.dart';
import 'package:test/pages/scroller_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
                child: Text('ScrollViewPage', style: kPageTitle),
                onPressed: () {
                  Get.to(() => ScrollViewPage(),
                      transition: Transition.cupertino);
                }),
            CupertinoButton(
                child: Text('ParabolaAnimationPage', style: kPageTitle),
                onPressed: () {
                  Get.to(() => ParabolaAnimationPage(),
                      transition: Transition.cupertino);
                })
          ],
        ),
      ),
    );
  }
}
