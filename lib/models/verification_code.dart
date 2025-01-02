class VerificationCodeModel {
  final String email;
  final String code;
  final String createdAt;
  final String expiresAt;

  VerificationCodeModel({
    required this.email,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
  });

  factory VerificationCodeModel.fromJson(Map<String, dynamic> json) {
    return VerificationCodeModel(
      email: json['email'],
      code: json['code'],
      createdAt: json['createdAt'],
      expiresAt: json['expiresAt'],
    );
  }
}
