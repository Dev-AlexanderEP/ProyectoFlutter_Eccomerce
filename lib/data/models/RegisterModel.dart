import '../../core/constants/ApiResponse.dart';

class RegisterRequestModel {
  final String nombreUsuario;
  final String email;
  final String contrasenia;

  RegisterRequestModel({
    required this.nombreUsuario,
    required this.email,
    required this.contrasenia,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombreUsuario': nombreUsuario,
      'email': email,
      'contrasenia': contrasenia,
    };
  }
}

class RegisterResponseModel {
  final String id;
  final String nombreUsuario;
  final String email;
  final String rol;
  final bool activo;
  final String createdAt;
  final String updatedAt;

  RegisterResponseModel({
    required this.id,
    required this.nombreUsuario,
    required this.email,
    required this.rol,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      id: json['id']?.toString() ?? '',                     // <- convierte int->String
      nombreUsuario: json['nombre'],
      email: json['email'],
      rol: json['rol'],
      activo: json['activo'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
  static ApiResponse<RegisterResponseModel> fromApiResponseJson(Map<String, dynamic> json) {
    return ApiResponse<RegisterResponseModel>.fromJson(
      json,
          (obj) => RegisterResponseModel.fromJson(obj),
    );
  }

}