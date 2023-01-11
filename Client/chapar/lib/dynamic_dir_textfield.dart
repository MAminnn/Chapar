import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

final ValueNotifier<TextDirection> textDir = ValueNotifier(TextDirection.ltr);

class DynamicTextField extends StatelessWidget {
  String currentFont = "Chubbo Light";
  final String persianFont = "Vazir";
  final String englishFont = "Chubbo Light";
  Color? cursorColor;
  TextStyle? style;
  TextEditingController controller;
  InputDecoration? decoration;
  String? hintText;
  FocusNode? focusNode;
  int? maxLines;
  int maxLength;
  DynamicTextField(
      {Key? key,
      required this.controller,
      this.cursorColor,
      this.decoration,
      this.style,
      this.hintText,
      this.focusNode,
      required this.maxLength,
      this.maxLines})
      : super(key: key);

  TextDirection getDirection(String v) {
    if (intl.Bidi.startsWithRtl(v)) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<TextDirection>(
        valueListenable: textDir,
        builder: (context, value, child) => TextField(
          keyboardType: TextInputType.multiline,
          controller: controller,
          textDirection: textDir.value,
          selectionWidthStyle: BoxWidthStyle.max,
          cursorColor: cursorColor,
          style: TextStyle(
              color: style?.color,
              fontFamily: currentFont,
              fontSize: style?.fontSize),
          focusNode: focusNode,
          decoration: decoration,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: (input) {
            if (input.trim().length < 2) {
              final currentInputDirection = getDirection(input);
              if (currentInputDirection != textDir.value) {
                controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length));
                textDir.value = currentInputDirection;
                currentFont = currentInputDirection == TextDirection.rtl
                    ? persianFont
                    : englishFont;
              }
            }
          },
        ),
      );
}
