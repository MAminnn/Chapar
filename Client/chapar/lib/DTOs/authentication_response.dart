class AuthenticationResponse {
  String? accessToken;
  String? refreshToken;
  String? error;
  AuthenticationResponse(this.accessToken, this.refreshToken, this.error);
  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    return AuthenticationResponse(
        json['accessToken'], json['refreshToken'], json['error']);
  }
}