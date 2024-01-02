import 'package:entrema/account/adherent/adherent.dart';
import 'package:entrema/account/categorie/categorie.dart';
import 'package:entrema/account/equipe.dart/equipe.dart';
import 'package:entrema/account/produit/produit.dart';
import 'package:entrema/account/stock/stock.dart';
import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/user.dart';
import 'package:entrema/color.dart';
import 'package:entrema/functions/function.dart';
import 'package:entrema/home/home.dart';
import 'package:entrema/home/scan/scanPage.dart';
import 'package:entrema/widget/bottom_bar.dart';
import 'package:entrema/widget/box.dart';
import 'package:entrema/widget/boxBox.dart';
import 'package:entrema/widget/button.dart';
import 'package:entrema/widget/pdp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.user, required this.commerce});
  final Commerce commerce;
  final User user;
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<Map> settings = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Theme.of(context).primaryColor,
        child: Scaffold(
            backgroundColor: Colors.blueGrey.withOpacity(0.1),
            body: SizedBox.expand(
                child: Stack(
              children: [
                SafeArea(
                    child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Center(
                            child: Hero(
                                tag: "${widget.user.id}account",
                                child: Pdp(
                                    user: widget.user,
                                    height: 150,
                                    radius: 75))),
                        Name(),
                        Commerce(),
                        const SizedBox(height: 100),
                      ]),
                )),
                Positioned(
                    bottom: 0,
                    child: BottomBar(
                      index: 1,
                      user: widget.user,
                      onPressed: (v) {
                        pushPage(context, Home(user: widget.user, index: v));
                      },
                    ))
              ],
            ))));
  }

  void Settings() {}

  Widget Name() {
    Widget body = SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          const Text("Responsable informatique",
              style: TextStyle(
                  fontFamily: "Cocogoose",
                  fontWeight: FontWeight.w900,
                  fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            widget.user.email,
            style: TextStyle(
                fontFamily: "Cocogoose",
                fontWeight: FontWeight.w100,
                color: black(context).withOpacity(.5),
                fontSize: 12),
          )
        ],
      ),
    );
    return Box(
        RichText(
          text: TextSpan(
            text: "${widget.user.prenom} ",
            style: TextStyle(
                fontFamily: "Cocogoose",
                color: black(context),
                fontWeight: FontWeight.w700,
                fontSize: 20),
            children: <TextSpan>[
              TextSpan(
                  text: widget.user.nom,
                  style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        body,
        Settings,
        context);
  }

  Widget Commerce() {
    List<Map> settingsItem = [
      {
        "nom": "Équipe",
        "icon": "equipe",
        "onPressed": () {
          pushPage(context,
              EquipePage(user: widget.user, commerce: widget.commerce));
        }
      },
      {
        "nom": "Stocks",
        "icon": "product",
        "onPressed": () {
          pushPage(
              context, StockPage(user: widget.user, commerce: widget.commerce));
        }
      },
      {
        "nom": "Catégories",
        "icon": "page",
        "onPressed": () {
          pushPage(context,
              CategoriePage(user: widget.user, commerce: widget.commerce));
        }
      },
      {
        "nom": "Produits",
        "icon": "file",
        "onPressed": () {
          pushPage(context,
              ProductPage(user: widget.user, commerce: widget.commerce));
        }
      },
      {
        "nom": "Adhérent.e.s",
        "icon": "profile",
        "onPressed": () {
          pushPage(context,
              AdherentPage(user: widget.user, commerce: widget.commerce));
        }
      },
      {"nom": "Trésorerie", "icon": "treso", "onPressed": () {}},
      {"nom": "Statistiques", "icon": "stats", "onPressed": () {}},
      {"nom": "Promotions", "icon": "cadeau", "onPressed": () {}},
      {"nom": "Alertes", "icon": "annonce", "onPressed": () {}}
    ];
    Widget body = SizedBox(
        width: double.infinity,
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: settingsItem.length,
            itemBuilder: (context, index) {
              return CustomButton(
                padding: const EdgeInsets.all(10),
                onPressed: settingsItem[index]["onPressed"],
                shape: StadiumBorder(
                    side: BorderSide(color: black(context).withOpacity(.1))),
                child: Row(children: [
                  Image.asset("assets/icon/${settingsItem[index]["icon"]}.png",
                      color: black(context), scale: 10),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(settingsItem[index]["nom"],
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700))
                ]),
              );
            }));
    return Box(
        Text(
          widget.commerce.nom,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        body,
        Settings,
        context);
  }
}
