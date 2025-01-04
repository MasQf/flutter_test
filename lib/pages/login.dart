import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/api/user.dart';
import 'package:test/constants/color.dart';
import 'package:test/controllers/token.dart';
import 'package:test/controllers/user.dart';
import 'package:test/models/user.dart';
import 'package:test/pages/home.dart';
import 'package:test/pages/register.dart';
import 'package:test/pages/reset_password.dart';
import 'package:test/widgets/head_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UserController userController = Get.find<UserController>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      body: Column(
        children: [
          HeadBar(title: '登录'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 20.w),
            child: Column(
              children: [
                Container(
                  width: 1.sw,
                  height: 120.h,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: const Color.fromARGB(255, 214, 214, 214),
                        width: 2.w,
                      )),
                  child: Center(
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '电子邮件',
                          hintStyle: TextStyle(
                              fontSize: 37.sp,
                              color: const Color.fromARGB(255, 198, 198, 198))),
                    ),
                  ),
                ),
                SizedBox(height: 20.w),
                Container(
                  width: 1.sw,
                  height: 120.h,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: const Color.fromARGB(255, 214, 214, 214),
                        width: 2.w,
                      )),
                  child: Center(
                    child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '密码',
                          hintStyle: TextStyle(
                              fontSize: 37.sp,
                              color: const Color.fromARGB(255, 198, 198, 198))),
                    ),
                  ),
                ),
                SizedBox(height: 100.w),
                CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: 1.sw,
                      height: 120.h,
                      decoration: BoxDecoration(
                        color: kMainColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          '登录',
                          style: TextStyle(
                            fontSize: 45.w,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        var res = await UserApi.login(
                            email: emailController.text,
                            password: passwordController.text);
                        if (res['status']) {
                          String token = res['token'];
                          await saveToken(token);
                          print('token: ${token}');

                          userController.name.value = res['user']['name'];
                          userController.email.value = res['user']['email'];

                          Get.to(() => HomePage(),
                              transition: Transition.cupertino);
                        }
                      } catch (e) {
                        print(e);
                      }
                    }),
                SizedBox(height: 20.w),
                CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: 1.sw,
                      height: 120.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          '注册',
                          style: TextStyle(
                            fontSize: 45.w,
                            fontWeight: FontWeight.bold,
                            color: kMainColor,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Get.to(() => RegisterPage(),
                          transition: Transition.cupertino);
                    }),
                CupertinoButton(
                    child: Text(
                      '忘记密码?',
                      style: TextStyle(
                        fontSize: 37.sp,
                        fontWeight: FontWeight.bold,
                        color: kMainColor,
                      ),
                    ),
                    onPressed: () {
                      Get.to(() => ResetPasswordPage(),
                          transition: Transition.cupertino);
                    })
              ],
            ),
          )
        ],
      ),
    );
  }
}
