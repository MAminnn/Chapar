import 'package:kind/kind.dart';

class MessageToSend extends Object with EntityMixin {
  static final EntityKind<MessageToSend> kind = EntityKind<MessageToSend>(
      name: 'test',
      define: (msg) {
        final idProp =
            msg.requiredString(id: 1, name: 'Id', getter: (t) => t.id);
        final textProp =
            msg.requiredString(id: 2, name: 'Text', getter: (m) => m.text);
        final sentdateProp = msg.requiredString(
            id: 3, name: 'SentDate', getter: (m) => m.sentDate);
        final chatidProp =
            msg.requiredString(id: 4, name: 'ChatId', getter: (m) => m.chatId);
        final senderidProp = msg.requiredString(
            id: 5, name: 'SenderId', getter: (m) => m.senderId);
        msg.constructorFromData = (data) {
          return MessageToSend(
              id: data.get(idProp),
              text: data.get(textProp),
              sentDate: data.get(sentdateProp),
              chatId: data.get(chatidProp),
              senderId: data.get(senderidProp));
        };
      });

  String id;
  String text;
  String sentDate;
  String chatId;
  String senderId;

  MessageToSend(
      {required this.id,
      required this.text,
      required this.sentDate,
      required this.chatId,
      required this.senderId});
  @override
  EntityKind getKind() => kind;
}
