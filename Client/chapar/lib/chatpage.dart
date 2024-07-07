import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:chapar/DTOs/chat.dart';
import 'package:http/http.dart';
import 'package:chapar/DTOs/chat_request.dart';
import 'package:kind/kind.dart' as kind;
import 'package:chapar/DTOs/message.dart';
import 'package:chapar/contacts.dart';
import 'package:chapar/thememanager.dart';
import 'protobuf/message_to_send.dart';
import 'main.dart';
import 'dynamic_dir_textfield.dart';

class ChatPage extends StatefulWidget {
  final int chatId;
  final String title;

  const ChatPage({Key? key, required this.chatId, required this.title})
      : super(
          key: key,
        );

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final messageTextFieldFocus = FocusNode();
  bool isInputFocused = false;
  int skipCount = 0;
  var currentChat;
  WebSocket? currentWebSocket;
  double maxScrollBefore = 0;
  List<Message> messages = [];
  var messasgeTF = TextEditingController();
  List<MessageToSend> pendingMessages = [];
  final ScrollController messageListController = ScrollController();
  Widget? scrollToDownButton;
  int unreadMessagesCount = 0;
  int contactChatId = 0;

  Future<void> getChatInfo() async {
    try {
      var response = await post(Uri.parse("$domain/api/Contact/getchat"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken'
          },
          body: jsonEncode(ChatRequest(widget.chatId, skipCount)));
      if (response.statusCode == 401) {
        await reauth(context);
        return await getChatInfo();
      }
      if (response.statusCode == 200) {
        messages = Chat.fromJson(widget.chatId, (jsonDecode(response.body)))
                .messages ??
            [];
        currentChat = Chat.fromJson(widget.chatId, (jsonDecode(response.body)));
      }
    } on Exception catch (_) {}
  }

  Future<void> getMoreMessages() async {
    maxScrollBefore = messageListController.position.maxScrollExtent;
    if (skipCount >= currentChat.allMessagesCount) {
      return;
    }
    var response = await post(Uri.parse("$domain/api/Contact/getchat"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode(ChatRequest(widget.chatId, skipCount)));
    if (response.statusCode == 401) {
      await reauth(context);
      return await getMoreMessages();
    }
    if (response.statusCode == 200) {
      messages.insertAll(
          0,
          Chat.fromJson(widget.chatId, (jsonDecode(response.body)))
                  .messages
                  ?.map((m) => Message(
                        m.id,
                        m.chatId,
                        m.text,
                        m.senderId,
                        m.sentDate,
                      )) ??
              []);
      [];
      setState(() {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          messageListController.jumpTo(
              messageListController.position.maxScrollExtent - maxScrollBefore);
        });
      });
    }
  }

  Future<void> openSocket() async {
    try {
      currentWebSocket = await WebSocket.connect(
          '$webSocketDomain/chat/EnterRoom',
          headers: <String, String>{
            'Authorization': 'Bearer $accessToken',
            'ChatId': widget.chatId.toString()
          });
      await getChatInfo();
      setState(() {});
      if (pendingMessages != []) {
        for (var i = 0; i < pendingMessages.length;) {
          currentWebSocket?.add(kind.ProtobufEncodingContext()
              .encodeBytes(pendingMessages[i], kind: MessageToSend.kind));
          pendingMessages.removeAt(i);
        }
      }
      currentWebSocket?.listen((event) {
        var isScrollMax = (messageListController.offset ==
            messageListController.position.maxScrollExtent);
        var gotMSG = kind.ProtobufDecodingContext()
            .decodeBytes(event, kind: MessageToSend.kind);
        setState(() {
          messages.add(Message(
            int.parse(gotMSG.id),
            widget.chatId,
            gotMSG.text,
            int.parse(gotMSG.senderId),
            gotMSG.sentDate.toString(),
          ));
        });
        if (gotMSG.senderId != currentContact.id) {
          if (isScrollMax == true) {
            setState(() {
              unreadMessagesCount = 0;
              scrollToDownButton = null;
            });
            SchedulerBinding.instance.addPostFrameCallback((_) {
              messageListController
                  .jumpTo(messageListController.position.maxScrollExtent);
            });
          } else {
            seen(false);
            unreadMessagesCount++;
            scrollToDownButton = Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 70),
              child: FloatingActionButton(
                backgroundColor: applicationTheme.primaryColor,
                onPressed: () {
                  setState(() {
                    seen(true);
                    unreadMessagesCount = 0;
                    scrollToDownButton = null;
                  });
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    messageListController
                        .jumpTo(messageListController.position.maxScrollExtent);
                  });
                },
                child: Column(children: [
                  DecoratedBox(
                    decoration: const ShapeDecoration(shape: CircleBorder()),
                    child: Text(unreadMessagesCount.toString(),
                        style: TextStyle(
                            color: applicationTheme.scaffoldBackgroundColor)),
                  ),
                  Icon(
                    Icons.arrow_downward,
                    color: applicationTheme.scaffoldBackgroundColor,
                  ),
                ]),
              ),
            );
          }
        }
      }, onError: (e) {
        openSocket();
      });
    } on Exception catch (e) {
      try {
        final authresponse = await get(
            Uri.parse("$domain/api/account/checkauth"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $accessToken'
            });
        if (authresponse.statusCode == 401) {
          await reauth(context);
          return await openSocket();
        }
      } catch (_) {
        await Future.delayed(const Duration(seconds: 2));
        openSocket();
      }
    }
  }

  Future<void> sendMessage() async {
    try {
      if (messasgeTF.text.replaceAll(' ', '').isNotEmpty &&
          messasgeTF.text.replaceAll('\n', '').isNotEmpty &&
          messasgeTF.text.isNotEmpty) {
        MessageToSend msg = MessageToSend(
            id: "0",
            text: messasgeTF.text.trim(),
            chatId: currentChat.id.toString(),
            senderId: currentContact?.id.toString() ?? "",
            sentDate: "");
        if (!await isWebSocketConnected()) {
          messages.add(Message(0, int.parse(msg.chatId), msg.text,
              int.parse(msg.senderId), DateTime.now().toString(),
              isDeliverd: false));
          pendingMessages.add(MessageToSend(
              id: "0",
              chatId: msg.chatId,
              sentDate: msg.sentDate,
              senderId: msg.senderId,
              text: msg.text));
          setState(() {
            messasgeTF.text = "";
            messasgeTF = TextEditingController();
            FocusScope.of(context).requestFocus(messageTextFieldFocus);
            SchedulerBinding.instance.addPostFrameCallback((_) {
              messageListController
                  .jumpTo(messageListController.position.maxScrollExtent);
            });
          });
        } else {
          messasgeTF.text = "";
          messasgeTF = TextEditingController();
          FocusScope.of(context).requestFocus(messageTextFieldFocus);
          currentWebSocket?.add(kind.ProtobufEncodingContext()
              .encodeBytes(msg, kind: MessageToSend.kind));
          setState(() {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              messageListController
                  .jumpTo(messageListController.position.maxScrollExtent);
            });
          });
        }
      }
      FocusScope.of(context).requestFocus(messageTextFieldFocus);
    } on Exception catch (_) {
      final authresponse = await get(Uri.parse("$domain/api/account/checkauth"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken'
          });
      if (authresponse.statusCode == 401) {
        await reauth(context);
        return await sendMessage();
      }
    }
  }

  Future<void> seen(bool seen) async {
    try {
      await get(
          Uri.parse(
              "$domain/api/chat/seen/${widget.chatId}/${currentContact.id}/$seen"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken'
          });
    } on Exception catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: applicationTheme,
        home: KeyboardListener(
            autofocus: true,
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event.logicalKey.keyId == 0x10000000d &&
                  event.physicalKey == PhysicalKeyboardKey.enter &&
                  !HardwareKeyboard.instance.isShiftPressed &&
                  !HardwareKeyboard.instance.isControlPressed &&
                  !HardwareKeyboard.instance.isAltPressed &&
                  event.runtimeType.toString() == 'RawKeyDownEvent') {
                if (isInputFocused == true) {
                  sendMessage();
                }
              }
            },
            child: Scaffold(
                floatingActionButton: scrollToDownButton,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
                backgroundColor: applicationTheme.scaffoldBackgroundColor,
                appBar: AppBar(
                  title: Text(
                    widget.title,
                    style: TextStyle(
                        color: applicationTheme.highlightColor,
                        fontFamily: "Vazir"),
                  ),
                  actions: appThemes.map((theme) {
                    return TextButton(
                        style: ButtonStyle(
                          minimumSize:
                              WidgetStateProperty.all(const Size(45, 45)),
                          maximumSize:
                              WidgetStateProperty.all(const Size(45, 45)),
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () {
                          setState(() {
                            applicationTheme = theme;
                          });
                        },
                        child: Icon(
                          Icons.circle,
                          color: theme.indicatorColor,
                          size: 22,
                        ));
                  }).toList(),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: applicationTheme.highlightColor),
                    onPressed: () {
                      currentWebSocket?.close();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ContactsPageWidget(),
                      ));
                    },
                  ),
                ),
                body: Column(
                  children: [
                    Expanded(
                        child: Container(
                      color: applicationTheme.scaffoldBackgroundColor,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                      child: Column(
                        children: [
                          Expanded(
                              child: Row(
                            children: [
                              Expanded(
                                  child: Material(
                                      color: applicationTheme
                                          .scaffoldBackgroundColor,
                                      child: ListView.builder(
                                          padding: const EdgeInsets.fromLTRB(
                                              30, 10, 30, 10),
                                          itemBuilder: (context, index) {
                                            if (messages[index].senderId ==
                                                currentContact?.id) {
                                              return ListTile(
                                                title: Row(
                                                  children: [
                                                    Flexible(
                                                        child: Stack(
                                                      children: [
                                                        PhysicalShape(
                                                          clipper: const ShapeBorderClipper(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.only(
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              17),
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              17),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              17)))),
                                                          color:
                                                              applicationTheme
                                                                  .primaryColor,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    15,
                                                                    7,
                                                                    15,
                                                                    7),
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  messages[
                                                                          index]
                                                                      .text
                                                                      .toString(),
                                                                  maxLines: 20,
                                                                  softWrap:
                                                                      true,
                                                                  style: TextStyle(
                                                                      color: applicationTheme
                                                                          .scaffoldBackgroundColor),
                                                                ),
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Text(
                                                                      intl.DateFormat(
                                                                              'kk:mm')
                                                                          .format(
                                                                              DateTime.parse(messages[index].sentDate))
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              11,
                                                                          color:
                                                                              applicationTheme.scaffoldBackgroundColor),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 3,
                                                                    ),
                                                                    messages[index].isDeliverd ??
                                                                            true
                                                                        ? Icon(
                                                                            Icons.done,
                                                                            size:
                                                                                13,
                                                                            color:
                                                                                applicationTheme.scaffoldBackgroundColor,
                                                                          )
                                                                        : Icon(
                                                                            Icons.access_time_outlined,
                                                                            size:
                                                                                13,
                                                                            color:
                                                                                applicationTheme.scaffoldBackgroundColor,
                                                                          )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ))
                                                  ],
                                                ),
                                                tileColor: Colors.transparent,
                                              );
                                            } else {
                                              return ListTile(
                                                title: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Flexible(
                                                          child: Stack(
                                                        children: [
                                                          PhysicalShape(
                                                              elevation: 5.0,
                                                              clipper: const ShapeBorderClipper(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.only(
                                                                          bottomLeft: Radius.circular(
                                                                              17),
                                                                          topLeft: Radius.circular(
                                                                              17),
                                                                          topRight: Radius.circular(
                                                                              17)))),
                                                              color: applicationTheme
                                                                  .secondaryHeaderColor,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        15,
                                                                        7,
                                                                        15,
                                                                        7),
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                          currentChat
                                                                              .contacts
                                                                              .firstWhere((element) => element.id == messages[index].senderId)
                                                                              .username,
                                                                          style: TextStyle(fontSize: 10, color: applicationTheme.scaffoldBackgroundColor)),
                                                                      Text(
                                                                        messages[index]
                                                                            .text,
                                                                        maxLines:
                                                                            20,
                                                                        softWrap:
                                                                            true,
                                                                        style: TextStyle(
                                                                            color:
                                                                                applicationTheme.scaffoldBackgroundColor),
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Text(
                                                                            intl.DateFormat('kk:mm').format(DateTime.parse(messages[index].sentDate)).toString(),
                                                                            style:
                                                                                TextStyle(fontSize: 11, color: applicationTheme.scaffoldBackgroundColor),
                                                                          )
                                                                        ],
                                                                      )
                                                                    ]),
                                                              ))
                                                        ],
                                                      ))
                                                    ]),
                                                tileColor: Colors.transparent,
                                              );
                                            }
                                          },
                                          controller: messageListController,
                                          itemCount: messages.length))),
                            ],
                          )),
                        ],
                      ),
                    )),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      maxHeight: 80, minHeight: 40),
                                  child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          11, 8, 11, 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(100)),
                                          border: Border.fromBorderSide(
                                              BorderSide(
                                                  color: applicationTheme
                                                      .primaryColor))),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: DynamicTextField(
                                          maxLength: 750,
                                          maxLines: null,
                                          focusNode: messageTextFieldFocus,
                                          cursorColor:
                                              applicationTheme.primaryColor,
                                          style: TextStyle(
                                              color: applicationTheme
                                                  .primaryColor),
                                          controller: messasgeTF,
                                          decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                              counterText: "",
                                              enabledBorder: InputBorder.none,
                                              hintTextDirection:
                                                  TextDirection.rtl,
                                              focusedBorder: InputBorder.none,
                                              filled: true,
                                              hintStyle: TextStyle(
                                                color: Colors.grey[500],
                                                fontFamily: "Vazir",
                                              ),
                                              hintText: "پیامی بنویسید",
                                              fillColor: applicationTheme
                                                  .scaffoldBackgroundColor),
                                        ),
                                      ))),
                            ),
                            TextButton(
                                style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                        EdgeInsets.zero)),
                                onPressed: (() => {sendMessage()}),
                                child: Icon(
                                  Icons.send_rounded,
                                  color: applicationTheme.primaryColor,
                                  size: 36,
                                ))
                          ],
                        )),
                  ],
                ))));
  }

  @override
  void initState() {
    super.initState();
    contactChatId = widget.chatId;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(messageTextFieldFocus);
      messageTextFieldFocus.addListener(() {
        isInputFocused = messageTextFieldFocus.hasFocus;
      });
      getData().then((value) {
        setState(() {});
        SchedulerBinding.instance.addPostFrameCallback((_) {
          messageListController
              .jumpTo(messageListController.position.maxScrollExtent);
        });
        seen(true);
      });
      messageListController.addListener(() {
        if (messageListController.position.pixels ==
            messageListController.position.minScrollExtent) {
          setState(() {
            skipCount = messages.length;
            getMoreMessages();
          });
        }
        if (messageListController.position.pixels ==
            messageListController.position.maxScrollExtent) {
          if (unreadMessagesCount != 0) {
            seen(true);
          }
          if (scrollToDownButton != null) {
            scrollToDownButton = null;
          }
        }
      });
    });
  }

  Future<void> getData() async {
    await openSocket();
  }

  Future<bool> isWebSocketConnected() async {
    try {
      final socket = await WebSocket.connect('$webSocketDomain/chat/EnterRoom',
          headers: <String, String>{
            'Authorization': 'Bearer $accessToken',
            'ChatId': widget.chatId.toString()
          });
      socket.close(); // Close the test connection
      return true;
    } catch (e) {
      openSocket();
      return false;
    }
  }
}
