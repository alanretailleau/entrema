import 'package:entrema/color.dart';
import 'package:entrema/widget/boxBox.dart';
import 'package:entrema/widget/button.dart';
import 'package:flutter/cupertino.dart';

Widget Box(
    Widget title, Widget body, Function()? settings, BuildContext context) {
  return BoxBox(
      Column(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                title,
                settings != null
                    ? SizedBox(
                        height: 40,
                        width: 40,
                        child: CustomButton(
                            shape: const StadiumBorder(),
                            onPressed: () {},
                            child: Image.asset(
                              "assets/icon/settings.png",
                              color: black(context),
                              scale: 10,
                            )),
                      )
                    : Container()
              ],
            ),
          ),
          body
        ],
      ),
      context);
}
