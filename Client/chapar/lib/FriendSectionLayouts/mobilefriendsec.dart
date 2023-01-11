import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:chapar/DTOs/accept_friend_request.dart';
import 'package:chapar/DTOs/contact.dart';
import 'package:chapar/DTOs/simple_friend.dart';
import 'package:chapar/contacts.dart';
import 'package:chapar/thememanager.dart';
import '../thememanager.dart' as themeManager;
import 'package:http/http.dart';
import 'package:chapar/main.dart';

Contact? currentContact;

class MobileScreenFriendSection extends StatefulWidget {
  dynamic Function() getContactData;
  MobileScreenFriendSection({Key? key, required this.getContactData})
      : super(key: key);

  @override
  State<MobileScreenFriendSection> createState() =>
      MobileScreenFriendSectionState();
}

class MobileScreenFriendSectionState extends State<MobileScreenFriendSection> {
  List<Map<String, dynamic>> friendRequests = List.generate(
      receivedFriendRequests.length,
      (index) => {
            'id': receivedFriendRequests[index].id,
            'title': receivedFriendRequests[index].fromContactUsername,
            'description': receivedFriendRequests[index].text,
            'isExpanded': false
          });

  Future<void> acceptFriendRequest(int frId) async {
    try {
      final response = await post(
          Uri.parse("$domain/api/Contact/AcceptFriendRequest"),
          body: jsonEncode(AcceptFriendRequestDTO(frId)),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken'
          });
      if (response.statusCode == 401) {
        await reauth(context);
        await acceptFriendRequest(frId);
        return;
      }
      if (jsonDecode(response.body) == true) {
        final fr =
            receivedFriendRequests.firstWhere((element) => element.id == frId);
        friendRequests.removeAt(receivedFriendRequests.indexOf(fr));
        receivedFriendRequests.remove(fr);
        widget.getContactData();
        setState(() {});
      }
      return;
    } on Exception catch (_) {
      showAlertDialog("متاسفانه درخواست با خطا روبرو شد", "خطا");
      setState(() {});
    }
  }

  Future<void> denideFriendRequest(int frId) async {
    try {
      var response = await post(
          Uri.parse("$domain/api/Contact/DenideFriendRequest"),
          body: jsonEncode(AcceptFriendRequestDTO(frId)),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken'
          });
      if (response.statusCode == 401) {
        await reauth(context);
        await denideFriendRequest(frId);
      }
      if (jsonDecode(response.body) == true) {
        setState(() {
          final fr = receivedFriendRequests
              .firstWhere((element) => element.id == frId);
          friendRequests.removeAt(receivedFriendRequests.indexOf(fr));
          receivedFriendRequests.remove(fr);
        });
      }
      return;
    } on Exception catch (_) {
      showAlertDialog("متاسفانه درخواست با خطا روبرو شد", "خطا");
    }
  }

  bool isRequestsOpen = false;

  updateTheme() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
            child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return ExpansionTile(
              collapsedIconColor: themeManager.applicationTheme.primaryColor,
              iconColor: themeManager.applicationTheme.primaryColor,
              title: Text(
                "درخواست های دوستی",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: themeManager.applicationTheme.primaryColor),
              ),
              children: [
                ExpansionPanelList(
                  elevation: 3,
                  expansionCallback: (index, isExpanded) {
                    setState(() {
                      friendRequests[index]['isExpanded'] = !isExpanded;
                    });
                  },
                  children: friendRequests
                      .map(
                        (item) => ExpansionPanel(
                          isExpanded: item['isExpanded'],
                          canTapOnHeader: true,
                          backgroundColor: item['isExpanded'] == true
                              ? themeManager.applicationTheme.primaryColor
                              : themeManager.applicationTheme.backgroundColor,
                          headerBuilder: (_, isExpanded) => Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 30),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['title'],
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: item['isExpanded'] == true
                                            ? themeManager.applicationTheme
                                                .backgroundColor
                                            : themeManager
                                                .applicationTheme.primaryColor,
                                        fontFamily: "Chubbo Light"),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            acceptFriendRequest(
                                                item.values.first);
                                            setState(() {});
                                          },
                                          icon: const Icon(Icons.check_circle,
                                              color: Colors.green)),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              denideFriendRequest(
                                                  int.parse(item.values.first));
                                            });
                                          },
                                          icon: const Icon(Icons.cancel,
                                              color: Colors.red))
                                    ],
                                  )
                                ],
                              )),
                          body: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 30),
                            child: Text(item['description']),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          },
        )),
        Expanded(
            child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return ExpansionTile(
              collapsedIconColor: themeManager.applicationTheme.primaryColor,
              iconColor: themeManager.applicationTheme.primaryColor,
              title: Text(
                "فهرست دوستان",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: themeManager.applicationTheme.primaryColor),
              ),
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: friends.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 50,
                      color: themeManager.applicationTheme.primaryColor,
                      child: Center(
                          child: Text(
                        friends[index].username.toString(),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      )),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              ],
            );
          },
        ))
      ],
    );
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
      backgroundColor: applicationTheme.backgroundColor,
      title: Text(
        title,
        style: TextStyle(
            fontFamily: "Vazir", color: applicationTheme.primaryColor),
      ),
      content: Text(
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
}
