import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'register.dart' as registerpage;
import 'DTOs/authentication_response.dart';
import 'contacts.dart';
import 'main.dart';

double screenWidth = 0;
double screenHeight = 0;

class LoginPageWidget extends StatefulWidget {
  const LoginPageWidget({Key? key}) : super(key: key);

  @override
  LoginPage createState() => LoginPage();
}

class LoginPage extends State<LoginPageWidget> {
  final TextEditingController lUsernameTF = TextEditingController();
  final TextEditingController lPasswordTF = TextEditingController();
  var passwordVisible = false;
  var loginErorText = "";

  Future<bool> authenticate(String username, String password) async {
    try {
      var response = await post(Uri.parse("$domain/api/account/login"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
              <String, String>{'UserName': username, 'Password': password}));
      var res = AuthenticationResponse.fromJson(jsonDecode(response.body));
      if (res.error != "" && res.error != null) {
        loginErorText = res.error ?? "";
        return false;
      }
      cacheManager.setString("accessToken", res.accessToken.toString());
      cacheManager.setString("refreshToken", res.refreshToken.toString());
      accessToken = res.accessToken.toString();
      refreshToken = res.refreshToken.toString();
      return true;
    } on Exception catch (_) {
      setState(() {
        loginErorText = "متاسفانه درخواست با خطا روبرو شد";
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Container(
      constraints: const BoxConstraints(minHeight: 550, minWidth: 350),
      padding: EdgeInsets.symmetric(
          vertical: 00.0, horizontal: (screenWidth / 10) * 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextField(
            maxLength: 30,
            maxLines: 1,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontFamily: "Chubbo Light",
                fontSize: 20),
            cursorColor: Theme.of(context).primaryColor,
            controller: lUsernameTF,
            decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor)),
                hintStyle: const TextStyle(fontFamily: "Vazir", fontSize: 20),
                hintText: 'نام کاربری را وارد نمایید',
                focusColor: Theme.of(context).focusColor,
                hintTextDirection: TextDirection.rtl),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9._-]'))
            ],
          ),
          TextField(
            maxLength: 50,
            maxLines: 1,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontFamily: "Chubbo Light",
                fontSize: 20),
            controller: lPasswordTF,
            obscureText: !passwordVisible,
            cursorColor: Theme.of(context).primaryColor,
            decoration: InputDecoration(
              hintTextDirection: TextDirection.rtl,
              focusColor: Theme.of(context).focusColor,
              focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).primaryColor)),
              hintStyle: const TextStyle(fontFamily: "Vazir", fontSize: 20),
              hintText: 'رمز عبور را وارد نمایید',
              // Here is key idea
              suffixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).toggleableActiveColor,
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
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9@#%^&]'))
            ],
          ),
          TextButton(
              onPressed: () => {
                    authenticate(lUsernameTF.text, lPasswordTF.text)
                        .then((value) => value
                            ? Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ContactsPageWidget()))
                            : setState(() {}))
                  },
              child: const Text(
                "ورود",
                style: TextStyle(fontSize: 23),
              )),
          TextButton(
              onPressed: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const registerpage.RegisterPageWidget()))
                  },
              child: Text(
                textAlign: TextAlign.center,
                "حساب کاربری ندارید ؟ یکی بسازید",
                style: TextStyle(fontSize: 23),
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: Text(
                loginErorText,
                maxLines: 3,
                style: TextStyle(
                    height: 3,
                    fontSize: 18,
                    color: Theme.of(context).primaryColor),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ))
            ],
          )
        ],
      ),
    );
  }
}
