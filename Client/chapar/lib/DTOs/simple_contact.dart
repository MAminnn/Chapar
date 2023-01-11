class SimpleContact {
  int id;
  String username;

  SimpleContact(this.id, this.username);

  factory SimpleContact.fromJson(Map<dynamic, dynamic> json) {

    return SimpleContact(json['id'], json['username']);
  }
}
