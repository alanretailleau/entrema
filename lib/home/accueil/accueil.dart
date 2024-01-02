import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/user.dart';
import 'package:entrema/color.dart';
import 'package:entrema/widget/bottom_bar.dart';
import 'package:entrema/widget/box.dart';
import 'package:entrema/widget/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key, required this.user, required this.commerce});
  final Commerce commerce;
  final User user;
  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
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
            body: SafeArea(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const SizedBox(height: 30),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: Text(
                      "Tableau de bord",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 0),
                    child: Text(
                      "État des stocks",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: black(context).withOpacity(.5)),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  KPI(),
                  EvolutionData(),
                  LastCommande()
                ]))));
  }

  void SettingsKPI() {}

  Widget KPI() {
    return Box(
        Text("KPI",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        Container(),
        SettingsKPI,
        context);
  }

  Widget EvolutionData() {
    return Box(
        Text("Évolution Data",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        Container(),
        SettingsKPI,
        context);
  }

  Widget LastCommande() {
    return Box(
        Text("Dernière commande",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        Container(),
        SettingsKPI,
        context);
  }
}
