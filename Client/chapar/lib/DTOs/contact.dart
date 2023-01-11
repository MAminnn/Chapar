import 'received_friend_request.dart';

class Contact {
  int id;
  int userId;
  String username;
  List<Contact>? friends;

  Contact(this.id, this.userId, this.username, this.friends);
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
        json['id'], json['userid'], json['username'], json['friends']);
  }
}
