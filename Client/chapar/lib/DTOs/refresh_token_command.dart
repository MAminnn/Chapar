class RefreshTokenCommand{
  String token;
  RefreshTokenCommand(this.token);

   Map<String, dynamic> toJson() {
    return {'Token': token};
  }
}