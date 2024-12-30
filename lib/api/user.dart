import 'package:test/api/api.dart';
import 'package:test/models/user.dart';

class UserApi {
  static Future<UserModel> login(
      {required String email, required String password}) async {
    try {
      final response = await Api().post('/login', data: {
        "email": email,
        "password": password,
      });
      var data = response.data['data'];

      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception("Error login: $e");
    }
  }

  static Future<bool> register(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final response = await Api().post('/register', data: {
        "name": name,
        "email": email,
        "password": password,
      });
      var status = response.data['status'];

      return status;
    } catch (e) {
      throw Exception("Error login: $e");
    }
  }
}
