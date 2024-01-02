import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/classes/categorie.dart';
import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/role.dart';
import 'package:entrema/classes/team.dart';
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

class SearchPeoplePage extends StatefulWidget {
  const SearchPeoplePage(
      {super.key,
      required this.user,
      required this.commerce,
      this.choice = false});
  final Commerce commerce;
  final User user;
  final bool choice;
  @override
  State<SearchPeoplePage> createState() => _SearchPeoplePageState();
}

class _SearchPeoplePageState extends State<SearchPeoplePage> {
  List<Map> settings = [];
  late Commerce commerce;
  List<bool> expanded = [];

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    commerce = widget.commerce;
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
                            title: "Rechercher",
                          ),
                          Parametres(),
                          listeUser(),
                          const SizedBox(height: 100),
                        ]),
                  )),
                ],
              ),
            )));
  }

  void Settings() {}

  Widget Parametres() {
    Widget body = SizedBox(
        width: double.infinity,
        child: FieldText2(
            borderColor: black(context).withOpacity(.1),
            hintText: "Recherche",
            hintText2: "Prénom | Nom",
            controller: controller,
            onChanged: (v) {
              setState(() {});
            }));
    return BoxBox(body, context);
  }

  Widget listeUser() {
    Widget body = StreamBuilder<List<User>>(
        stream: User.streamUsers(controller.text),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          print("yo");
          return ListView.builder(
              itemCount: snapshot.data!.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                User user = snapshot.data![index];
                return CustomButton(
                  padding: const EdgeInsets.all(5),
                  color: lighten(user.couleur.withOpacity(.05), 0.3),
                  onPressed: !widget.choice
                      ? () {}
                      : () {
                          Navigator.pop(context, user);
                        },
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: user.couleur.withOpacity(.1)),
                      borderRadius: BorderRadius.circular(100)),
                  child: Row(
                    children: [
                      Pdp(user: user, height: 30, radius: 15),
                      SizedBox(width: 10),
                      Text("${user.prenom} ${user.nom}")
                    ],
                  ),
                );
              });
        });

    return BoxBox(controller.text.length > 2 ? body : Container(), context);
  }
}

class NewRolePage extends StatefulWidget {
  const NewRolePage(
      {super.key, required this.user, required this.commerce, this.role});
  final User user;
  final Role? role;
  final Commerce commerce;

  @override
  State<NewRolePage> createState() => _NewCategoriePageState();
}

class _NewCategoriePageState extends State<NewRolePage> {
  TextEditingController nom = TextEditingController();
  late Role role;

  List<bool> roleIndex = [];
  List<OverlayPortalController> controllers = [];

  @override
  void initState() {
    for (var i = 0; i < Autorisation.values.length; i++) {
      roleIndex.add(false);
      controllers.add(OverlayPortalController());
    }
    DocumentReference doc =
        FirebaseFirestore.instance.collection("roles").doc();
    role = Role(id: doc.id, nom: "", autorisations: []);
    if (widget.role != null) {
      role = widget.role!;
    }
    nom.text = role.nom;

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
                            title: "Nouveau rôle",
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
                            onPressed: role.nom.length > 2
                                ? (widget.role != null
                                    ? () {
                                        role.update();
                                        Navigator.pop(context, true);
                                      }
                                    : () {
                                        role.create(widget.commerce);
                                        Navigator.pop(context, true);
                                      })
                                : null,
                            shape: StadiumBorder(
                                side: BorderSide(
                                    width: 2,
                                    color: Colors.green.withOpacity(.3))),
                            child: Text(
                                widget.role != null ? "Enregistrer" : "Valider",
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
                    role.nom = v!;
                  }),
            ),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 3.0),
            child: Text("Autorisations",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          ),
          SizedBox(
            width: double.infinity,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: Autorisation.values.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: CustomButton(
                        color: roleIndex[index]
                            ? widget.user.couleur.withOpacity(.2)
                            : null,
                        shape: StadiumBorder(
                            side: BorderSide(
                                width: roleIndex[index] ? 2 : 1,
                                color: roleIndex[index]
                                    ? widget.user.couleur.withOpacity(.3)
                                    : black(context).withOpacity(.1))),
                        onPressed: () {
                          setState(() {
                            roleIndex[index] = !roleIndex[index];
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(Autorisation.values[index].nom,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: roleIndex[index]
                                          ? FontWeight.bold
                                          : null)),
                            ),
                            SizedBox(
                                height: 30,
                                width: 30,
                                child: CustomButton(
                                  shape: const StadiumBorder(),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    controllers[index].toggle();
                                    Future.delayed(const Duration(seconds: 5),
                                        () {
                                      controllers[index].hide();
                                    });
                                  },
                                  child: OverlayPortal(
                                      controller: controllers[index],
                                      overlayChildBuilder:
                                          (BuildContext context) {
                                        return Positioned(
                                            bottom: 50,
                                            left: 20,
                                            child: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    40,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  constraints:
                                                      const BoxConstraints(
                                                          minHeight: 50),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: black(context)
                                                              .withOpacity(.1),
                                                          spreadRadius: 1,
                                                          offset: const Offset(
                                                              0, 10),
                                                          blurRadius: 10)
                                                    ],
                                                    color: white(context),
                                                  ),
                                                  child: Text(
                                                    Autorisation.values[index]
                                                        .description,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )));
                                      },
                                      child: Image.asset(
                                        "assets/icon/info.png",
                                        scale: 10,
                                        color: black(context),
                                      )),
                                ))
                          ],
                        )),
                  ),
                );
              },
            ),
          ),
        ]));
    return Box(
        const Text("Paramètres",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        body,
        null,
        context);
  }
}
