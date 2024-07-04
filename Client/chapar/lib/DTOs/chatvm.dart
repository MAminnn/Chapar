import 'package:chapar/DTOs/message.dart';

class ChatVM {
  int id;
  String title;
  Message? lastMessage;
  bool seen;
  List<String> chatMembers;
  ChatVM(this.id, this.title, this.lastMessage, this.seen, this.chatMembers);

  factory ChatVM.fromJson(Map<String, dynamic> json) {
    if (json['lastMessage'] == null) {
      return ChatVM(json['chatId'], json['title'], null, json['seen'],
          json['chatMembers'].map<String>((element) => element.toString()).toList());
    }
    return ChatVM(
        json['chatId'],
        json['title'],
        Message.fromJson(json['lastMessage']),
        json['seen'],
        json['chatMembers'].map<String>((element) => element.toString()).toList());
  }
}
