import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/user.dart';
import 'package:entrema/color.dart';
import 'package:entrema/widget/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Stock extends StatefulWidget {
  const Stock({super.key, required this.commerce, required this.user});
  final User user;
  final Commerce commerce;

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  List<Map> settings = [];
  @override
  void initState() {
    settings = [
      {
        "nom": "Historique des livraisons",
        "id": "historiqueLivraison",
        "icon": "historique",
        "onPressed": () {}
      },
      {
        "nom": "Nouvelle livraison",
        "id": "newLivraison",
        "icon": "add2",
        "onPressed": () {}
      },
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Theme.of(context).primaryColor,
        child: Scaffold(
            backgroundColor: Colors.blueGrey.withOpacity(0.1),
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      const SizedBox(height: 100),
                      Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          height: 200,
                          decoration: BoxDecoration(
                              color: white(context),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Image.asset("assets/icon/receive.png",
                                      scale: 10, color: black(context)),
                                  const SizedBox(width: 7),
                                  const Text("Dernière livraison",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: "Nexa",
                                          fontWeight: FontWeight.bold)),
                                  Expanded(child: Container()),
                                  SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CustomButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      padding: EdgeInsets.zero,
                                      onPressed: () {},
                                      child: Image.asset("assets/icon/edit.png",
                                          scale: 10, color: black(context)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: widget.user.couleur
                                              .withOpacity(.1),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Row(
                                        children: [
                                          Image.asset("assets/icon/place.png",
                                              scale: 12,
                                              color: widget.user.couleur),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text("Maison des élèves",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: "Nexa",
                                                  color: widget.user.couleur,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: widget.user.couleur
                                              .withOpacity(.1),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                              "assets/icon/calendar2.png",
                                              scale: 12,
                                              color: widget.user.couleur),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text("12 Sept.",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: "Nexa",
                                                  color: widget.user.couleur,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ))
                                ],
                              )
                            ],
                          )),
                      const SizedBox(height: 50),
                      Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: settings.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: CustomButton(
                                    padding: const EdgeInsets.all(15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: white(context),
                                    splashColor:
                                        widget.user.couleur.withOpacity(.1),
                                    highlightColor:
                                        widget.user.couleur.withOpacity(.1),
                                    onPressed: settings[index]["onPressed"],
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          "assets/icon/${settings[index]["icon"]}.png",
                                          color: black(context),
                                          scale: 10,
                                        ),
                                        SizedBox(width: 10),
                                        Text(settings[index]["nom"],
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Nexa"))
                                      ],
                                    )),
                              );
                            }),
                      ),
                    ])))));
  }
}
