import 'package:flutter/material.dart';
import 'main.dart';

final persianFont = "Vazir";
final englishFont = "";

ThemeData applicationTheme = appThemes[0];
MaterialColor aquaThemeColor = const MaterialColor(0x1CDAB8, {
  50: Color.fromARGB(255, 28, 218, 184),
  200: Color.fromARGB(255, 0, 158, 167),
  700: Color.fromARGB(255, 47, 72, 88),
  900: Color.fromARGB(255, 0, 188, 179)
});
MaterialColor yellowThemeColor = const MaterialColor(0xFFD54F, {
  50: Color.fromARGB(255, 255, 255, 129),
  200: Color.fromARGB(255, 255, 213, 79),
  700: Color.fromARGB(255, 200, 164, 21),
  900: Color.fromARGB(255, 159, 198, 90)
});
MaterialColor orangeThemeColor = const MaterialColor(0xFF8F00, {
  50: Color.fromARGB(255, 255, 192, 70),
  200: Color.fromARGB(255, 255, 143, 0),
  700: Color.fromARGB(255, 197, 96, 0),
  900: Color.fromARGB(255, 255, 96, 92)
});
MaterialColor lightblueThemeColor = const MaterialColor(0x00897B, {
  50: Colors.white,
  200: Color.fromARGB(255, 64, 196, 255),
  700: Color.fromARGB(255, 0, 148, 204)
});
MaterialColor darkThemeColor = const MaterialColor(0x1C1C1C, {
  50: Color.fromARGB(255, 153, 153, 153),
  200: Color.fromARGB(255, 28, 28, 28),
  700: Color.fromARGB(255, 0, 0, 0),
  900: Color.fromARGB(255, 143, 122, 140)
});
MaterialColor lightThemeColor = const MaterialColor(0xDA1C1C, {
  50: Color.fromARGB(255, 38, 166, 154),
  200: Colors.white,
  700: Color.fromARGB(255, 222, 222, 222),
  900: Color.fromARGB(255, 105, 205, 143)
});

var darkColor = const Color.fromARGB(255, 33, 33, 33);
List<ThemeData> appThemes = [
  ThemeData(
      textTheme: const TextTheme(
          bodyText2: TextStyle(
        color: Color.fromARGB(255, 55, 71, 79),
      )),
      indicatorColor: orangeThemeColor[200],
      primaryColor: orangeThemeColor[200],
      backgroundColor: const Color.fromARGB(255, 55, 71, 79),
      hintColor: orangeThemeColor[200],
      toggleableActiveColor: orangeThemeColor[200],
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all(orangeThemeColor[200]))),
      appBarTheme: AppBarTheme(backgroundColor: orangeThemeColor[700]),
      highlightColor: const Color.fromARGB(255, 55, 71, 79),
      fontFamily: "Vazir",
      secondaryHeaderColor: orangeThemeColor[900]),
  ThemeData(
      textTheme: TextTheme(bodyText2: TextStyle(color: darkColor)),
      indicatorColor: yellowThemeColor[200],
      primaryColor: yellowThemeColor[200],
      backgroundColor: darkColor,
      hintColor: yellowThemeColor[200],
      toggleableActiveColor: yellowThemeColor[200],
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all(yellowThemeColor[200]))),
      appBarTheme: AppBarTheme(backgroundColor: yellowThemeColor[700]),
      highlightColor: darkColor,
      fontFamily: "Vazir",
      secondaryHeaderColor: yellowThemeColor[900]),
  ThemeData(
      textTheme: TextTheme(bodyText2: TextStyle(color: aquaThemeColor[700])),
      indicatorColor: aquaThemeColor[700],
      primaryColor: aquaThemeColor[50],
      backgroundColor: aquaThemeColor[700],
      hintColor: aquaThemeColor[50],
      toggleableActiveColor: aquaThemeColor[50],
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(aquaThemeColor[50]))),
      appBarTheme: AppBarTheme(backgroundColor: aquaThemeColor[700]),
      highlightColor: aquaThemeColor[50],
      fontFamily: "Vazir",
      secondaryHeaderColor: aquaThemeColor[200]),
  ThemeData(
      textTheme: TextTheme(bodyText2: TextStyle(color: lightThemeColor[200])),
      indicatorColor: lightThemeColor[200],
      backgroundColor: lightThemeColor[200],
      primaryColor: lightThemeColor[50],
      hintColor: lightThemeColor[50],
      toggleableActiveColor: lightThemeColor[50],
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(lightThemeColor[50]))),
      appBarTheme: AppBarTheme(backgroundColor: lightThemeColor[700]),
      highlightColor: lightThemeColor[50],
      fontFamily: "Vazir",
      secondaryHeaderColor: lightThemeColor[900]),
  ThemeData(
      textTheme: TextTheme(bodyText2: TextStyle(color: darkThemeColor[200])),
      indicatorColor: darkThemeColor[200],
      primaryColor: darkThemeColor[50],
      backgroundColor: darkThemeColor[200],
      hintColor: darkThemeColor[50],
      toggleableActiveColor: darkThemeColor[50],
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(darkThemeColor[50]))),
      appBarTheme: AppBarTheme(backgroundColor: darkThemeColor[700]),
      highlightColor: darkThemeColor[50],
      fontFamily: "Vazir",
      secondaryHeaderColor: darkThemeColor[900])
];

class ThemeLayout extends StatefulWidget {
  Widget body;

  ThemeLayout({Key? key, required this.body}) : super(key: key);

  @override
  State<ThemeLayout> createState() => _ThemeLayoutState();
}

class _ThemeLayoutState extends State<ThemeLayout> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: applicationTheme,
      home: WillPopScope(
          onWillPop: (() async {
            return false;
          }),
          child: Scaffold(
            appBar: AppBar(
              actions: appThemes.map((theme) {
                return TextButton(
                    style: ButtonStyle(
                      minimumSize:
                          MaterialStateProperty.all(const Size(45, 45)),
                      maximumSize:
                          MaterialStateProperty.all(const Size(45, 45)),
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
                    color: applicationTheme.highlightColor,
                    fontFamily: "Vazir"),
              ),
            ),
            backgroundColor: applicationTheme.backgroundColor,
            body: widget.body,
          )),
    );
  }
}
