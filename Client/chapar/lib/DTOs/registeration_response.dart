class RegisterationResponse {
  bool success;
  List<String>? errors;
  RegisterationResponse(this.success, this.errors);
  factory RegisterationResponse.fromJson(Map<String, dynamic> json) {
    return RegisterationResponse(json['success'], json['errors']?.map<String>((error) => error.toString()).toList());
  }
}