class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String background;

  UserModel({
    this.id = '',
    required this.name,
    required this.email,
    this.avatar = '',
    this.background = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'] ?? '',
      background: json['background'] ?? '',
    );
  }
}
