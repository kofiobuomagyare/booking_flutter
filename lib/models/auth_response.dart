class AuthResponse {
  final String message;
  final String? token;
  final String? role;
  final Map<String, dynamic>? userData;

  AuthResponse({
    required this.message,
    this.token,
    this.role,
    this.userData,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] ?? '',
      token: json['token'],
      role: json['role'],
      userData: json['userData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token,
      'role': role,
      'userData': userData,
    };
  }
} 