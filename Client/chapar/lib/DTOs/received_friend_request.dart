class ReceivedFriendRequest {
  int id;
  String fromContactUsername;
  String text;
  int fromContactId;

  ReceivedFriendRequest(
      this.id, this.fromContactUsername, this.fromContactId, this.text);
  factory ReceivedFriendRequest.fromJson(Map<String, dynamic> json) {
    return ReceivedFriendRequest(
      json['id'],
      json['fromContactUsername'],
      json['fromContactId'],
      json['text'],
    );
  }
}
