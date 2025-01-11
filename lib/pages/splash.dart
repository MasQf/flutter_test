import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/api/user.dart';
import 'package:test/utils/token.dart';
import 'package:test/controllers/user.dart';
import 'package:test/pages/home.dart';
import 'package:test/pages/login.dart';
import 'package:test/pages/root.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  UserController userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final String? token = await getToken();

    if (token == null) {
      // 没有 Token，跳转到登录页
      print('没有 Token，跳转到登录页');
      Get.offAll(() => LoginPage(), transition: Transition.cupertino);
    } else {
      try {
        // 有token,设置请求头
        Api().setToken(token);
        // 调用验证接口
        var res = await UserApi.verifyToken();

        if (res['status']) {
          // 验证成功,更新 Token
          final newToken = res['token'];
          await saveToken(newToken);
          userController.id.value = res['user']['_id'];
          userController.name.value = res['user']['name'];
          userController.email.value = res['user']['email'];
          userController.avatar.value = res['user']['avatar'];

          Get.offAll(() => RootPage(),
              transition: Transition.cupertino); // 跳转到首页
        } else {
          // 验证失败，跳转到登录页
          Get.offAll(() => LoginPage(), transition: Transition.cupertino);
        }
      } catch (e) {
        print('Error verifying token: $e');
        Get.offAll(() => LoginPage(), transition: Transition.cupertino);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }
}
