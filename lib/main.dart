import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/pages/splash.dart';

class MyScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return BouncingScrollPhysics(); // 去掉弹性
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 确保 Flutter 绑定初始化
  // 设置系统 UI 样式
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // 设置状态栏背景色为透明
    statusBarIconBrightness: Brightness.dark, // 状态栏图标为深色
    systemNavigationBarColor: Colors.white, // 设置导航栏背景色
    systemNavigationBarIconBrightness: Brightness.dark, // 设置导航栏图标为深色
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1080, 1920),
      builder: (context, child) => GetMaterialApp(
        scrollBehavior: MyScrollBehavior(),
        debugShowCheckedModeBanner: false,
        home: SplashPage(),
      ),
    );
  }
}
