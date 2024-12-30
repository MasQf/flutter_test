import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/user.dart';
import 'package:test/constants/color.dart';
import 'package:test/widgets/head_bar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          HeadBar(title: '注册', canBack: true),
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
                      controller: nameController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '用户名',
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
                          '注册',
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
                        bool success = await UserApi.register(
                            name: nameController.text,
                            email: emailController.text,
                            password: passwordController.text);
                        if (success) {
                          Get.back();
                        }
                      } catch (e) {
                        print(e);
                      }
                    }),
                SizedBox(height: 20.w),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    '我好像有账号',
                    style: TextStyle(
                      fontSize: 37.sp,
                      color: kMainColor,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
