import 'dart:ui';

import 'package:entrema/classes/user.dart';
import 'package:entrema/color.dart';
import 'package:entrema/functions/function.dart';
import 'package:entrema/widget/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class BottomBar extends StatelessWidget {
  const BottomBar(
      {super.key,
      required this.index,
      required this.user,
      required this.onPressed});

  final int index;
  final Function onPressed;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
            margin: const EdgeInsets.all(20),
            height: 60,
            width: MediaQuery.of(context).size.width - 40,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container()))),
        Container(
          margin: const EdgeInsets.all(20),
          height: 60,
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: white(context).withOpacity(.5)),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedContainer(
                      curve: Curves.easeInOutCubicEmphasized,
                      duration: const Duration(milliseconds: 500),
                      height: 40,
                      width: index == 0
                          ? calculateTextSize(
                                      text:
                                          user.langue == "FR" ? "Scan" : "Scan",
                                      style: TextStyle(
                                          color: index == 0
                                              ? user.couleur
                                              : black(context),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          fontFamily: "Cocogoose"),
                                      context: context)
                                  .width +
                              50
                          : 40,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          SizedBox(
                            height: 40,
                            child: CustomButton(
                              padding: const EdgeInsets.all(10),
                              color: user.couleur
                                  .withOpacity(index == 0 ? .1 : .0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              child: Container(),
                              onPressed: () {
                                onPressed(0);
                              },
                            ),
                          ),
                          Positioned(
                            left: 10,
                            child: IgnorePointer(
                              child: Image.asset("assets/icon/scan.png",
                                  color: index == 0
                                      ? user.couleur
                                      : black(context),
                                  scale: 10),
                            ),
                          ),
                          Positioned(
                              right: 10,
                              child: IgnorePointer(
                                  child: AnimatedOpacity(
                                      opacity: index == 0 ? 1 : 0,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeInOutCubicEmphasized,
                                      child: Text(
                                          user.langue == "FR" ? "Scan" : "Scan",
                                          style: TextStyle(
                                              color: index == 0
                                                  ? user.couleur
                                                  : black(context),
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Cocogoose")))))
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      curve: Curves.easeInOutCubicEmphasized,
                      duration: const Duration(milliseconds: 500),
                      height: 40,
                      width: index == 1
                          ? calculateTextSize(
                                      text: user.langue == "FR"
                                          ? "Accueil"
                                          : "Home",
                                      style: TextStyle(
                                          color: index == 1
                                              ? user.couleur
                                              : black(context),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          fontFamily: "Cocogoose"),
                                      context: context)
                                  .width +
                              50
                          : 40,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          SizedBox(
                            height: 40,
                            child: CustomButton(
                              padding: const EdgeInsets.all(10),
                              color: user.couleur
                                  .withOpacity(index == 1 ? .1 : .0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              child: Container(),
                              onPressed: () {
                                onPressed(1);
                              },
                            ),
                          ),
                          Positioned(
                            left: 10,
                            child: IgnorePointer(
                              child: Image.asset("assets/icon/home.png",
                                  color: index == 1
                                      ? user.couleur
                                      : black(context),
                                  scale: 10),
                            ),
                          ),
                          Positioned(
                              right: 10,
                              child: IgnorePointer(
                                  child: AnimatedOpacity(
                                      opacity: index == 1 ? 1 : 0,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeInOutCubicEmphasized,
                                      child: Text(
                                          user.langue == "FR"
                                              ? "Accueil"
                                              : "Home",
                                          style: TextStyle(
                                              color: index == 1
                                                  ? user.couleur
                                                  : black(context),
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Cocogoose")))))
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      curve: Curves.easeInOutCubicEmphasized,
                      duration: const Duration(milliseconds: 500),
                      height: 40,
                      width: index == 2
                          ? calculateTextSize(
                                      text: user.langue == "FR"
                                          ? "Stock"
                                          : "Stock",
                                      style: TextStyle(
                                          color: index == 2
                                              ? user.couleur
                                              : black(context),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Cocogoose"),
                                      context: context)
                                  .width +
                              54
                          : 40,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          SizedBox(
                            height: 40,
                            child: CustomButton(
                              padding: const EdgeInsets.all(10),
                              color: user.couleur
                                  .withOpacity(index == 2 ? .1 : .0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              child: Container(),
                              onPressed: () {
                                onPressed(2);
                              },
                            ),
                          ),
                          Positioned(
                            left: 10,
                            child: IgnorePointer(
                              child: Image.asset("assets/icon/boutique.png",
                                  color: index == 2
                                      ? user.couleur
                                      : black(context),
                                  scale: 10),
                            ),
                          ),
                          Positioned(
                              right: 10,
                              child: IgnorePointer(
                                  child: AnimatedOpacity(
                                      opacity: index == 2 ? 1 : 0,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeInOutCubicEmphasized,
                                      child: Text(
                                          user.langue == "FR"
                                              ? "Stock"
                                              : "Stock",
                                          style: TextStyle(
                                              color: index == 2
                                                  ? user.couleur
                                                  : black(context),
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Cocogoose")))))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
