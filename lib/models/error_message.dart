/// 错误体信息
class ErrorMessageModel {
  bool? status;
  String? code;
  String? message;

  ErrorMessageModel({this.status, this.code, this.message});

  factory ErrorMessageModel.fromJson(Map<String, dynamic> json) {
    return ErrorMessageModel(
      status: json['status'] as bool?,
      code: json['code'] as String?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'code': code,
        'message': message,
      };
}
