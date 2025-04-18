import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/user.dart';
import 'package:test/constants/color.dart';
import 'package:test/controllers/user.dart';
import 'package:test/pages/user/reset_password.dart';
import 'package:test/widgets/button/cup_button.dart';
import 'package:test/widgets/head_bar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final UserController _userController = Get.find<UserController>();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = _userController.name.value ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // 显示重置密码确认对话框
  void _showResetPasswordDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('重置密码'),
          content: const Text('确定要重置密码吗？将会跳转到重置密码页面。'),
          actions: [
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () {
                Get.back();
                Get.to(() => ResetPasswordPage(),
                    transition: Transition.cupertino);
              },
            ),
          ],
        );
      },
    );
  }

  // 保存用户名
  Future<void> _saveUsername() async {
    final newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) {
      Get.snackbar('错误', '用户名不能为空');
      return;
    }

    if (newUsername == _userController.name.value) {
      Get.back(); // 如果没有修改，直接返回
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await UserApi.updateUsername(
        userId: _userController.id.value!,
        name: newUsername,
      );

      if (result) {
        // 更新本地用户信息
        _userController.name.value = newUsername;

        Get.back();
      } else {}
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HeadBar(
              title: '编辑个人信息',
              canBack: true,
              rightWidget: _isLoading
                  ? const CupertinoActivityIndicator()
                  : CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        '保存',
                        style: TextStyle(
                          color: kMainColor,
                          fontSize: 45.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _saveUsername,
                    ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('基本信息'),
                      _buildInfoItem(
                        label: '用户名',
                        isEditable: true,
                        content: _usernameController.text,
                        controller: _usernameController,
                      ),
                      _buildInfoItem(
                        label: '电子邮件',
                        isEditable: false,
                        content: _userController.email.value,
                      ),
                      _buildPasswordItem(
                        onTap: _showResetPasswordDialog,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String content,
    required bool isEditable,
    TextEditingController? controller,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          isEditable
              ? TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    fontSize: 16.sp,
                  ),
                )
              : Text(
                  content,
                  style: TextStyle(
                    fontSize: 16.sp,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPasswordItem({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '密码',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '点击重置密码',
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
