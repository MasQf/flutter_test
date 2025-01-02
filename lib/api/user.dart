import 'package:dio/dio.dart';
import 'package:test/api/api.dart';
import 'package:test/models/verification_code.dart';

class UserApi {
  static Future<dynamic> login(
      {required String email, required String password}) async {
    try {
      final response = await Api()
          .post('/login', data: {"email": email, "password": password});
      var data = response.data;

      return data;
    } catch (e) {
      throw Exception("Error login: $e");
    }
  }

  static Future<bool> register(
      {required String name,
      required String email,
      required String code,
      required String password}) async {
    try {
      final response = await Api().post('/register', data: {
        "name": name,
        "email": email,
        "code": code,
        "password": password
      });
      var status = response.data['status'];

      return status;
    } catch (e) {
      throw Exception("Error login: $e");
    }
  }

  // 发送邮箱验证码
  static Future<dynamic> sendCode({required String email}) async {
    try {
      final response = await Api().post(
        '/send_verification_code',
        data: {
          "email": email,
        },
        options: Options(
          validateStatus: (status) {
            // 接受 200 和 500 状态码
            return status == 200 || status == 500;
          },
        ),
      );

      // 检查响应状态
      if (response.statusCode == 500) {
        // 服务器返回 500 错误时的处理
        if (response.data == null) {
          return {
            "msg": "Server error with no additional information",
            "status": false,
          };
        }

        String errorMessage = response.data['msg'] ?? 'Unknown error occurred';
        return {
          "msg": errorMessage,
          "status": false,
        };
      }

      // 如果状态码是 200，解析验证码
      if (response.statusCode == 200) {
        var res = response.data['verificationCode'];
        VerificationCodeModel code = VerificationCodeModel.fromJson(res);
        return code;
      }

      // 未知状态码处理
      return {
        "msg": "Unexpected response status: ${response.statusCode}",
        "status": false,
      };
    } on DioException catch (e) {
      // 处理 DioException 的错误
      if (e.type == DioExceptionType.badResponse) {
        // 处理 badResponse 错误
        String errorMessage =
            e.response?.data['msg'] ?? 'Failed to send verification code';
        return {
          "msg": errorMessage,
          "status": false,
        };
      }

      // 其他 Dio 异常处理
      print("DioException caught: ${e.message}");
      return {
        "msg": "Network error: ${e.message}",
        "status": false,
      };
    } catch (e) {
      // 捕获其他未预料的异常
      print("Unexpected exception: $e");
      return {
        "msg": "An unexpected error occurred.",
        "status": false,
      };
    }
  }
}
