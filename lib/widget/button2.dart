import 'package:flutter/material.dart';

import '../color.dart';

// ignore: must_be_immutable
class Button extends StatelessWidget {
  Button(
      {super.key, required this.height,
      required this.active,
      this.multipleChoice,
      this.activeColor,
      this.disabledColor});
  final double height;
  final bool? multipleChoice;
  final bool active;
  Color? activeColor, disabledColor;

  @override
  Widget build(BuildContext context) {
    activeColor ??= blue;
    disabledColor ??= Theme.of(context).primaryColorDark.withOpacity(0.2);
    return Container(
      height: height,
      width: height,
      padding: EdgeInsets.all(height / 6),
      decoration: BoxDecoration(
        color: active
            ? activeColor!.withOpacity(.1)
            : disabledColor!.withOpacity(.1),
        borderRadius:
            BorderRadius.circular(multipleChoice == true ? height / 4 : 20),
      ),
      child: Container(
        decoration: BoxDecoration(
            color: active ? activeColor : null,
            borderRadius:
                BorderRadius.circular(multipleChoice == true ? height / 6 : 20),
            border: Border.all(
                color: active
                    ? activeColor ?? Colors.transparent
                    : disabledColor ?? Colors.transparent,
                width: 2)),
      ),
    );
  }
}
