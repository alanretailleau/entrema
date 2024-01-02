import 'dart:convert';
import 'dart:developer';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/account/adherent/adherent.dart';
import 'package:entrema/account/produit/produit.dart';
import 'package:entrema/classes/adherent.dart';
import 'package:entrema/classes/categorie.dart';
import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/consommationProduit.dart';
import 'package:entrema/classes/course.dart';
import 'package:entrema/classes/picture.dart';
import 'package:entrema/classes/product.dart';
import 'package:entrema/classes/scanProduct.dart';
import 'package:entrema/classes/transaction.dart';
import 'package:entrema/classes/user.dart';
import 'package:entrema/functions/function.dart';
import 'package:entrema/widget/FieldText2.dart';
import 'package:entrema/widget/Loader.dart';
import 'package:entrema/widget/box.dart';
import 'package:entrema/widget/button.dart';
import 'package:entrema/widget/galerieElement.dart';
import 'package:entrema/widget/money.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fast_barcode_scanner/fast_barcode_scanner.dart';
import 'package:vibration/vibration.dart';
import '../../color.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key, required this.user, required this.commerce});
  final Commerce commerce;
  final User user;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<dynamic> productScan = [];

  PageController _controller = PageController();

  bool cameraPosition = true;
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Theme.of(context).primaryColor,
        child: Scaffold(
            backgroundColor: Colors.blueGrey.withOpacity(0.1),
            body: SingleChildScrollView(
              child: StreamBuilder<List<Course>>(
                  stream:
                      Course.streamCourses(widget.commerce.id, widget.user.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Course> courses = snapshot.data!;
                      if (courses.isEmpty) {
                        DocumentReference coursesRef = FirebaseFirestore
                            .instance
                            .collection("courses")
                            .doc();
                        Course(
                            price: 0,
                            id: coursesRef.id,
                            date: DateTime.now(),
                            commerce: widget.commerce.id,
                            user: widget.user.id,
                            finish: false,
                            adherent: "",
                            element: []).create();
                      }
                      return StreamBuilder<Adherent?>(
                          stream: courses[0].adherent != ""
                              ? Adherent.streamAdherent(courses[0].adherent)
                              : null,
                          builder: (context, snapshot2) {
                            Adherent? adherent = snapshot2.data;
                            return SafeArea(
                                child: Column(children: [
                              const SizedBox(height: 50),
                              Container(
                                  margin: const EdgeInsets.all(30),
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(5),
                                  height: 250,
                                  decoration: BoxDecoration(
                                      color: white(context),
                                      borderRadius: BorderRadius.circular(17)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      children: [
                                        BarcodeCamera(
                                          types: const [
                                            BarcodeType.ean8,
                                            BarcodeType.ean13,
                                            BarcodeType.code128
                                          ],
                                          resolution: Resolution.hd1080,
                                          framerate: Framerate.fps30,
                                          mode: DetectionMode.pauseDetection,
                                          onScan: (code) async {
                                            if (productScan
                                                .where((element) =>
                                                    (element.runtimeType ==
                                                            Product &&
                                                        (element as Product)
                                                            .barcode
                                                            .contains(
                                                                code.value)) ||
                                                    (element.runtimeType ==
                                                            ScanProduct &&
                                                        (element as ScanProduct)
                                                                .id ==
                                                            code.value))
                                                .isEmpty) {
                                              CameraController.instance
                                                  .pauseDetector();
                                              productScan.add(
                                                  await getProduct(code.value));
                                              setState(() {
                                                CameraController.instance
                                                    .resumeDetector();
                                                _controller.animateToPage(
                                                    productScan.length - 1,
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    curve: Curves
                                                        .easeInOutCubicEmphasized);
                                              });
                                            } else {
                                              int indexOf = productScan.indexOf(
                                                  productScan.firstWhere((element) =>
                                                      (element.runtimeType ==
                                                              Product &&
                                                          (element as Product)
                                                              .barcode
                                                              .contains(code
                                                                  .value)) ||
                                                      (element.runtimeType ==
                                                              ScanProduct &&
                                                          (element as ScanProduct)
                                                                  .id ==
                                                              code.value)));

                                              _controller.animateToPage(indexOf,
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                  curve: Curves
                                                      .easeInOutCubicEmphasized);
                                              CameraController.instance
                                                  .resumeDetector();
                                            }
                                            if (await Vibration
                                                    .hasAmplitudeControl() ==
                                                true) {
                                              Vibration.vibrate(
                                                  amplitude: 128,
                                                  duration: 100);
                                            }
                                          },
                                          children: [
                                            MaterialPreviewOverlay(
                                              animateDetection: true,
                                              aspectRatio:
                                                  (MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          40) /
                                                      150,
                                            ),
                                            const BlurPreviewOverlay(
                                              blurAmount: 50,
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                            top: 5,
                                            right: 5,
                                            child: SizedBox(
                                              height: 40,
                                              width: 40,
                                              child: CustomButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  splashColor: black(context)
                                                      .withOpacity(.1),
                                                  highlightColor: black(context)
                                                      .withOpacity(.1),
                                                  color: white(context),
                                                  onPressed: () {
                                                    setState(() {});
                                                    if (cameraPosition) {
                                                      CameraController.instance
                                                          .pauseDetector();
                                                      cameraPosition = false;
                                                    } else {
                                                      CameraController.instance
                                                          .resumeDetector();
                                                      cameraPosition = true;
                                                    }
                                                  },
                                                  child: Image.asset(
                                                      "assets/icon/play2.png",
                                                      scale: 10,
                                                      color: black(context))),
                                            ))
                                      ],
                                    ),
                                  )),
                              Box(
                                  ChoiceAdherent(snapshot.data!, adherent),
                                  scanParameters(snapshot.data!, adherent),
                                  () {},
                                  context)
                            ]));
                          });
                    } else {
                      return Center(child: Loader(color: black(context)));
                    }
                  }),
            )));
  }

  Widget ChoiceAdherent(List<Course> courses, Adherent? adherent) {
    return CustomButton(
        padding: EdgeInsets.only(
            left: 10,
            right: adherent != null ? 10 : 20,
            top: adherent != null ? 5 : 10,
            bottom: adherent != null ? 5 : 10),
        onPressed: () async {
          Adherent? adh = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AdherentPage(
                      choice: true,
                      user: widget.user,
                      commerce: widget.commerce,
                    )),
          );
          if (adh != null) {
            setState(() {
              adherent = adh;
              courses[0].adherent = adh.id;
              courses[0].update();
            });
          }
        },
        shape: StadiumBorder(
            side: BorderSide(color: black(context).withOpacity(.1))),
        child: adherent == null
            ? Row(children: [
                Image.asset("assets/icon/profile.png",
                    color: black(context), scale: 10),
                const SizedBox(
                  width: 15,
                ),
                const Text("Choisir un.e adhérent.e",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))
              ])
            : Row(children: [
                Text("${adherent!.prenom} ${adherent!.nom}",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(
                  width: 15,
                ),
                CustomButton(
                    color: widget.user.couleur.withOpacity(.1),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: const StadiumBorder(),
                    onPressed: () {
                      showCupertinoModalPopup(
                          context: context,
                          builder: (context) {
                            return Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      color: white(context),
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(20))),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomButton(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          shape: StadiumBorder(
                                              side: BorderSide(
                                                  color: black(context)
                                                      .withOpacity(.1))),
                                          onPressed: () {},
                                          child: const Text(
                                              "Recharger le compte de l'adhérent.e")),
                                      const SizedBox(height: 10),
                                      CustomButton(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          shape: StadiumBorder(
                                              side: BorderSide(
                                                  color: black(context)
                                                      .withOpacity(.1))),
                                          onPressed: () {
                                            pushPage(
                                                context,
                                                NewAdherentPage(
                                                  user: widget.user,
                                                  commerce: widget.commerce,
                                                  adherent: adherent,
                                                ));
                                          },
                                          child: const Text(
                                              "Modifier les données de l'adhérent.e"))
                                    ],
                                  ),
                                ));
                          });
                    },
                    child: Money(
                        price: adherent.solde / 100,
                        style: TextStyle(
                            fontFamily: "cocogoose",
                            color: widget.user.couleur,
                            fontSize: 15,
                            fontWeight: FontWeight.bold))),
                const SizedBox(
                  width: 15,
                ),
                SizedBox(
                  height: 30,
                  width: 30,
                  child: CustomButton(
                    shape: StadiumBorder(),
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      courses[0].adherent = " ";
                      courses[0].update();
                      adherent = null;
                      setState(() {});
                    },
                    child: Image.asset("assets/icon/cancel.png",
                        color: black(context), scale: 10),
                  ),
                ),
              ]));
  }

  Widget scanParameters(List<Course> courses, Adherent? adherent) {
    return SizedBox(
        height: MediaQuery.of(context).size.height - 590,
        child: PageView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 1 + productScan.length,
            itemBuilder: (context, index) {
              if (index == productScan.length) {
                return Column(children: [
                  Expanded(
                    child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: courses[0].element.length,
                        padding: const EdgeInsets.only(top: 10),
                        itemBuilder: ((context, index) {
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        height: 40,
                                        width: 40,
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.network(
                                                courses[0]
                                                    .element[index]
                                                    .produit
                                                    .url,
                                                fit: BoxFit.cover))),
                                    const SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            courses[0]
                                                .element[index]
                                                .produit
                                                .nom,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                        CustomButton(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          color: courses[0]
                                              .element[index]
                                              .produit
                                              .couleur
                                              .withOpacity(.1),
                                          shape: const StadiumBorder(),
                                          child: Center(
                                            child: Text(
                                                "${courses[0].element[index].poids} ${courses[0].element[index].produit.unite}",
                                                style: TextStyle(
                                                    color: courses[0]
                                                        .element[index]
                                                        .produit
                                                        .couleur,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  MoneyMaskedTextController
                                                      poids =
                                                      MoneyMaskedTextController(
                                                          rightSymbol:
                                                              " ${courses[0].element[index].produit.unite}",
                                                          precision: 1,
                                                          initialValue: courses[
                                                                  0]
                                                              .element[index]
                                                              .poids);
                                                  return Dialog(
                                                    insetPadding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    backgroundColor:
                                                        white(context),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20.0),
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            GalerieElementV2(
                                                                height: 60,
                                                                width: 60,
                                                                idUser: widget
                                                                    .user.id,
                                                                context:
                                                                    context,
                                                                info: Picture(
                                                                    darkColor:
                                                                        Colors
                                                                            .black,
                                                                    lightColor:
                                                                        Colors
                                                                            .white,
                                                                    width: 100,
                                                                    height: 100,
                                                                    url: courses[
                                                                            0]
                                                                        .element[
                                                                            index]
                                                                        .produit
                                                                        .url,
                                                                    galerie:
                                                                        ""),
                                                                radius: 30),
                                                            const SizedBox(
                                                                height: 20),
                                                            Text(
                                                              courses[0]
                                                                  .element[
                                                                      index]
                                                                  .produit
                                                                  .nom,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 18),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            const SizedBox(
                                                                height: 50),
                                                            SizedBox(
                                                              height: 75,
                                                              child: FieldText2(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  borderColor: black(
                                                                          context)
                                                                      .withOpacity(
                                                                          .1),
                                                                  hintText:
                                                                      "Poids",
                                                                  controller:
                                                                      poids,
                                                                  keyboardType: const TextInputType
                                                                      .numberWithOptions(
                                                                      decimal:
                                                                          false),
                                                                  onChanged:
                                                                      (v) {
                                                                    courses[0]
                                                                        .element[
                                                                            index]
                                                                        .poids = poids.numberValue;
                                                                    courses[0]
                                                                        .update();
                                                                    setState(
                                                                        () {});
                                                                  }),
                                                            ),
                                                            const SizedBox(
                                                                height: 50),
                                                            CustomButton(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        10),
                                                                onPressed: () {
                                                                  setState(
                                                                      () {});
                                                                  CameraController
                                                                      .instance
                                                                      .resumeDetector();
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                shape: StadiumBorder(
                                                                    side: BorderSide(
                                                                        color: black(context).withOpacity(
                                                                            .1))),
                                                                child: const Text(
                                                                    "Modifier",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w700)))
                                                          ]),
                                                    ),
                                                  );
                                                });
                                          },
                                        )
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    CustomButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              MoneyMaskedTextController price =
                                                  MoneyMaskedTextController(
                                                      rightSymbol: " €",
                                                      precision: 2,
                                                      initialValue: courses[0]
                                                                  .element[
                                                                      index]
                                                                  .price !=
                                                              null
                                                          ? courses[0]
                                                                  .element[
                                                                      index]
                                                                  .price! /
                                                              100
                                                          : courses[0]
                                                                  .element[
                                                                      index]
                                                                  .poids /
                                                              courses[0]
                                                                  .element[
                                                                      index]
                                                                  .produit
                                                                  .poids *
                                                              courses[0]
                                                                  .element[
                                                                      index]
                                                                  .produit
                                                                  .price /
                                                              100);
                                              return Dialog(
                                                insetPadding:
                                                    const EdgeInsets.all(20),
                                                backgroundColor: white(context),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        GalerieElementV2(
                                                            height: 60,
                                                            width: 60,
                                                            idUser:
                                                                widget.user.id,
                                                            context: context,
                                                            info: Picture(
                                                                darkColor:
                                                                    Colors
                                                                        .black,
                                                                lightColor:
                                                                    Colors
                                                                        .white,
                                                                width: 100,
                                                                height: 100,
                                                                url: courses[0]
                                                                    .element[
                                                                        index]
                                                                    .produit
                                                                    .url,
                                                                galerie: ""),
                                                            radius: 30),
                                                        const SizedBox(
                                                            height: 20),
                                                        Text(
                                                          courses[0]
                                                              .element[index]
                                                              .produit
                                                              .nom,
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 18),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                            height: 50),
                                                        SizedBox(
                                                          height: 75,
                                                          child: FieldText2(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              borderColor: black(
                                                                      context)
                                                                  .withOpacity(
                                                                      .1),
                                                              hintText: "Prix",
                                                              controller: price,
                                                              keyboardType:
                                                                  const TextInputType
                                                                      .numberWithOptions(
                                                                      decimal:
                                                                          false),
                                                              onChanged: (v) {
                                                                courses[0]
                                                                        .element[
                                                                            index]
                                                                        .price =
                                                                    (price.numberValue *
                                                                            100)
                                                                        .round();
                                                                courses[0]
                                                                    .update();
                                                                setState(() {});
                                                              }),
                                                        ),
                                                        const SizedBox(
                                                            height: 50),
                                                        courses[0]
                                                                    .element[
                                                                        index]
                                                                    .price !=
                                                                null
                                                            ? CustomButton(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        10),
                                                                onPressed: () {
                                                                  courses[0]
                                                                      .element[
                                                                          index]
                                                                      .price = null;
                                                                  setState(
                                                                      () {});
                                                                  CameraController
                                                                      .instance
                                                                      .resumeDetector();
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                shape: StadiumBorder(
                                                                    side: BorderSide(
                                                                        color: black(context).withOpacity(
                                                                            .1))),
                                                                child: const Text(
                                                                    "Annuler la modification",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w700)))
                                                            : Container(),
                                                        CustomButton(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        10),
                                                            onPressed: () {
                                                              setState(() {});
                                                              CameraController
                                                                  .instance
                                                                  .resumeDetector();
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            shape: StadiumBorder(
                                                                side: BorderSide(
                                                                    color: black(
                                                                            context)
                                                                        .withOpacity(
                                                                            .1))),
                                                            child: const Text(
                                                                "Modifier le prix",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700)))
                                                      ]),
                                                ),
                                              );
                                            });
                                      },
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      color: courses[0]
                                          .element[index]
                                          .produit
                                          .couleur
                                          .withOpacity(.1),
                                      shape: const StadiumBorder(),
                                      child: Center(
                                        child: Row(
                                          children: [
                                            Money(
                                              style: TextStyle(
                                                  color: courses[0]
                                                      .element[index]
                                                      .produit
                                                      .couleur,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 20,
                                                  fontFamily: "Cocogoose"),
                                              price: courses[0]
                                                          .element[index]
                                                          .price !=
                                                      null
                                                  ? courses[0]
                                                          .element[index]
                                                          .price! /
                                                      100
                                                  : courses[0]
                                                          .element[index]
                                                          .poids /
                                                      courses[0]
                                                          .element[index]
                                                          .produit
                                                          .poids *
                                                      courses[0]
                                                          .element[index]
                                                          .produit
                                                          .price /
                                                      100,
                                            ),
                                            courses[0].element[index].price !=
                                                    null
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5.0),
                                                    child: Image.asset(
                                                        "assets/icon/edit.png",
                                                        scale: 15,
                                                        color: courses[0]
                                                            .element[index]
                                                            .produit
                                                            .couleur),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CustomButton(
                                          onPressed: () {
                                            courses[0].element.removeAt(index);
                                            courses[0].update();
                                          },
                                          shape: const StadiumBorder(),
                                          child: Image.asset(
                                              "assets/icon/cancel.png",
                                              scale: 10,
                                              color: black(context)),
                                        ))
                                  ],
                                ),
                              ),
                              courses.length - 1 > index
                                  ? Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 7),
                                      height: 1,
                                      color: black(context).withOpacity(.1))
                                  : Container()
                            ],
                          );
                        })),
                  ),
                  CustomButton(
                      padding: const EdgeInsets.only(
                          left: 10, right: 20, top: 10, bottom: 10),
                      onPressed: () async {
                        Product? prod = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductPage(
                                    choice: true,
                                    user: widget.user,
                                    commerce: widget.commerce,
                                  )),
                        );
                        if (prod != null) {
                          ProduitScan produitScan =
                              ProduitScan(produit: prod, poids: prod.poids);
                          MoneyMaskedTextController poids =
                              MoneyMaskedTextController(
                                  rightSymbol: " ${prod.unite}",
                                  precision: 1,
                                  initialValue: produitScan.poids);
                          // ignore: use_build_context_synchronously
                          showDialog(
                              context: context,
                              builder: (context) {
                                CameraController.instance.pauseDetector();
                                cameraPosition = false;
                                return Dialog(
                                    shadowColor: Colors.transparent,
                                    surfaceTintColor: Colors.transparent,
                                    insetPadding: EdgeInsets.zero,
                                    backgroundColor: Colors.transparent,
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.all(20),
                                        margin: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                            color: white(context),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GalerieElementV2(
                                                  height: 60,
                                                  width: 60,
                                                  idUser: widget.user.id,
                                                  context: context,
                                                  info: Picture(
                                                      darkColor: Colors.black,
                                                      lightColor: Colors.white,
                                                      width: 100,
                                                      height: 100,
                                                      url: prod.url,
                                                      galerie: ""),
                                                  radius: 30),
                                              const SizedBox(height: 20),
                                              Text(
                                                prod.nom,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 50),
                                              SizedBox(
                                                height: 75,
                                                child: FieldText2(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    borderColor: black(context)
                                                        .withOpacity(.1),
                                                    hintText: "Poids",
                                                    controller: poids,
                                                    keyboardType:
                                                        const TextInputType
                                                            .numberWithOptions(
                                                            decimal: false),
                                                    onChanged: (v) {
                                                      produitScan.poids =
                                                          poids.numberValue;
                                                      setState(() {});
                                                    }),
                                              ),
                                              const SizedBox(height: 50),
                                              CustomButton(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  onPressed: () {
                                                    courses[0]
                                                        .element
                                                        .add(produitScan);
                                                    courses[0].update();
                                                    setState(() {});
                                                    CameraController.instance
                                                        .resumeDetector();
                                                    Navigator.pop(context);
                                                  },
                                                  shape: StadiumBorder(
                                                      side: BorderSide(
                                                          color: black(context)
                                                              .withOpacity(
                                                                  .1))),
                                                  child: const Text("Ajouter",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w700)))
                                            ])));
                              });
                        }
                      },
                      shape: StadiumBorder(
                          side: BorderSide(
                              color: black(context).withOpacity(.1))),
                      child: Row(children: [
                        Image.asset("assets/icon/add.png",
                            color: black(context), scale: 10),
                        const SizedBox(
                          width: 15,
                        ),
                        const Text("Ajouter un produit manuellement",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700))
                      ])),
                  const SizedBox(height: 10),
                  CustomButton(
                      color: (adherent != null &&
                                  adherent.solde >= courses[0].montant()
                              ? Colors.green
                              : Colors.red)
                          .withOpacity(.2),
                      padding: const EdgeInsets.only(
                          left: 30, right: 30, top: 15, bottom: 15),
                      onPressed: courses[0].adherent != "" &&
                              courses[0].adherent != " " &&
                              courses[0].element.isNotEmpty
                          ? () async {
                              if (adherent != null &&
                                  adherent.solde >= courses[0].montant()) {
                                courses[0].finish = true;
                                courses[0].date = DateTime.now();
                                courses[0].update();
                                for (var i = 0; i < courses[0].element.length; i++) {
                                  await ConsommationProductService.addOrUpdateConsommationProduct(
                            widget.commerce,
                            (await Categorie.get(courses[0].element[i].produit.categorieId))!,
                            courses[0].element[i].produit,
                           courses[0].date,
                            ConsoProd(
                                id: FirebaseFirestore.instance
                                    .collection("consoProds")
                                    .doc()
                                    .id,
                                livraison: false,
                                date:
                                    courses[0].date,
                                idAdherent: courses[0].adherent
                                    ,
                                quantite: courses[0].element[i].poids));
                                }
                                DocumentReference doc = FirebaseFirestore
                                    .instance
                                    .collection("transactions")
                                    .doc();
                                Transaction2(
                                        adherent: courses[0].adherent,
                                        id: doc.id,
                                        commerce: widget.commerce.id,
                                        date: DateTime.now(),
                                        userId: widget.user.id,
                                        amount: courses[0].montant(),
                                        description: "Courses",
                                        type: TransactionType.debit,
                                        method: "prelevement")
                                    .create();
                                adherent.solde -= courses[0].montant();
                                adherent.update();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    content: Container(
                                        padding: const EdgeInsets.all(10),
                                        margin: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: const Text(
                                            "Opération impossible : l'adhérent doit recharcher son compte",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: "cocogoose",
                                                color: Colors.white,
                                                fontWeight:
                                                    FontWeight.bold)))));
                              }
                            }
                          : null,
                      shape: StadiumBorder(
                          side: BorderSide(
                        color: (adherent != null &&
                                    adherent.solde >= courses[0].montant()
                                ? Colors.green
                                : Colors.red)
                            .withOpacity(.2),
                      )),
                      child: Opacity(
                        opacity: courses[0].adherent != "" &&
                                courses[0].adherent != " " &&
                                courses[0].element.isNotEmpty
                            ? 1
                            : 0.5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Valider",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700)),
                            SizedBox(
                              width: 10,
                            ),
                            Money(
                                price: courses[0].montant() / 100,
                                style: TextStyle(
                                    fontFamily: "Cocogoose",
                                    color: black(context),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      )),
                ]);
              } else {
                if (productScan[index].runtimeType == Product) {
                  Product produit = productScan[index]!;
                  ProduitScan produitScan =
                      ProduitScan(produit: produit, poids: produit.poids);
                  MoneyMaskedTextController poids = MoneyMaskedTextController(
                      rightSymbol: " ${produit.unite}",
                      precision: 1,
                      initialValue: produitScan.poids);
                  return Column(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(height: 10),
                    GalerieElementV2(
                        height: 60,
                        width: 60,
                        idUser: widget.user.id,
                        context: context,
                        info: Picture(
                            darkColor: Colors.black,
                            lightColor: Colors.white,
                            width: 100,
                            height: 100,
                            url: produit.url,
                            galerie: ""),
                        radius: 30),
                    const SizedBox(height: 10),
                    Text(
                      produit.nom,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 73,
                      child: FieldText2(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          borderColor: black(context).withOpacity(.1),
                          hintText: "Poids",
                          controller: poids,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: false),
                          onChanged: (v) {
                            produitScan.poids = poids.numberValue;
                          }),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        onPressed: () {
                          courses[0].element.add(produitScan);
                          courses[0].update();
                          setState(() {});
                          CameraController.instance.resumeDetector();
                          _controller.animateToPage(productScan.length,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.decelerate);
                        },
                        shape: StadiumBorder(
                            side: BorderSide(
                                color: black(context).withOpacity(.1))),
                        child: const Text("Ajouter",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700)))
                  ]);
                } else if (productScan[index].runtimeType == ScanProduct) {
                  ScanProduct product = productScan[index];
                  return Column(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(height: 20),
                    GalerieElementV2(
                        height: 60,
                        width: 60,
                        idUser: widget.user.id,
                        context: context,
                        info: Picture(
                            darkColor: Colors.black,
                            lightColor: Colors.white,
                            width: 100,
                            height: 100,
                            url: product.url,
                            galerie: ""),
                        radius: 30),
                    const SizedBox(height: 20),
                    Text(
                      product.nom,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    !product.exist
                        ? const Text(
                            "Ce produit n'existe pas encore.",
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          )
                        : Container(),
                    SizedBox(height: !product.exist ? 10 : 0),
                    product.exist
                        ? CustomButton(
                            child: const Text("Ajouter"),
                            onPressed: () {
                              CameraController.instance.resumeDetector();
                              cameraPosition = true;
                            },
                          )
                        : Column(
                            children: [
                              CustomButton(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                shape: const StadiumBorder(),
                                color: widget.user.couleur.withOpacity(.1),
                                child: Text(
                                    "Lier ce produit à un produit existant",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: widget.user.couleur,
                                        fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  CameraController.instance.resumeDetector();
                                  cameraPosition = true;
                                  Product? prod = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProductPage(
                                              choice: true,
                                              user: widget.user,
                                              commerce: widget.commerce,
                                            )),
                                  );
                                  if (prod != null) {
                                    if (!prod.barcode.contains(product.id)) {
                                      prod.barcode.add(product.id);
                                    }
                                    prod.update();
                                    productScan[index] = prod;
                                    setState(() {});
                                  }
                                },
                              ),
                              CustomButton(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                shape: const StadiumBorder(),
                                color: widget.user.couleur.withOpacity(.1),
                                child: Text(
                                    "Ajouter ce produit à l'application",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: widget.user.couleur,
                                        fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  CameraController.instance.resumeDetector();
                                  Product? prod = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NewProductPage(
                                            scanProduct: product,
                                            user: widget.user,
                                            commerce: widget.commerce)),
                                  );
                                  print(prod);
                                  if (prod != null) {
                                    productScan[index] = prod;
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                  ]);
                } else {
                  return Container();
                }
              }
            }));
  }

  Future getProduct(String id) async {
    Product? product = await Product.getByBarcode(id);
    if (product != null) {
      return product;
    }
    return ScanProduct.fromJson(jsonDecode((await http.get(Uri.parse(
            'https://world.openfoodfacts.net/api/v2/product/$id?fields=product_name,image_front_url,_id,_keywords,categories')))
        .body)["product"]);
  }
}
