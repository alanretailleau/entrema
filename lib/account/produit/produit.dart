import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/account/categorie/categorie.dart';
import 'package:entrema/classes/categorie.dart';
import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/product.dart';
import 'package:entrema/classes/scanProduct.dart';
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
import 'package:image_picker/image_picker.dart';
import '../../widget/FieldText2.dart';

class ProductPage extends StatefulWidget {
  const ProductPage(
      {super.key,
      required this.user,
      required this.commerce,
      this.choice = false});
  final Commerce commerce;
  final bool choice;
  final User user;
  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Map> settings = [];

  List<bool> expanded = [];

  @override
  void initState() {
    for (var i = 0; i < 1000; i++) {
      expanded.add(false);
    }
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
                            title: "Produits",
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
        "nom": "Créer un produit",
        "icon": "add",
        "onPressed": () {
          pushPage(context,
              NewProductPage(user: widget.user, commerce: widget.commerce));
        }
      },
      {"nom": "Supprimer un produit", "icon": "cancel", "onPressed": () {}},
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
            return ExpansionPanelList(
              elevation: 0,
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  expanded[index] = isExpanded;
                });
              },
              children:
                  snapshot.data!.map<ExpansionPanel>((Categorie categorie) {
                return ExpansionPanel(
                  backgroundColor: white(context),
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Row(
                      children: [
                        CustomButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          color: categorie.couleur.withOpacity(.1),
                          shape: const StadiumBorder(),
                          onPressed: !widget.choice
                              ? () {
                                  pushPage(
                                      context,
                                      NewCategoriePage(
                                        user: widget.user,
                                        commerce: widget.commerce,
                                        categorie: categorie,
                                      ));
                                }
                              : () {},
                          child: Row(
                            children: [
                              Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                    color: categorie.couleur,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              const SizedBox(width: 10),
                              Text(categorie.nom)
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  body: StreamBuilder(
                      stream: Product.streamProducts(categorie.id),
                      builder: (context, snapshot2) {
                        if (snapshot2.hasData) {
                          return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: snapshot2.data!.length + 1,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                if (index == snapshot2.data!.length) {
                                  return SizedBox(
                                    height: 40,
                                    child: CustomButton(
                                        shape: StadiumBorder(
                                            side: BorderSide(
                                                color: black(context)
                                                    .withOpacity(.1))),
                                        onPressed: !widget.choice
                                            ? () {
                                                pushPage(
                                                    context,
                                                    NewProductPage(
                                                      user: widget.user,
                                                      commerce: widget.commerce,
                                                      categorie: categorie,
                                                    ));
                                              }
                                            : () {},
                                        child: Text("Nouveau produit")),
                                  );
                                }
                                Product produit = snapshot2.data![index];
                                return CustomButton(
                                  padding: const EdgeInsets.all(5),
                                  color: lighten(
                                      produit.couleur.withOpacity(.05), 0.3),
                                  onPressed: !widget.choice
                                      ? () {
                                          pushPage(
                                              context,
                                              NewProductPage(
                                                  user: widget.user,
                                                  commerce: widget.commerce,
                                                  produit: produit));
                                        }
                                      : () {
                                          Navigator.pop(context, produit);
                                        },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100)),
                                  child: Row(
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: produit.couleur
                                                      .withOpacity(.5))),
                                          height: 30,
                                          width: 30,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.network(produit.url,
                                                  fit: BoxFit.cover))),
                                      const SizedBox(width: 10),
                                      Text(produit.nom)
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
                      }),
                  isExpanded: expanded[snapshot.data!
                      .lastIndexWhere((element) => element.id == categorie.id)],
                );
              }).toList(),
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

class NewProductPage extends StatefulWidget {
  const NewProductPage(
      {super.key,
      required this.user,
      required this.commerce,
      this.produit,
      this.scanProduct,
      this.categorie});
  final User user;
  final ScanProduct? scanProduct;
  final Product? produit;
  final Commerce commerce;
  final Categorie? categorie;

  @override
  State<NewProductPage> createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  TextEditingController nom = TextEditingController();
  TextEditingController barcode = TextEditingController();
  MoneyMaskedTextController poids =
      MoneyMaskedTextController(rightSymbol: " L", precision: 1);
  TextEditingController keyword = TextEditingController();
  MoneyMaskedTextController prix =
      MoneyMaskedTextController(rightSymbol: '€', precision: 2);
  late Product produit;
  List unites = ["L", "cL", "mL", "kg", "g", "mg"];
  late Color color;

  int uniteIndex = 0;

  @override
  void initState() {
    DocumentReference doc =
        FirebaseFirestore.instance.collection("products").doc();
    produit = Product(
        poids: 0,
        surstock: 0,
        rupture: 0,
        url: "",
        item: [],
        barcode: [],
        categorieId: "",
        id: doc.id,
        nom: "",
        couleur: widget.user.couleur,
        keywords: [],
        price: 0,
        unite: "L",
        options: []);
    if (widget.produit != null) {
      produit = widget.produit!;
    }
    if (widget.scanProduct != null) {
      produit.nom = widget.scanProduct!.nom;
      produit.keywords = widget.scanProduct!.keywords;
      produit.barcode.add(widget.scanProduct!.id);
      produit.url = widget.scanProduct!.url;
    }
    if (widget.categorie != null) {
      produit.couleur = widget.categorie!.couleur;
      produit.unite = widget.categorie!.unite;
      produit.categorieId = widget.categorie!.id;
      produit.price = widget.categorie!.price;
    }
    nom.text = produit.nom;
    if (produit.barcode.isNotEmpty) {
      barcode.text = produit.barcode.join(", ");
      barcode.text.substring(0, barcode.text.length - 2);
    }

    uniteIndex = unites.indexOf(produit.unite);
    if (uniteIndex == -1) {
      uniteIndex = 0;
    } else {
      poids = MoneyMaskedTextController(
          rightSymbol: " ${unites[uniteIndex]}", precision: 1);
    }
    color = produit.couleur;
    keyword.text = produit.keywords.join(", ");
    if (keyword.text.isNotEmpty) {
      keyword.text.substring(0, keyword.text.length - 2);
    }
    poids.updateValue(produit.poids);
    prix.updateValue(produit.price / 100);
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
                            title: "Nouveau produit",
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
                            onPressed: produit.nom.length > 2 &&
                                    produit.categorieId != "" &&
                                    produit.url != "" &&
                                    produit.barcode.isNotEmpty
                                ? (widget.produit != null
                                    ? () {
                                        produit.update();
                                        Navigator.pop(context);
                                      }
                                    : () {
                                        produit.create();
                                        Navigator.pop(context, produit);
                                      })
                                : null,
                            shape: StadiumBorder(
                                side: BorderSide(
                                    width: 2,
                                    color: Colors.green.withOpacity(.3))),
                            child: Text(
                                widget.produit != null
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
                height: 80,
                width: 80,
                child: Stack(
                  children: [
                    produit.url != ""
                        ? SizedBox.expand(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.network(
                                produit.url,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox.expand(
                      child: CustomButton(
                        onPressed: () async {
                          XFile? image = await showPicker(context);
                          if (image != null) {
                            String? url = await uploadFile(
                                context, image, widget.commerce.id);
                            if (url != null) {
                              setState(() {
                                produit.url = url;
                              });
                            }
                          }
                        },
                        shape: StadiumBorder(
                            side: BorderSide(
                                color: black(context).withOpacity(.5))),
                        child: Image.asset("assets/icon/add-camera.png",
                            scale: 10, color: black(context)),
                      ),
                    ),
                  ],
                )),
            SizedBox(
              height: 75,
              child: FieldText2(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  borderColor: black(context).withOpacity(.1),
                  hintText: "Nom",
                  controller: nom,
                  onChanged: (v) {
                    produit.nom = v!;
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
                    produit.keywords = keywords;
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
                  hintText: "Code-barre",
                  controller: barcode,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  onChanged: (v) {
                    List<String> barcodes = barcode.text.split(",");
                    for (var i = 0; i < barcodes.length; i++) {
                      if (barcodes[i].startsWith(" ")) {
                        barcodes[i] = barcodes[i].substring(1);
                      }
                    }
                    produit.barcode = barcodes;
                    setState(() {});
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 3.0),
              child: Text("Catégorie",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
            ),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: FutureBuilder<Categorie?>(
                  future: Categorie.get(produit.categorieId),
                  builder: (context, snapshot) {
                    Categorie? categorie = snapshot.data;
                    return CustomButton(
                        color: categorie != null
                            ? lighten(categorie.couleur.withOpacity(.05), 0.3)
                            : null,
                        shape: StadiumBorder(
                            side: BorderSide(
                                color: (categorie != null
                                        ? categorie.couleur
                                        : black(context))
                                    .withOpacity(.1))),
                        onPressed: () async {
                          Categorie? cat = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CategoriePage(
                                      choice: true,
                                      user: widget.user,
                                      commerce: widget.commerce,
                                    )),
                          );
                          if (cat != null) {
                            setState(() {
                              produit.categorieId = cat.id;
                            });
                          }
                        },
                        child: snapshot.hasData &&
                                snapshot.data != null &&
                                snapshot.data!.commerce != ""
                            ? Text(categorie!.nom,
                                style: TextStyle(fontWeight: FontWeight.bold))
                            : const Text("Choisir une catégorie"));
                  }),
            ),
            const SizedBox(height: 15),
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
                            produit.poids = 0;
                            uniteIndex = index;
                            produit.unite = unites[index];
                            poids = MoneyMaskedTextController(
                                rightSymbol: " ${unites[uniteIndex]}",
                                precision: 1);
                          });
                        },
                        child: Text(unites[index])),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 75,
              child: FieldText2(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  borderColor: black(context).withOpacity(.1),
                  hintText: "Poids (par défaut)",
                  controller: poids,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  onChanged: (v) {
                    produit.poids = poids.numberValue;
                    setState(() {});
                    print(produit.poids);
                  }),
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
                  produit.price = (prix.numberValue * 100).round();
                  setState(() {});

                  print(produit.price);
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
                      color: produit.couleur,
                      shape: StadiumBorder(
                          side: BorderSide(
                              color: black(context).withOpacity(.2))),
                      onPressed: () async {
                        produit.couleur = await chooseColor(context);
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
