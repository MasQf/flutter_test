import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/user.dart';
import 'package:test/constants/color.dart';
import 'package:test/models/verification_code.dart';
import 'package:test/widgets/head_bar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  VerificationCodeModel? code;

  bool isCodeLoading = false;
  bool isLoading = false;
  bool canRegister = false;

  // 检查输入框内容不为空
  void _checkFormState() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final code = codeController.text.trim();
    final password = passwordController.text.trim();

    // 检查四个输入框是否都有内容
    final allFieldsNotEmpty = name.isNotEmpty &&
        email.isNotEmpty &&
        code.isNotEmpty &&
        password.isNotEmpty;

    setState(() {
      canRegister = allFieldsNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();

    // 添加监听器到每个输入框
    nameController.addListener(_checkFormState);
    emailController.addListener(_checkFormState);
    codeController.addListener(_checkFormState);
    passwordController.addListener(_checkFormState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      body: Column(
        children: [
          HeadBar(title: '注册', canBack: true),
          Stack(children: [
            if (isLoading)
              Center(
                  child: Stack(
                children: [
                  Container(
                    width: 300.w,
                    height: 300.w,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(40.r)),
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
                ],
              )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 20.w),
              child: Column(
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 150.w,
                            child: Text(
                              '用户名',
                              style: TextStyle(
                                  fontSize: 40.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 120.h,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 214, 214, 214),
                                    width: 2.w,
                                  )),
                              child: Center(
                                child: TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '用户名',
                                      hintStyle: TextStyle(
                                          fontSize: 40.sp,
                                          color: const Color.fromARGB(
                                              255, 198, 198, 198))),
                                  style: TextStyle(
                                    fontSize: 40.sp,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.w),
                      Row(
                        children: [
                          Container(
                            width: 150.w,
                            child: Text(
                              '邮箱',
                              style: TextStyle(
                                  fontSize: 40.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 120.h,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 214, 214, 214),
                                    width: 2.w,
                                  )),
                              child: Center(
                                child: TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '邮箱',
                                      hintStyle: TextStyle(
                                          fontSize: 40.sp,
                                          color: const Color.fromARGB(
                                              255, 198, 198, 198))),
                                  style: TextStyle(
                                    fontSize: 40.sp,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.w),
                      Row(
                        children: [
                          Container(
                            width: 150.w,
                            child: Text(
                              '验证码',
                              style: TextStyle(
                                  fontSize: 40.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 120.h,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 214, 214, 214),
                                    width: 2.w,
                                  )),
                              child: Center(
                                child: TextField(
                                  controller: codeController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '验证码',
                                      hintStyle: TextStyle(
                                          fontSize: 40.sp,
                                          color: const Color.fromARGB(
                                              255, 198, 198, 198))),
                                  style: TextStyle(
                                    fontSize: 40.sp,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: Stack(children: [
                                Container(
                                  height: 120.h,
                                  width: 150.w,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 30.w),
                                  decoration: BoxDecoration(
                                    color: isCodeLoading
                                        ? Colors.transparent
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: isCodeLoading
                                        ? Border.all(
                                            color: Colors.transparent,
                                            width: 2.w,
                                          )
                                        : Border.all(
                                            color: const Color.fromARGB(
                                                255, 214, 214, 214),
                                            width: 2.w,
                                          ),
                                  ),
                                  child: Center(
                                    child: isCodeLoading
                                        ? CupertinoActivityIndicator(
                                            radius: 30.r)
                                        : Text(
                                            '获取',
                                            style: TextStyle(
                                              fontSize: 40.sp,
                                              fontWeight: FontWeight.bold,
                                              color: kMainColor,
                                            ),
                                          ),
                                  ),
                                ),
                              ]),
                              onPressed: () async {
                                setState(() {
                                  isCodeLoading = true;
                                });
                                // var res = await UserApi.sendCode(
                                //     email: emailController.text);
                                // // 判断返回结果
                                // if (res is VerificationCodeModel) {
                                //   // 处理验证码
                                //   code = res;
                                // } else {
                                //   // 处理其他类型的返回数据
                                //   print("Error: ${res['msg']}");
                                // }
                                // setState(() {
                                //   isCodeLoading = false;
                                // });
                              }),
                        ],
                      ),
                      SizedBox(height: 20.w),
                      Row(
                        children: [
                          Container(
                            width: 150.w,
                            child: Text(
                              '密码',
                              style: TextStyle(
                                  fontSize: 40.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 120.h,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 214, 214, 214),
                                    width: 2.w,
                                  )),
                              child: Center(
                                child: TextField(
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '密码',
                                      hintStyle: TextStyle(
                                          fontSize: 40.sp,
                                          color: const Color.fromARGB(
                                              255, 198, 198, 198))),
                                  style: TextStyle(
                                    fontSize: 40.sp,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 100.h),
                  canRegister
                      ? CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                            width: 1.sw,
                            height: 120.h,
                            decoration: BoxDecoration(
                              color: isLoading
                                  ? Colors.white.withOpacity(0.5)
                                  : kMainColor,
                              borderRadius: BorderRadius.circular(40.r),
                            ),
                            child: Center(
                              child: isLoading
                                  ? CupertinoActivityIndicator(radius: 30.r)
                                  : Text(
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
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              bool success = await UserApi.register(
                                  name: nameController.text,
                                  email: emailController.text,
                                  code: codeController.text,
                                  password: passwordController.text);
                              if (success) {
                                Get.back();
                              }
                            } catch (e) {
                              print(e);
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          })
                      : CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                            width: 1.sw,
                            height: 120.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: Text(
                                '注册',
                                style: TextStyle(
                                  fontSize: 45.w,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {})
                ],
              ),
            ),
          ])
        ],
      ),
    );
  }
}
