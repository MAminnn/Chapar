import 'package:flutter/material.dart';
import 'thememanager.dart';
class ResponsiveLayout extends StatelessWidget {
  final Widget mobileScreenWidget;
  final Widget desktopScreenWidget;
  ThemeData applicationTheme;
  ResponsiveLayout({
    Key? key,
    required this.desktopScreenWidget,
    required this.mobileScreenWidget,
    required this.applicationTheme
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 600) {
          return mobileScreenWidget;
        } else {
          return desktopScreenWidget;
        }
      },
    );
  }
}
