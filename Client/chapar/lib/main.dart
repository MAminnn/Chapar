// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chapar/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart';
import 'package:http/http.dart';
import 'DTOs/authentication_response.dart';
import 'DTOs/refresh_token_command.dart';
import 'contacts.dart';
import 'thememanager.dart';

String accessToken = "";
String refreshToken = "";
String domain = "https://chapar.aminkarvizi.ir";
var cacheManager;

Future<void> reauth(BuildContext context) async {
  var refreshresponse = await post(Uri.parse("$domain/api/account/refrshtoken"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(RefreshTokenCommand((cacheManager as SharedPreferences)
          .getString("refreshToken")
          .toString())));

  if (refreshresponse.body == "") {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const ThemeLayout(body: LoginPageWidget())));
  } else {
    final authres =
        AuthenticationResponse.fromJson(jsonDecode(refreshresponse.body));
    cacheManager.setString("accessToken", authres.accessToken);
    cacheManager.setString("refreshToken", authres.refreshToken);
    accessToken = authres.accessToken.toString();
    refreshToken = authres.refreshToken.toString();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String connectionStatusText = "";
  bool isConnectionInProgress = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              connectionStatusText,
              style: const TextStyle(fontSize: 25, color: Colors.black),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            Padding(
              padding: const EdgeInsets.all(35),
              child: TextButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          isConnectionInProgress
                              ? Colors.black26
                              : Colors.black)),
                  onPressed: isConnectionInProgress
                      ? () {}
                      : () {
                          connectToServer();
                        },
                  child: Text(
                    "تلاش مجدد",
                    style: TextStyle(
                        color: isConnectionInProgress
                            ? Colors.white60
                            : Colors.white,
                        fontSize: 23),
                  )),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  void connectToServer() async {
    setState(() {
      isConnectionInProgress = true;
      connectionStatusText = "درحال اتصال به سرور ...";
    });
    try {
      cacheManager = await SharedPreferences.getInstance();
      WidgetsFlutterBinding.ensureInitialized();
      if (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows && !kIsWeb) {
        setWindowMinSize(const Size(900, 600));
        setWindowTitle("Chapar");
      }
      final refreshresponse = await post(
            Uri.parse("$domain/api/account/refrshtoken"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(RefreshTokenCommand(
                (cacheManager as SharedPreferences)
                    .getString("refreshToken")
                    .toString())));
        if (refreshresponse.body == "") {
          navigate(const ThemeLayout(
            body: LoginPageWidget(),
          ));
        } else {
          final authres =
              AuthenticationResponse.fromJson(jsonDecode(refreshresponse.body));
          cacheManager.setString("accessToken", authres.accessToken);
          cacheManager.setString("refreshToken", authres.refreshToken);
          accessToken = authres.accessToken.toString();
          refreshToken = authres.refreshToken.toString();
          navigate(const ContactsPageWidget());
        }
    } on Exception catch (_) {
      setState(() {
        connectionStatusText = "خطا در ارتباط با سرور";
        isConnectionInProgress = false;
      });
    }
  }

  void navigate(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }
}

void main() {
  return runApp(MaterialApp(
    theme: applicationTheme,
    home: const MainPage(),
  ));
}
