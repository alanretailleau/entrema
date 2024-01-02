import 'package:entrema/color.dart';
import 'package:entrema/widget/button.dart';
import 'package:flutter/cupertino.dart';

Widget BoxBox(Widget body, BuildContext context) {
  return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: black(context).withOpacity(.01),
            spreadRadius: 5,
            offset: const Offset(0, 20),
            blurRadius: 15)
      ], color: white(context), borderRadius: BorderRadius.circular(17)),
      child: body);
}
