import 'package:entrema/color.dart';
import 'package:entrema/widget/button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar(
      {super.key, required this.title, this.back = true, this.onPressed});
  final String title;
  final bool back;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          back
              ? SizedBox(
                  height: 50,
                  width: 50,
                  child: CustomButton(
                      color: black(context).withOpacity(.02),
                      shape: const StadiumBorder(),
                      onPressed: onPressed ??
                          () {
                            Navigator.pop(context);
                          },
                      child: Image.asset("assets/icon/back.png",
                          color: black(context), scale: 10)))
              : Container(),
          SizedBox(
            width: back ? 10 : 0,
          ),
          Text(title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))
        ],
      ),
    );
  }
}
