import 'package:chapar/DTOs/simple_contact.dart';

import 'message.dart';
import 'simple_contact.dart';

class Chat {
  int id;
  List<SimpleContact> contacts;
  List<Message>? messages;
  int allMessagesCount;
  Chat(this.id, this.contacts, this.messages, this.allMessagesCount);
  factory Chat.fromJson(int id, Map<String, dynamic> json) {
    return Chat(
        id,
        json['contacts']
            .map<SimpleContact>(
                (contact) => SimpleContact(contact['id'], contact['username']))
            .toList(),
        json['messages']
            .map<Message>((message) => Message(message['id'], message['chatId'],
                message['text'], message['senderId'], message['sentDate']))
            .toList(),
        json['allMessagesCount']);
  }
}
