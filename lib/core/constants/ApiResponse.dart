class ApiResponse<T> {
  final String mensaje;
  final T object;

  ApiResponse({
    required this.mensaje,
    required this.object,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse(
      mensaje: json['mensaje'] ?? '',
      object: fromJsonT(json['object']),
    );
  }
}