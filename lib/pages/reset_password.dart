import 'package:flutter/material.dart';
import 'package:test/constants/color.dart';
import 'package:test/widgets/head_bar.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      body: Column(
        children: [
          HeadBar(title: '重置密码', canBack: true),
        ],
      ),
    );
  }
}
