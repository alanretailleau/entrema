import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/account/account.dart';
import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/user.dart';
import 'package:entrema/color.dart';
import 'package:entrema/functions/function.dart';
import 'package:entrema/home/accueil/accueil.dart';
import 'package:entrema/home/scan/scanPage.dart';
import 'package:entrema/home/stocks/stock.dart';
import 'package:entrema/widget/account.dart';
import 'package:entrema/widget/bottom_bar.dart';
import 'package:entrema/widget/button.dart';
import 'package:entrema/widget/pdp.dart';
import 'package:fast_barcode_scanner/fast_barcode_scanner.dart';
import 'package:flutter/material.dart';
import '../widget/Loader.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.user, this.index = 1});
  final User user;
  final int index;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    userStream = FirebaseFirestore.instance
        .collection("user")
        .doc(widget.user.id)
        .snapshots();
    pageController = PageController(initialPage: widget.index);
    _counterNotifier = ValueNotifier<int>(widget.index);
    super.initState();
  }

  Commerce? commerce2;
  User? userr;
  late ValueNotifier<int> _counterNotifier;
  late Stream<DocumentSnapshot> userStream;
  late Widget restaurantPage;
  late Widget scanPage;
  late Widget chatHome;
  late Widget accountPage;
  late Widget stackPage;
  late PageController pageController;
  bool landscape = false;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width >
        MediaQuery.of(context).size.height * 1.2) {
      landscape = true;
    } else {
      landscape = false;
    }
    return Scaffold(
        body: FutureBuilder<Commerce>(
            future: Commerce.read(widget.user.commerce),
            builder: (context, snap) {
              if (snap.hasData) {
                Commerce commerce = snap.data!;
                commerce2 = commerce;
                return StreamBuilder<User?>(
                    stream: User.streamUser(widget.user.id),
                    builder: (context, userSnap) {
                      if (userSnap.hasData) {
                        User user = userSnap.data!;
                        userr = user;
                        if (user.bloque == true) {
                          return const Material(
                              child: Center(
                                  child: Text(
                            "Vous n'êtes pas authorisé.e à continuer.\nMerci de réessayer plus tard.",
                            textAlign: TextAlign.center,
                          )));
                        }

                        scanPage = ScanPage(commerce: commerce, user: user);

                        return WillPopScope(
                          onWillPop: () async {
                            bool quit = await editDialog(context, "Non", "Oui",
                                "Voulez-vous quitter Entr'EMA ?");
                            if (quit == true) {
                              exit(0);
                            } else {
                              return false;
                            }
                          },
                          child: ScrollConfiguration(
                              behavior:
                                  ScrollConfiguration.of(context).copyWith(
                                dragDevices: {
                                  PointerDeviceKind.touch,
                                  PointerDeviceKind.mouse,
                                  PointerDeviceKind.trackpad
                                },
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  PageView(
                                      controller: pageController,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      onPageChanged: (value) {
                                        if (value == 0) {
                                          CameraController.instance
                                              .resumeDetector();
                                        } else {
                                          CameraController.instance
                                              .pauseDetector();
                                        }
                                        _counterNotifier.value = value;
                                        scanPage = ScanPage(
                                            commerce: commerce, user: user);
                                      },
                                      children: [
                                        scanPage,
                                        Accueil(user: user, commerce: commerce),
                                        Stock(user: user, commerce: commerce),
                                      ]),
                                  landscape
                                      ? Positioned(
                                          top: 30,
                                          right: 20,
                                          left: 20,
                                          child: SizedBox(
                                              height: 70,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                          sigmaX: 5.0,
                                                          sigmaY: 5.0),
                                                      child: Container()))))
                                      : Container(),
                                  landscape
                                      ? Positioned(
                                          top: 30,
                                          right: 20,
                                          left: 20,
                                          child: Container(
                                            height: 70,
                                            decoration: BoxDecoration(
                                                color: white(context)
                                                    .withOpacity(.6),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2,
                                                  child:
                                                      ValueListenableBuilder<
                                                              int>(
                                                          valueListenable:
                                                              _counterNotifier,
                                                          builder: (context,
                                                              value,
                                                              Widget? child) {
                                                            return Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  SizedBox(
                                                                    width: (MediaQuery.of(context).size.width /
                                                                                2 -
                                                                            20) /
                                                                        3,
                                                                    child: CustomButton(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                                        color: user.couleur.withOpacity(value == 0 ? .1 : 0),
                                                                        onPressed: () {
                                                                          setState(
                                                                              () {
                                                                            scanPage =
                                                                                ScanPage(commerce: commerce, user: user);
                                                                          });

                                                                          pageController
                                                                              .jumpToPage(
                                                                            0,
                                                                          );
                                                                        },
                                                                        child: Center(
                                                                          child: Text(
                                                                              user.langue == "FR" ? "Scan" : "Scan",
                                                                              style: TextStyle(fontFamily: "Cocogoose", fontSize: 15, color: value != 0 ? black(context) : user.couleur)),
                                                                        )),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          10),
                                                                  SizedBox(
                                                                    width: (MediaQuery.of(context).size.width /
                                                                                2 -
                                                                            20) /
                                                                        3,
                                                                    child: CustomButton(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                                        color: user.couleur.withOpacity(value == 1 ? .1 : 0),
                                                                        onPressed: () {
                                                                          pageController
                                                                              .jumpToPage(
                                                                            1,
                                                                          );
                                                                        },
                                                                        child: Center(
                                                                          child: Text(
                                                                              user.langue == "FR" ? "Accueil" : "Home",
                                                                              style: TextStyle(fontFamily: "Cocogoose", fontSize: 15, color: value != 1 ? black(context) : user.couleur)),
                                                                        )),
                                                                  ),
                                                                ]);
                                                          }),
                                                ),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                4 -
                                                            40,
                                                    height: 100,
                                                    child: Account(
                                                        user: user,
                                                        commerce: commerce))
                                              ],
                                            ),
                                          ))
                                      : Container(),
                                  landscape
                                      ? Positioned(
                                          top: MediaQuery.of(context)
                                                  .padding
                                                  .top +
                                              110,
                                          bottom: 30,
                                          left: 0,
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4,
                                              child: ClipRRect(
                                                  borderRadius: const BorderRadius
                                                      .horizontal(
                                                      right:
                                                          Radius.circular(10)),
                                                  child: BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                          sigmaX: 20.0,
                                                          sigmaY: 20.0),
                                                      child: Container()))))
                                      : Container(),
                                  !landscape
                                      ? Positioned(
                                          top: MediaQuery.of(context)
                                                  .padding
                                                  .top +
                                              20,
                                          right: 20,
                                          child: SizedBox(
                                              height: 50,
                                              width: 50,
                                              child: CustomButton(
                                                  shape: const StadiumBorder(),
                                                  onPressed: () {
                                                    if (commerce2 != null &&
                                                        userr != null) {
                                                      setState(() {});
                                                      pushPage(
                                                          context,
                                                          AccountPage(
                                                              user: user,
                                                              commerce:
                                                                  commerce));
                                                    }
                                                  },
                                                  child: Hero(
                                                    tag: "${user.id}account",
                                                    child: Pdp(
                                                        height: 50,
                                                        user: user,
                                                        radius: 25),
                                                  ))))
                                      : Container(),
                                  !landscape
                                      ? Positioned(
                                          bottom: 0,
                                          child: ValueListenableBuilder<int>(
                                              valueListenable: _counterNotifier,
                                              builder: (context, value,
                                                  Widget? child) {
                                                return BottomBar(
                                                    index: value,
                                                    user: user,
                                                    onPressed: (v) {
                                                      pageController
                                                          .jumpToPage(v);
                                                    });
                                              }))
                                      : Container(),
                                ],
                              )),
                        );
                      } else {
                        return const Center(child: Loader());
                      }
                    });
              } else {
                return const Center(
                    child: Loader(
                  color: Colors.blue,
                ));
              }
            }));
  }
}
