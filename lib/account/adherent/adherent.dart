import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:entrema/classes/adherent.dart';
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
import 'package:entrema/widget/money.dart';
import 'package:entrema/widget/pdp.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import '../../widget/FieldText2.dart';

class AdherentPage extends StatefulWidget {
  const AdherentPage(
      {super.key,
      required this.user,
      required this.commerce,
      this.choice = false});
  final Commerce commerce;
  final User user;
  final bool choice;
  @override
  State<AdherentPage> createState() => _AdherentPageState();
}

class _AdherentPageState extends State<AdherentPage> {
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
                            title: "Adhérent.e.s",
                          ),
                          !widget.choice ? parametres() : Container(),
                          listeCategories(),
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

  void settingsParam() {}

  Widget parametres() {
    List<Map> settingsItem = [
      {
        "nom": "Créer un.e adhérent.e",
        "icon": "add",
        "onPressed": () {
          pushPage(context,
              NewAdherentPage(user: widget.user, commerce: widget.commerce));
        }
      },
      {
        "nom": "Supprimer un.e adhérent.e",
        "icon": "cancel",
        "onPressed": () async {
          Adherent? adherentTemp = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AdherentPage(
                      choice: true,
                      user: widget.user,
                      commerce: widget.commerce,
                    )),
          );
          if (adherentTemp != null) {
            // ignore: use_build_context_synchronously
            if ((await editDialog(context, "Annuler", "Supprimer",
                    "Souhaitez-vous supprimer ${adherentTemp.prenom} ${adherentTemp.nom} ?")) ==
                true) {
              adherentTemp.delete();
            }
          }
        }
      },
      {
        "nom": "Importer des adhérent.e.s",
        "icon": "verified",
        "onPressed": () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result != null) {
            File file = File(result.files.single.path!);
            List<List> fields = await file
                .openRead()
                .transform(utf8.decoder)
                .transform(const CsvToListConverter())
                .toList();
            List<List<dynamic>> newFields = fields
                .map((e) => e
                    .map((f) => f.runtimeType == String
                        ? f.contains("€")
                            ? (double.parse(f
                                        .toString()
                                        .substring(0, f.length - 1)
                                        .replaceAll(",", ".")) *
                                    100)
                                .round()
                            : f.contains("TRUE")
                                ? true
                                : f.contains("FALSE")
                                    ? false
                                    : f.trim()
                        : f)
                    .toList())
                .toList();
            List<Adherent> adherents = [];
            if (newFields.length > 3) {
              for (var i = 3; i < newFields.length; i++) {
                List<Map<String, dynamic>> data = [];
                for (var j = 5; j < newFields[2].length; j++) {
                  data.add({"nom": newFields[2][j], "value": newFields[i][j]});
                }
                /*final adherentsQuery = (await FirebaseFirestore.instance
                        .collection("adherents")
                        .where("customId",
                            isEqualTo: newFields[i][3].toString())
                        .limit(1)
                        .get())
                    .docs;
                print(newFields[i][1].toString());*/
                adherents.add(Adherent(
                    //updateB: adherentsQuery.isNotEmpty,
                    commerce: widget.commerce.id,
                    solde: newFields[i][4],
                    id: /*adherentsQuery.isNotEmpty
                        ? adherentsQuery.first.id
                        : */
                        FirebaseFirestore.instance
                            .collection("adherents")
                            .doc()
                            .id,
                    lastUpdate: DateTime.now(),
                    customId: newFields[i][3].toString(),
                    dateCreation: DateTime.now(),
                    prenom: newFields[i][2].toString(),
                    bloque: false,
                    nom: newFields[i][1].toString(),
                    searchTerm: [],
                    data: data));
              }
              // ignore: use_build_context_synchronously
              showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return Material(
                      color: Colors.transparent,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 2 / 3,
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 20),
                        decoration: BoxDecoration(
                            color: white(context),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20))),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Êtes-vous sûr de vouloir ajouter ${adherents.length} nouvelle${adherents.length > 1 ? "s" : ""}${adherents.length > 1 ? ".aux" : ".au"} adhérent.e${adherents.length > 1 ? ".s" : ""} ?",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: adherents.length,
                                  itemBuilder: (context, index) {
                                    Adherent adherent = adherents[index];
                                    return Column(
                                      children: [
                                        adherent.show(context,
                                            onPressed: widget.choice
                                                ? () {
                                                    Navigator.pop(
                                                        context, adherent);
                                                  }
                                                : () async {
                                                    Adherent? adherentTemp =
                                                        await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              NewAdherentPage(
                                                                  nouveau: true,
                                                                  user:
                                                                      widget
                                                                          .user,
                                                                  commerce: widget
                                                                      .commerce,
                                                                  adherent:
                                                                      adherent)),
                                                    );
                                                    if (adherentTemp != null) {
                                                      adherents[index] =
                                                          adherentTemp;
                                                    }
                                                  },
                                            color: widget.user.couleur),
                                        adherents.length - 1 > index
                                            ? Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2),
                                                height: 1,
                                                color: black(context)
                                                    .withOpacity(.1),
                                              )
                                            : Container()
                                      ],
                                    );
                                  }),
                            ),
                            const SizedBox(height: 20),
                            CustomButton(
                                splashColor: black(context).withOpacity(.1),
                                highlightColor: black(context).withOpacity(.1),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                color: white(context),
                                shape: StadiumBorder(
                                    side: BorderSide(
                                        color: black(context).withOpacity(.1))),
                                onPressed: () async {
                                  for (var i = 0; i < adherents.length; i++) {
                                    await adherents[i].create();
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text("Valider",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)))
                          ],
                        ),
                      ),
                    );
                  });
            }
          } else {
            // User canceled the picker
          }
        }
      },
      {"nom": "Modifier les données", "icon": "edit", "onPressed": () {}},
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
        settingsParam,
        context);
  }

  TextEditingController controller = TextEditingController();

  Widget listeCategories() {
    Widget body = StreamBuilder<List<Adherent>>(
        stream: Adherent.streamAdherents(widget.commerce.id,
            searchTerm: controller.text.isNotEmpty ? controller.text : null,
            limit: 100),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty && controller.text.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Aucun adhérent trouvé",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              children: [
                SizedBox(
                  height: 75,
                  child: FieldText2(
                      borderColor: black(context).withOpacity(.1),
                      hintText2: "Code | Nom | Prénom",
                      controller: controller,
                      onChanged: (v) {
                        setState(() {});
                      }),
                ),
                ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      Adherent adherent = snapshot.data![index];
                      return Column(
                        children: [
                          adherent.show(context,
                              onPressed: widget.choice
                                  ? () {
                                      Navigator.pop(context, adherent);
                                    }
                                  : () {
                                      pushPage(
                                          context,
                                          NewAdherentPage(
                                              user: widget.user,
                                              commerce: widget.commerce,
                                              adherent: adherent));
                                    },
                              color: widget.user.couleur),
                          snapshot.data!.length - 1 > index
                              ? Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  height: 1,
                                  color: black(context).withOpacity(.1),
                                )
                              : Container()
                        ],
                      );
                    }),
              ],
            );
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

class NewAdherentPage extends StatefulWidget {
  const NewAdherentPage(
      {super.key,
      required this.user,
      required this.commerce,
      this.adherent,
      this.nouveau = false});
  final User user;
  final bool nouveau;
  final Adherent? adherent;
  final Commerce commerce;

  @override
  State<NewAdherentPage> createState() => _NewAdherentPageState();
}

class _NewAdherentPageState extends State<NewAdherentPage> {
  TextEditingController nom = TextEditingController();
  TextEditingController prenom = TextEditingController();
  TextEditingController identifiant = TextEditingController();
  MoneyMaskedTextController solde = MoneyMaskedTextController(rightSymbol: '€');
  late Adherent adherent;
  List<TextEditingController?> dataController = [];

  @override
  void initState() {
    DocumentReference doc =
        FirebaseFirestore.instance.collection("adherents").doc();
    adherent = Adherent(
      lastUpdate: DateTime.now(),
      customId: "",
      solde: 0,
      dateCreation: DateTime.now(),
      prenom: "",
      bloque: false,
      searchTerm: [],
      data: [],
      id: doc.id,
      nom: "",
      commerce: widget.commerce.id,
    );
    if (widget.adherent != null) {
      adherent = widget.adherent!;
    }
    for (var i = 0; i < widget.commerce.dataAdherent.length; i++) {
      if (adherent.data
          .where((element) =>
              element.containsValue(widget.commerce.dataAdherent[i]["nom"]))
          .isEmpty) {
        adherent.data.add({
          "nom": widget.commerce.dataAdherent[i]["nom"],
          "value": widget.commerce.dataAdherent[i]["default"],
        });
      }
      dataController.add(widget.commerce.dataAdherent[i]["type"] == "texte"
          ? TextEditingController(
              text: adherent.data
                      .where((element) => element.containsValue(
                          widget.commerce.dataAdherent[i]["nom"]))
                      .isNotEmpty
                  ? adherent.data.firstWhere((element) => element.containsValue(
                      widget.commerce.dataAdherent[i]["nom"]))["value"]
                  : null)
          : null);
    }
    nom.text = adherent.nom;
    prenom.text = adherent.prenom;
    identifiant.text = adherent.customId;
    solde.updateValue(adherent.solde / 100);
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
                            title: "Nouvel.le adhérent.e",
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
                            disabledColor: white(context),
                            color: white(context),
                            splashColor: Colors.green.withOpacity(.1),
                            highlightColor: Colors.green.withOpacity(.1),
                            onPressed: adherent.nom.length > 2 &&
                                    adherent.prenom.length > 2 &&
                                    identifiant.text.isNotEmpty
                                ? (widget.adherent != null
                                    ? widget.nouveau
                                        ? () {
                                            adherent.lastUpdate =
                                                DateTime.now();
                                            Navigator.pop(context, adherent);
                                          }
                                        : () {
                                            adherent.lastUpdate =
                                                DateTime.now();
                                            adherent.update();
                                            Navigator.pop(context);
                                          }
                                    : () {
                                        adherent.lastUpdate = DateTime.now();
                                        adherent.create();
                                        Navigator.pop(context);
                                      })
                                : null,
                            shape: StadiumBorder(
                                side: BorderSide(
                                    width: 2,
                                    color: Colors.green.withOpacity(.3))),
                            child: Text(
                                widget.adherent != null
                                    ? widget.nouveau
                                        ? "Valider"
                                        : "Enregistrer"
                                    : "Valider",
                                style: TextStyle(
                                    color: black(context).withOpacity(
                                        adherent.nom.length > 2 &&
                                                adherent.prenom.length > 2 &&
                                                identifiant.text.isNotEmpty
                                            ? 1
                                            : 0.2),
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
                    adherent.nom = v!;
                    setState(() {});
                  }),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 75,
              child: FieldText2(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  borderColor: black(context).withOpacity(.1),
                  hintText: "Prénom",
                  hintText2: "",
                  controller: prenom,
                  onChanged: (v) {
                    if (v != null) {
                      adherent.prenom = v;
                      setState(() {});
                    }
                  }),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 75,
              child: FieldText2(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  borderColor: black(context).withOpacity(.1),
                  hintText: "Identifiant",
                  hintText2: "",
                  controller: identifiant,
                  onChanged: (v) {
                    if (v != null && v.isNotEmpty) {
                      adherent.customId = v;
                    }
                    setState(() {});
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
            const SizedBox(height: 15),
            FieldText2(
                hintText: "Solde",
                hintText2: "Optionnel",
                fontSize: 13,
                fontWeight: FontWeight.w700,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                borderColor: black(context).withOpacity(.1),
                controller: solde,
                onChanged: (v) {
                  adherent.solde = (solde.numberValue * 100).round();
                  setState(() {});
                }),
            ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.commerce.dataAdherent.length,
                itemBuilder: (context, index) {
                  switch (widget.commerce.dataAdherent[index]["type"]) {
                    case "boolean":
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3.0),
                              child: Text(
                                  widget.commerce.dataAdherent[index]["nom"],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900)),
                            ),
                            CupertinoSwitch(
                                value: adherent.data.firstWhere((element) =>
                                    element["nom"] ==
                                    widget.commerce.dataAdherent[index]
                                        ["nom"])["value"],
                                onChanged: (v) {
                                  setState(() {
                                    adherent.data.firstWhere((element) =>
                                        element["nom"] ==
                                        widget.commerce.dataAdherent[index]
                                            ["nom"])["value"] = !adherent.data
                                        .firstWhere((element) =>
                                            element["nom"] ==
                                            widget.commerce.dataAdherent[index]
                                                ["nom"])["value"];
                                  });
                                })
                          ],
                        ),
                      );
                    case "texte":
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: FieldText2(
                            hintText: widget.commerce.dataAdherent[index]
                                ["nom"],
                            hintText2: widget.commerce.dataAdherent[index]
                                ["nom"],
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            borderColor: black(context).withOpacity(.1),
                            controller: dataController[index]!,
                            onChanged: (v) {
                              setState(() {
                                adherent.data.firstWhere((element) =>
                                    element["nom"] ==
                                    widget.commerce.dataAdherent[index]
                                        ["nom"])["value"] = v;
                              });
                            }),
                      );
                    default:
                      return Container(child: Text("error"));
                  }
                })
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
