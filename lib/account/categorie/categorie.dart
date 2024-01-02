import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/classes/categorie.dart';
import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/user.dart';
import 'package:entrema/color.dart';
import 'package:entrema/functions/function.dart';
import 'package:entrema/home/home.dart';
import 'package:entrema/home/scan/scanPage.dart';
import 'package:entrema/widget/FieldText.dart';
import 'package:entrema/widget/Loader.dart';
import 'package:entrema/widget/appbar.dart';
import 'package:entrema/widget/bottom_bar.dart';
import 'package:entrema/widget/box.dart';
import 'package:entrema/widget/boxBox.dart';
import 'package:entrema/widget/button.dart';
import 'package:entrema/widget/pdp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import '../../widget/FieldText2.dart';

class CategoriePage extends StatefulWidget {
  const CategoriePage(
      {super.key,
      required this.user,
      required this.commerce,
      this.choice = false});
  final Commerce commerce;
  final User user;
  final bool choice;
  @override
  State<CategoriePage> createState() => _CategoriePageState();
}

class _CategoriePageState extends State<CategoriePage> {
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
                          const CustomAppBar(
                            title: "Catégories",
                          ),
                          !widget.choice ? Parametres() : Container(),
                          ListeCategories(),
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
              ),
            )));
  }

  void Settings() {}

  Widget Parametres() {
    List<Map> settingsItem = [
      {
        "nom": "Créer une catégorie",
        "icon": "add",
        "onPressed": () {
          pushPage(context,
              NewCategoriePage(user: widget.user, commerce: widget.commerce));
        }
      },
      {"nom": "Supprimer une catégorie", "icon": "cancel", "onPressed": () {}},
      {"nom": "Favoris", "icon": "star", "onPressed": () {}},
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
        const Text("Paramètres",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        body,
        Settings,
        context);
  }

  Widget ListeCategories() {
    Widget body = StreamBuilder<List<Categorie>>(
        stream: Categorie.streamCategories(widget.commerce.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Aucune catégorie trouvée",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Categorie categorie = snapshot.data![index];
                  return CustomButton(
                    padding: const EdgeInsets.only(left: 12),
                    color: lighten(categorie.couleur.withOpacity(.05), 0.3),
                    onPressed: widget.choice
                        ? () {
                            Navigator.pop(context, categorie);
                          }
                        : () {
                            pushPage(
                                context,
                                NewCategoriePage(
                                    user: widget.user,
                                    commerce: widget.commerce,
                                    categorie: categorie));
                          },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    child: Row(
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                              color: categorie.couleur,
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        SizedBox(width: 10),
                        Text(categorie.nom)
                      ],
                    ),
                  );
                });
          } else {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Loader(
                  color: black(context),
                ),
              ),
            );
          }
        });
    return BoxBox(body, context);
  }
}

class NewCategoriePage extends StatefulWidget {
  const NewCategoriePage(
      {super.key, required this.user, required this.commerce, this.categorie});
  final User user;
  final Categorie? categorie;
  final Commerce commerce;

  @override
  State<NewCategoriePage> createState() => _NewCategoriePageState();
}

class _NewCategoriePageState extends State<NewCategoriePage> {
  TextEditingController nom = TextEditingController();
  TextEditingController keyword = TextEditingController();
  MoneyMaskedTextController prix = MoneyMaskedTextController(rightSymbol: '€');
  late Categorie categorie;
  List unites = ["L", "cL", "mL", "kg", "g", "mg"];
  late Color color;

  int uniteIndex = 0;

  @override
  void initState() {
    DocumentReference doc =
        FirebaseFirestore.instance.collection("categories").doc();
    categorie = Categorie(
        id: doc.id,
        nom: "",
        couleur: widget.user.couleur,
        commerce: widget.commerce.id,
        keywords: [],
        price: 0,
        unite: "L",
        options: []);
    if (widget.categorie != null) {
      categorie = widget.categorie!;
    }
    nom.text = categorie.nom;
    uniteIndex = unites.indexOf(categorie.unite);
    if (uniteIndex == -1) {
      uniteIndex = 0;
    }
    color = categorie.couleur;
    keyword.text = categorie.keywords.join(", ");
    if (keyword.text.isNotEmpty) {
      keyword.text.substring(0, keyword.text.length - 2);
    }
    prix.updateValue(categorie.price / 100);

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
                alignment: Alignment.topCenter,
                children: [
                  SafeArea(
                      child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          CustomAppBar(
                            title: "Nouvelle catégorie",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Description(),
                          Parametres(),
                          const SizedBox(height: 100),
                        ]),
                  )),
                  Positioned(
                      bottom: 30,
                      child: SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width - 60,
                        child: CustomButton(
                            color: white(context),
                            splashColor: Colors.green.withOpacity(.1),
                            highlightColor: Colors.green.withOpacity(.1),
                            onPressed: categorie.nom.length > 2
                                ? (widget.categorie != null
                                    ? () {
                                        categorie.update();
                                        Navigator.pop(context);
                                      }
                                    : () {
                                        categorie.create();
                                        Navigator.pop(context);
                                      })
                                : null,
                            shape: StadiumBorder(
                                side: BorderSide(
                                    width: 2,
                                    color: Colors.green.withOpacity(.3))),
                            child: Text(
                                widget.categorie != null
                                    ? "Enregistrer"
                                    : "Valider",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700))),
                      ))
                ],
              ),
            )));
  }

  Widget Description() {
    Widget body = SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              height: 75,
              child: FieldText2(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  borderColor: black(context).withOpacity(.1),
                  hintText: "Nom",
                  controller: nom,
                  onChanged: (v) {
                    categorie.nom = v!;
                  }),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 75,
              child: FieldText2(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  borderColor: black(context).withOpacity(.1),
                  hintText: "Mots-clés",
                  hintText2: "Ex : Fraise, rouge, pépins, fruit...",
                  controller: keyword,
                  onChanged: (v) {
                    List<String> keywords = keyword.text.split(",");
                    for (var i = 0; i < keywords.length; i++) {
                      if (keywords[i].startsWith(" ")) {
                        keywords[i] = keywords[i].substring(1);
                      }
                    }
                    categorie.keywords = keywords;
                  }),
            )
          ],
        ));
    return Box(
        const Text("Description",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        body,
        null,
        context);
  }

  Widget Parametres() {
    Widget body = SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 3.0),
              child: Text("Unité",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
            ),
            SizedBox(
              height: 35,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: unites.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CustomButton(
                        color: uniteIndex == index
                            ? widget.user.couleur.withOpacity(.2)
                            : null,
                        shape: StadiumBorder(
                            side: BorderSide(
                                width: uniteIndex == index ? 2 : 1,
                                color: uniteIndex == index
                                    ? widget.user.couleur.withOpacity(.3)
                                    : black(context).withOpacity(.1))),
                        onPressed: () {
                          setState(() {
                            uniteIndex = index;
                            categorie.unite = unites[index];
                          });
                        },
                        child: Text(unites[index])),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            FieldText2(
                hintText: "Prix (optionnel)",
                hintText2: "Optionnel",
                fontSize: 13,
                fontWeight: FontWeight.w700,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                borderColor: black(context).withOpacity(.1),
                controller: prix,
                onChanged: (v) {
                  categorie.price = (prix.numberValue * 100).round();
                }),
            const SizedBox(height: 15),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 3.0),
                  child: Text("Couleur",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: CustomButton(
                      color: categorie.couleur,
                      shape: StadiumBorder(
                          side: BorderSide(
                              color: black(context).withOpacity(.2))),
                      onPressed: () async {
                        categorie.couleur = await chooseColor(context);
                        setState(() {});
                      },
                      child: Container()),
                ),
              ],
            ),
          ],
        ));
    return Box(
        const Text("Paramètres",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        body,
        null,
        context);
  }
}
