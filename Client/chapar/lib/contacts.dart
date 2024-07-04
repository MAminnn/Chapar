import 'dart:convert';
import 'dart:io';
import 'package:chapar/DTOs/message.dart';
import 'package:chapar/main.dart';

import 'protobuf/message_to_send.dart';
import 'package:kind/kind.dart' as kind;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:chapar/DTOs/add_group.dart';
import 'package:chapar/DTOs/contact.dart';
import 'package:chapar/DTOs/simple_friend.dart';
import 'package:chapar/DTOs/received_friend_request.dart';
import 'package:chapar/chatpage.dart';
import 'package:chapar/dynamic_dir_textfield.dart';
import 'package:chapar/loginpage.dart';
import 'package:chapar/responsive_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'FriendSectionLayouts/mobilefriendsec.dart';
import 'FriendSectionLayouts/desktopfriendsec.dart';
import 'package:http/http.dart';
import 'DTOs/chatvm.dart';
import 'DTOs/friend_request_response.dart';
import 'thememanager.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

List<ReceivedFriendRequest> receivedFriendRequests = [];
List<SimpleFriend> friends = [];
var currentContact;

class ContactsPageWidget extends StatefulWidget {
  const ContactsPageWidget({Key? key}) : super(key: key);

  @override
  ContactsPage createState() => ContactsPage();
}

class ContactsPage extends State<ContactsPageWidget> {
  bool isDataCollected = false;
  WebSocket? currentWebSocket;
  List<ChatVM> chatsList = [];
  TextEditingController friendNameTF = TextEditingController();
  TextEditingController frienReqTxtTF = TextEditingController();

  TextEditingController groupNameTF = TextEditingController();
  List<int> groupMembers = [];

  Future<void> openSocket() async {
    try {
      currentWebSocket = await WebSocket.connect(
          'wss://chapar.crusaders.ir/chat/Connect',
          headers: <String, String>{
            'Authorization': 'Bearer $accessToken',
          });
    } on Exception catch (_) {
      final authresponse = await get(Uri.parse("$domain/api/account/checkauth"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken'
          });
      if (authresponse.statusCode == 401) {
        await reauth(context);
        return await openSocket();
      }
      await Future.delayed(const Duration(seconds: 10));
      return await openSocket();
    }
    currentWebSocket?.listen((event) {
      var gotMSG = kind.ProtobufDecodingContext()
          .decodeBytes(event, kind: MessageToSend.kind);
      final chat = chatsList
          .singleWhere((element) => element.id.toString() == gotMSG.chatId);
      setState(() {
        chatsList.remove(chat);
        chat.lastMessage = Message(
            int.parse(gotMSG.id),
            int.parse(gotMSG.chatId),
            gotMSG.text,
            int.parse(gotMSG.senderId),
            gotMSG.sentDate);
        chat.seen = false;
        chatsList.insert(0, chat);
      });
    }, onError: (_) {
      openSocket();
    });
  }

  Future<void> getFriendRequests() async {
    try {
      var response = await get(
          Uri.parse("$domain/api/Contact/GetFriendRequests"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken'
          });
      if (response.statusCode == 401) {
        await reauth(context);
        return await getFriendRequests();
      }
      if (response.statusCode == 200) {
        receivedFriendRequests =
            FriendRequestResponse.fromJson(jsonDecode(response.body))
                    .receivedFriendRequest ??
                [];
      }
    } on Exception catch (_) {
      showAlertDialog("متاسفانه درخواست با خطا روبرو شد", "خطا");
    }
  }

  Future<void> getChatsList() async {
    try {
      var response = await get(Uri.parse("$domain/api/Contact/getchats"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken'
          });
      if (response.statusCode == 401) {
        await reauth(context);
        return await getChatsList();
      }
      if (response.statusCode == 200) {
        chatsList = List<ChatVM>.from(
            jsonDecode(response.body).map((model) => ChatVM.fromJson(model)));
      }
    } on Exception catch (_) {
      showAlertDialog("متاسفانه درخواست با خطا روبرو شد", "خطا");
    }
  }

  Future<void> getFriends() async {
    try {
      var response = await get(Uri.parse("$domain/api/Contact/getfriends"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken'
          });
      if (response.statusCode == 401) {
        await reauth(context);
        return await getFriends();
      }
      if (response.statusCode == 200) {
        var frs = jsonDecode(response.body);
        friends = List<SimpleFriend>.from(
            frs.map((friend) => SimpleFriend.fromJson(friend))).toList();
      }
    } on Exception catch (_) {
      showAlertDialog("متاسفانه درخواست با خطا روبرو شد", "خطا");
    }
  }

  Future<void> getContact() async {
    try {
      var response = await get(
          Uri.parse("$domain/api/Contact/GetContactbyUser"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken'
          });
      if (response.statusCode == 401) {
        await reauth(context);
        return await getContact();
      }
      if (response.statusCode == 200) {
        var res = (jsonDecode(response.body) as Map<dynamic, dynamic>);
        currentContact = Contact(res['id'], res['userId'], res['username'], []);
      }
    } on Exception catch (_) {
      showAlertDialog("متاسفانه درخواست با خطا روبرو شد", "خطا");
    }
  }

  Future<void> sendFriendRequest() async {
    if (friendNameTF.text == currentContact.username) {
      showAlertDialog("شما نمیتوانید به خودتان درخواست دوستی بدهید", "خطا");
      return;
    }
    if (friendNameTF.text == "") {
      return;
    }
    try {
      var response = await post(
          Uri.parse("$domain/api/Contact/SendFriendRequest"),
          body: jsonEncode(<String, String>{
            'RequestMessage': frienReqTxtTF.text,
            'FriendUsername': friendNameTF.text
          }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken'
          });
      if (response.statusCode == 401) {
        await reauth(context);
        return await sendFriendRequest();
      }
      if (response.statusCode == 200) {
        frienReqTxtTF.text = "";
        friendNameTF.text = "";
        showAlertDialog("درخواست دوستی با موفقیت ارسال شد", "موفقیت");
      }
    } on Exception catch (_) {
      showAlertDialog("متاسفانه درخواست با خطا روبرو شد", "خطا");
    }
  }

  Future<void> signOut() async {
    try {
      var response = await get(
          Uri.parse("$domain/api/account/logout/$refreshToken"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken'
          });
      if (response.statusCode == 401) {
        await reauth(context);
        return await signOut();
      }
      if (response.statusCode == 200) {
        if (jsonDecode(response.body) == true) {
          (cacheManager as SharedPreferences).remove("refreshToken");
          (cacheManager as SharedPreferences).remove("accessToken");
        }
        currentWebSocket?.close();
        navigate(ThemeLayout(body: const LoginPageWidget()));
      }
    } on Exception catch (_) {
      showAlertDialog("متاسفانه درخواست با خطا روبرو شد", "خطا");
    }
  }

  Future<void> addGroup() async {
    if (!groupNameTF.text.replaceAll(' ', '').isNotEmpty ||
        !groupNameTF.text.replaceAll('\n', '').isNotEmpty ||
        !groupNameTF.text.isNotEmpty) {
      return;
    }
    try {
      var response = await post(Uri.parse("$domain/api/Contact/creategroup"),
          body: jsonEncode(AddGroup(
              groupMembers + [currentContact.id], groupNameTF.text.trim())),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken'
          });
      if (response.statusCode == 401) {
        await reauth(context);
        return await addGroup();
      }
      if (response.statusCode == 200) {
        if (response.body != "") {
          showAlertDialog("گروه با موفقیت ایجاد شد ", "موفقیت");
          setState(() {
            chatsList.add(ChatVM.fromJson(jsonDecode(response.body)));
          });
          setState(() {});
        }
      }
    } on Exception catch (_) {
      showAlertDialog("متاسفانه درخواست با خطا روبرو شد", "خطا");
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: applicationTheme,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: applicationTheme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              "چاپار",
              style: TextStyle(
                  color: applicationTheme.highlightColor, fontFamily: "Vazir"),
            ),
            actions: appThemes.map((theme) {
              return TextButton(
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all(const Size(45, 45)),
                    maximumSize: WidgetStateProperty.all(const Size(45, 45)),
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
            bottom: TabBar(
              indicatorColor: applicationTheme.primaryColor,
              tabs: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(
                    Icons.chat,
                    color: applicationTheme.highlightColor,
                  ),
                  Text(
                    "لیست چت ها",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: applicationTheme.highlightColor),
                  )
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(
                    Icons.people,
                    color: applicationTheme.highlightColor,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "دوستان",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: applicationTheme.highlightColor),
                  )
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(
                    Icons.accessibility_new,
                    color: applicationTheme.highlightColor,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "سایر امکانات",
                    style: TextStyle(
                        color: applicationTheme.highlightColor,
                        fontWeight: FontWeight.bold),
                  )
                ]),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemCount: chatsList.length,
                  padding: const EdgeInsets.all(20),
                  itemBuilder: (context, index) => Container(
                        color: applicationTheme.primaryColor,
                        child: Center(
                            child: TextButton(
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(3, 10, 3, 5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(chatsList[index].title.toString(),
                                      style: TextStyle(
                                          color: applicationTheme
                                              .scaffoldBackgroundColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                      maxLines: 1,
                                      chatsList[index]
                                              .lastMessage
                                              ?.text
                                              .toString() ??
                                          "",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: applicationTheme
                                              .scaffoldBackgroundColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                          onPressed: () => showChatMembers(
                                              chatsList[index].id),
                                          icon: Icon(
                                              Icons
                                                  .perm_contact_calendar_rounded,
                                              size: 23,
                                              color: applicationTheme
                                                  .scaffoldBackgroundColor)),
                                      Icon(
                                          chatsList[index].seen
                                              ? Icons.done_all_sharp
                                              : Icons.drafts_rounded,
                                          color: applicationTheme
                                              .scaffoldBackgroundColor,
                                          size: 18),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 0, 5, 0),
                                        child: chatsList[index].lastMessage ==
                                                null
                                            ? null
                                            : Text(
                                                intl.DateFormat.Hm()
                                                    .format(DateTime.parse(
                                                        chatsList[index]
                                                                .lastMessage
                                                                ?.sentDate
                                                                .toString() ??
                                                            ""))
                                                    .toString(),
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    color: applicationTheme
                                                        .scaffoldBackgroundColor,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          onPressed: () {
                            currentWebSocket?.close();
                            navigate(ChatPage(
                              chatId: chatsList[index].id,
                              title: chatsList[index].title,
                            ));
                          },
                        )),
                      )),
              Container(
                  padding: EdgeInsets.fromLTRB(((screenWidth / 9) - 30), 25,
                      ((screenWidth / 9) - 30), 25),
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: TextField(
                                maxLength: 30,
                                maxLines: 1,
                                cursorColor: applicationTheme.primaryColor,
                                style: TextStyle(
                                    color: applicationTheme.primaryColor,
                                    fontFamily: "Chubbo Light"),
                                controller: friendNameTF,
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                        borderSide: BorderSide(
                                            color:
                                                applicationTheme.primaryColor)),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                        borderSide: BorderSide(
                                            color:
                                                applicationTheme.primaryColor)),
                                    filled: true,
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(30, 5, 30, 5),
                                    hintStyle: TextStyle(
                                        color: applicationTheme.hintColor,
                                        fontFamily: "Vazir"),
                                    hintTextDirection: TextDirection.rtl,
                                    hintText: "نام دوست خود را وارد نمایید",
                                    fillColor: applicationTheme
                                        .scaffoldBackgroundColor),
                              ),
                            ),
                            IconButton(
                              onPressed: () => sendFriendRequest(),
                              icon: Icon(Icons.person_add,
                                  color: applicationTheme.primaryColor),
                            )
                          ],
                        ),
                        TextField(
                          maxLines: 1,
                          maxLength: 100,
                          cursorColor: applicationTheme.primaryColor,
                          style: TextStyle(
                              fontFamily: "Vazir",
                              color: applicationTheme.primaryColor),
                          controller: frienReqTxtTF,
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: applicationTheme.primaryColor)),
                              filled: true,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(30, 5, 30, 5),
                              hintStyle:
                                  TextStyle(color: applicationTheme.hintColor),
                              hintTextDirection: TextDirection.rtl,
                              hintText: "متن درخواست",
                              fillColor:
                                  applicationTheme.scaffoldBackgroundColor),
                        ),
                        Expanded(
                          child: ResponsiveLayout(
                            desktopScreenWidget: DesktopScreenFriendSection(
                              getContactData: getContactData,
                            ),
                            mobileScreenWidget: MobileScreenFriendSection(
                                getContactData: getContactData),
                            applicationTheme: applicationTheme,
                          ),
                        )
                      ],
                    ),
                  )),
              Column(
                children: [
                  TextButton(
                      style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                              const EdgeInsets.all(20))),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (c) => AlertDialog(
                                  backgroundColor:
                                      applicationTheme.primaryColor,
                                  title: Text(
                                    'تشکیل گروه',
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                        color: applicationTheme
                                            .scaffoldBackgroundColor,
                                        fontFamily: "Vazir"),
                                  ),
                                  content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        DynamicTextField(
                                          maxLength: 30,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: applicationTheme
                                                .scaffoldBackgroundColor,
                                          ),
                                          controller: groupNameTF,
                                          cursorColor: applicationTheme
                                              .scaffoldBackgroundColor,
                                          decoration: InputDecoration(
                                              counterStyle: TextStyle(
                                                  color: applicationTheme
                                                      .scaffoldBackgroundColor),
                                              focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: applicationTheme
                                                          .scaffoldBackgroundColor)),
                                              enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: applicationTheme
                                                          .scaffoldBackgroundColor)),
                                              hintText: "نام گروه",
                                              hintTextDirection:
                                                  TextDirection.rtl,
                                              hintStyle: TextStyle(
                                                  fontFamily: "Vazir",
                                                  color: applicationTheme
                                                      .scaffoldBackgroundColor)),
                                        ),
                                        MultiSelectDialogField(
                                          buttonIcon: Icon(
                                            Icons.arrow_drop_down_outlined,
                                            color: applicationTheme
                                                .scaffoldBackgroundColor,
                                          ),
                                          buttonText: Text(
                                            "انتخاب اعضا",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: applicationTheme
                                                    .scaffoldBackgroundColor,
                                                fontFamily: "Vazir"),
                                          ),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: applicationTheme
                                                          .scaffoldBackgroundColor))),
                                          confirmText: Text(
                                            "تایید",
                                            style: TextStyle(
                                                color: applicationTheme
                                                    .scaffoldBackgroundColor,
                                                fontSize: 22),
                                          ),
                                          chipDisplay:
                                              MultiSelectChipDisplay.none(),
                                          title: Text(
                                            "انتخاب اعضا",
                                            textDirection: TextDirection.rtl,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: applicationTheme
                                                    .scaffoldBackgroundColor),
                                          ),
                                          backgroundColor:
                                              applicationTheme.primaryColor,
                                          unselectedColor: applicationTheme
                                              .scaffoldBackgroundColor,
                                          dialogHeight: 100,
                                          itemsTextStyle: TextStyle(
                                              color: applicationTheme
                                                  .primaryColor),
                                          checkColor:
                                              applicationTheme.primaryColor,
                                          selectedColor:
                                              applicationTheme.primaryColor,
                                          selectedItemsTextStyle: TextStyle(
                                              color: applicationTheme
                                                  .scaffoldBackgroundColor),
                                          items: friends
                                              .map((e) => MultiSelectItem(
                                                  e.id, e.username))
                                              .toList(),
                                          listType: MultiSelectListType.CHIP,
                                          onConfirm: (values) {
                                            groupMembers = values
                                                .map((e) =>
                                                    int.parse(e.toString()))
                                                .toList();
                                          },
                                        ),
                                      ]),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          addGroup();
                                        },
                                        child: Text(
                                          "ایجاد",
                                          style: TextStyle(
                                              color: applicationTheme
                                                  .scaffoldBackgroundColor,
                                              fontFamily: "Vazir"),
                                        ))
                                  ],
                                ));
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "تشکیل گروه",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      )),
                  TextButton(
                      style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                              const EdgeInsets.all(20))),
                      onPressed: () {
                        signOut();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "خروج از حساب کاربری",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      )),
                  TextButton(
                      style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                              const EdgeInsets.all(20))),
                      onPressed: () {
                        showAboutDialog();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "درباره ی ما",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getContactData();
    });
  }

  void navigate(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  getContactData() async {
    await openSocket();
    await getContact();
    await getChatsList();
    await getFriendRequests();
    await getFriends();
    setState(() {});
  }

  showAlertDialog(String text, String title) {
    // set up the button
    Widget okButton = TextButton(
      child: Text(
        "اوکی",
        style: TextStyle(
            fontFamily: "Vazir", color: applicationTheme.primaryColor),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: applicationTheme.scaffoldBackgroundColor,
      title: Text(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        title,
        style: TextStyle(
            fontFamily: "Vazir", color: applicationTheme.primaryColor),
      ),
      content: Text(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        text,
        style: TextStyle(
            fontFamily: "Vazir", color: applicationTheme.primaryColor),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAboutDialog() {
    // set up the button
    Widget okButton = TextButton(
      child: Text(
        "اوکی",
        style: TextStyle(
            fontFamily: "Vazir", color: applicationTheme.primaryColor),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: applicationTheme.scaffoldBackgroundColor,
      title: Text(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        "درباره ی ما",
        style: TextStyle(
            fontFamily: "Vazir", color: applicationTheme.primaryColor),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                    color: applicationTheme.primaryColor,
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text(
                      "ارتباط با برنامه نویس",
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Vazir",
                          color: applicationTheme.scaffoldBackgroundColor),
                    )),
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: RichText(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: 'اینستاگرام',
                  style: TextStyle(
                      fontFamily: "Vazir",
                      color: applicationTheme.primaryColor),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      await launchUrlString(
                        "https://www.instagram.com/moamin___/",
                      );
                    }),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: RichText(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: 'تلگرام',
                  style: TextStyle(
                      fontFamily: "Vazir",
                      color: applicationTheme.primaryColor),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      await launchUrlString(
                        "https://t.me/M_AminK",
                      );
                    }),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: RichText(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: 'وبسایت شخصی',
                  style: TextStyle(
                      fontFamily: "Vazir",
                      color: applicationTheme.primaryColor),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      await launchUrlString(
                        "https://aminkarvizi.ir",
                      );
                    }),
            ),
          ),
          Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text(
                "چاپار : mamin",
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "Vazir", color: applicationTheme.primaryColor),
              )),
        ],
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showChatMembers(int chatId) {
    var chat = chatsList.singleWhere((element) => element.id == chatId);
    // set up the button
    Widget okButton = TextButton(
      child: Text(
        "اوکی",
        style: TextStyle(
            fontFamily: "Vazir", color: applicationTheme.primaryColor),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: applicationTheme.scaffoldBackgroundColor,
      title: Text(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        "اعضای گپ",
        style: TextStyle(
            fontFamily: "Vazir", color: applicationTheme.primaryColor),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: chat.chatMembers
            .map((member) => Container(
                  margin: const EdgeInsets.fromLTRB(5, 8, 5, 8),
                  child: Text(member,
                      style: TextStyle(
                          color: applicationTheme.primaryColor,
                          fontFamily: "Chubbo Light",
                          fontSize: 23)),
                ))
            .toList(),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
