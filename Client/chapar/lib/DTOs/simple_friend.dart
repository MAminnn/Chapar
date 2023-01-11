class SimpleFriend {
  int id;
  String username;

  SimpleFriend(this.id, this.username);

  factory SimpleFriend.fromJson(Map<String, dynamic> json) {
    return SimpleFriend(json['id'], json['username']);
  }
}
