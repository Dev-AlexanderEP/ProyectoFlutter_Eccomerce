class RegisterRequestModel {
  final String username;
  final String email;
  final String password;

  RegisterRequestModel({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }
}

class RegisterResponseModel {
  final bool success;
  final String message;
  final String? userId;

  RegisterResponseModel({
    required this.success,
    required this.message,
    this.userId,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      userId: json['userId'],
    );
  }
}
