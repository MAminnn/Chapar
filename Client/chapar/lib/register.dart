import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:chapar/loginpage.dart';
import 'package:chapar/thememanager.dart';
import 'main.dart';
import 'DTOs/registeration_response.dart';

class RegisterPageWidget extends StatefulWidget {
  const RegisterPageWidget({Key? key}) : super(key: key);

  @override
  RegisterPage createState() => RegisterPage();
}

class RegisterPage extends State<RegisterPageWidget> {
  String registerErorText = "";
  double screenWidth = 0;
  double screenHeight = 0;
  final TextEditingController rPasswordTF = TextEditingController();
  final TextEditingController rConfirmPasswordTF = TextEditingController();
  final TextEditingController rEmailTF = TextEditingController();
  final TextEditingController rUsernameTF = TextEditingController();

  register(String username, String email, String password,
      String confirmPassword) async {
    try {
      if (username == "" ||
          email == "" ||
          password == "" ||
          confirmPassword == "") {
        registerErorText = " لطفاً ورودی ها را به طور کامل وارد نمایید";
        setState(() {});
        return;
      }
      var response = await post(Uri.parse("$domain/api/account/register"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'UserName': username,
            'Email': email,
            'Password': password,
            'ConfirmPassword': confirmPassword
          }));
      final RegisterationResponse res =
          RegisterationResponse.fromJson(jsonDecode(response.body));
      if (res.errors != null) {
        String errors = "";
        for (var i = 0;
            i < num.parse(res.errors?.length.toString() ?? "0");
            i++) {
          errors += "${res.errors?[i]}\n";
        }
        registerErorText = errors;
        setState(() {});
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ThemeLayout(body: const LoginPageWidget())));
      showAlertDialog(
          "حساب کاربری با موفقیت ایجاد شد ، برای تایید حساب کاربری به ایمیل خود مراجعه نمایید ، در صورت عدم مشاهده ی ایمیل به قسمت اسپم یا هرزنامه ها مراجعه نمایید",
          "موفقیت");
    } on Exception catch (_) {
      setState(() {
        registerErorText = "متاسفانه درخواست با خطا روبرو شد";
      });
    }
  }

  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      theme: applicationTheme,
      home: Scaffold(
        appBar: AppBar(
          actions: appThemes.map((theme) {
            return TextButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(45, 45)),
                  maximumSize: MaterialStateProperty.all(const Size(45, 45)),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
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
          title: Text(
            "چاپار",
            style: TextStyle(
                color: applicationTheme.highlightColor, fontFamily: "Vazir"),
          ),
        ),
        backgroundColor: applicationTheme.backgroundColor,
        body: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(minHeight: 550, minWidth: 350),
            padding: EdgeInsets.symmetric(
                vertical: 00.0, horizontal: (screenWidth - 150) / 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                  maxLines: 1,
                  maxLength: 30,
                  cursorColor: applicationTheme.primaryColor,
                  style: (TextStyle(
                    color: applicationTheme.primaryColor,
                    fontFamily: "Chubbo Light",
                    fontSize: 19,
                  )),
                  controller: rUsernameTF,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: applicationTheme.primaryColor)),
                      hintStyle: TextStyle(
                          color: applicationTheme.primaryColor,
                          fontFamily: "Vazir",
                          fontSize: 19),
                      hintText: 'نام کاربری را وارد نمایید',
                      hintTextDirection: TextDirection.rtl),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9._-]'))
                  ],
                ),
                TextField(
                  cursorColor: applicationTheme.primaryColor,
                  style: (TextStyle(
                    color: applicationTheme.primaryColor,
                    fontFamily: "Chubbo Light",
                    fontSize: 19,
                  )),
                  controller: rEmailTF,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: applicationTheme.primaryColor)),
                      hintStyle: TextStyle(
                          color: applicationTheme.primaryColor,
                          fontFamily: "Vazir",
                          fontSize: 19),
                      hintText: 'ایمیل را وارد نمایید',
                      hintTextDirection: TextDirection.rtl),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9@.]'))
                  ],
                ),
                TextField(
                  maxLength: 50,
                  maxLines: 1,
                  cursorColor: applicationTheme.primaryColor,
                  style: (TextStyle(
                    color: applicationTheme.primaryColor,
                    fontFamily: "Chubbo Light",
                    fontSize: 19,
                  )),
                  controller: rPasswordTF,
                  obscureText: !passwordVisible,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: applicationTheme.primaryColor)),
                    hintStyle: TextStyle(
                        color: applicationTheme.primaryColor,
                        fontFamily: "Vazir",
                        fontSize: 19),
                    hintTextDirection: TextDirection.rtl,
                    hintText: 'رمز عبور را وارد نمایید',
                    // Here is key idea
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Based on passwordVisible state choose the icon
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: applicationTheme.primaryColor,
                      ),
                      onPressed: () {
                        // Update the state i.e. toogle the state of passwordVisible variable
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
                  autocorrect: false,
                  enableSuggestions: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp('[a-zA-Z0-9@#%^&]'))
                  ],
                ),
                TextField(
                  maxLength: 50,
                  maxLines: 1,
                  cursorColor: applicationTheme.primaryColor,
                  style: (TextStyle(
                    color: applicationTheme.primaryColor,
                    fontFamily: "Chubbo Light",
                    fontSize: 19,
                  )),
                  controller: rConfirmPasswordTF,
                  obscureText: !passwordVisible,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: applicationTheme.primaryColor)),
                    hintStyle: TextStyle(
                        color: applicationTheme.primaryColor,
                        fontFamily: "Vazir",
                        fontSize: 19),
                    hintTextDirection: TextDirection.rtl,
                    hintText: 'تکرار رمز عبور را وارد نمایید',
                    // Here is key idea
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Based on passwordVisible state choose the icon
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: applicationTheme.primaryColor,
                      ),
                      onPressed: () {
                        // Update the state i.e. toogle the state of passwordVisible variable
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
                  autocorrect: false,
                  enableSuggestions: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp('[a-zA-Z0-9@#%^&]'))
                  ],
                ),
                Container(
                    margin: const EdgeInsets.all(20),
                    child: TextButton(
                        onPressed: () => {
                              register(rUsernameTF.text, rEmailTF.text,
                                  rPasswordTF.text, rConfirmPasswordTF.text)
                            },
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(20)),
                            backgroundColor: MaterialStateProperty.all(
                                applicationTheme.primaryColor)),
                        child: Text(
                          "ثبت",
                          style: TextStyle(
                              fontSize: 20,
                              color: applicationTheme.backgroundColor),
                        ))),
                TextButton(
                    onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ThemeLayout(
                                      body: const LoginPageWidget())))
                        },
                    child: Text(
                      textAlign: TextAlign.center,
                      "قبلاً ثبت نام کرده اید ؟ وارد شوید",
                      style: TextStyle(
                          fontSize: 22, color: applicationTheme.primaryColor),
                    )),
                Container(
                    child: Text(
                      registerErorText,
                      maxLines: 7,
                      style: const TextStyle(
                          height: 3,
                          fontSize: 18,
                          color: Colors.red),
                      textAlign: TextAlign.center,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
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
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
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
