class Message {
  int id;
  String text;
  String sentDate;
  int senderId;
  int chatId;
  bool? isDeliverd = true;
  Message(this.id, this.chatId, this.text, this.senderId, this.sentDate,
      {this.isDeliverd});
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      json['id'],
      json['chatId'],
      json['text'],
      json['senderId'],
      json['sentDate'],
    );
  }
}
