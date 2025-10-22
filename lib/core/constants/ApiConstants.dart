class ApiConstants {
  static const String baseUrl = "http://192.168.87.135:8080/api/v1";
  static const String baseUrlL = "http://192.168.87.135:8080";

  // Login
  static const String loginEndpoint = "$baseUrlL/token";
  // Login Google
  static const String googleLoginEndpoint = "$baseUrlL/google-login";
  
  // Register
  static const String registerEndpoint = "$baseUrl/usuarios";
  static const String registerVerifyCodeEndpoint = "$baseUrlL/verificar-codigo-registro";

  // Olvido de contraseña
  static const String forgotPasswordEndpoint = "$baseUrl/enviar-codigo-verificacion";
  static const String verifyCodeEndpoint = "$baseUrl/verificar-codigo";
  // Resetear contraseña sin login
  static const String resetPasswordEndpoint = "$baseUrl/resetar-contrasenia";

}
