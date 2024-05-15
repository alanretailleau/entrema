import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/picture.dart';
import 'package:entrema/home/home.dart';
import 'package:entrema/widget/button.dart';
import 'package:entrema/widget/button2.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../classes/user.dart';
import '../color.dart';
import '../functions/function.dart';
import '../widget/FieldText.dart';
import '../widget/Loader.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final FocusNode _focus = FocusNode();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  String erreur = "";
  bool isLoading = false;
  bool supportsAppleSignIn = false;
  late String verificationId;
  double opacity = 0;
  double padding = 0;

  @override
  void initState() {
    _focus.addListener(_onFocusChange);
    update();
    super.initState();
  }

  void _onFocusChange() {
    if (_focus.hasFocus) {
      setState(() {});
    }
  }

  void update() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        opacity = 1;
        padding = 20;
      });
    });
  }

  bool showTel = true;
  bool showCode = false;
  bool cguAccepted = false;
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Theme.of(context).primaryColor,
        child: Scaffold(
            backgroundColor: Colors.blueGrey.withOpacity(0.05),
            body: SafeArea(
              child: WillPopScope(
                  onWillPop: () async {
                    bool quit = await editDialog(context, "Annuler", "Oui",
                        "Voulez-vous quitter Entr'EMA ?");
                    if (quit == true) {
                      exit(0);
                    } else {
                      return false;
                    }
                  },
                  child: SingleChildScrollView(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: SizedBox(
                            height: MediaQuery.of(context).size.width / 3,
                            width: MediaQuery.of(context).size.width / 3,
                            child: CustomButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {},
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                color: Theme.of(context).primaryColor,
                                highlightColor: blue.withOpacity(0.2),
                                splashColor: blue.withOpacity(0.2),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    "assets/icon.png",
                                    fit: BoxFit.cover,
                                  ),
                                ))),
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(seconds: 2),
                              bottom: -20 + padding,
                              curve: Curves.decelerate,
                              child: AnimatedOpacity(
                                duration: const Duration(seconds: 2),
                                curve: Curves.easeIn,
                                opacity: opacity,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width - 40,
                                  height: 60,
                                  child: AnimatedOpacity(
                                      opacity: opacity,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      child: CustomButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        color: blue.withOpacity(0.7),
                                        splashColor: blue.withOpacity(0.2),
                                        highlightColor: blue.withOpacity(0.2),
                                        onPressed: () {
                                          pushPage(
                                              context,
                                              const Inscription(
                                                  inscription: false));
                                        },
                                        child: const Text("Se connecter",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(seconds: 3),
                              bottom: -60 + padding * 3,
                              curve: Curves.decelerate,
                              child: AnimatedOpacity(
                                duration: const Duration(seconds: 3),
                                curve: Curves.easeIn,
                                opacity: opacity,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width - 80,
                                  height: 50,
                                  child: AnimatedOpacity(
                                      opacity: opacity,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      child: CustomButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        color: blue.withOpacity(0.2),
                                        splashColor: blue.withOpacity(0.2),
                                        highlightColor: blue.withOpacity(0.2),
                                        onPressed: () {
                                          pushPage(
                                              context,
                                              const Inscription(
                                                  inscription: true));
                                        },
                                        child: Text("Se créer un compte",
                                            style: TextStyle(
                                                color: blue,
                                                fontWeight: FontWeight.bold)),
                                      )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ))),
            )));
  }
}

class Inscription extends StatefulWidget {
  const Inscription({super.key, required this.inscription});
  final bool inscription;
  @override
  _InscriptionState createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  TextEditingController prenom = TextEditingController();
  TextEditingController nom = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _isLoading = false;
  String erreur = "";
  bool loading = false;
  List<String> colors = [];
  int colorInt = 0;
  String? url;
  Color currentColor = blue;
  Color pickerColor = blue;
  bool cgu = false;
  bool eye = false;

  @override
  void initState() {
    colors = [
      "0xffFE3C3C",
      "0xffFA4FAA",
      "0xffBA30E2",
      "0xff7E08CD",
      "0xff6515F1",
      "0xff1C1CE4",
      "0xff1166F7",
      "0xff20A8F6",
      "0xff1FE4FA",
      "0xff14F8E9",
      "0xff20EC80",
      "0xff18DA45",
      "0xff2CBC0F",
      "0xff4CEE04",
      "0xffA9F13D",
      "0xffF2FB06",
      "0xffF1DB14",
      "0xffFFB02A",
      "0xffF77816"
    ];
    info = [
      {
        "type": "information",
        "text": "Bienvenue sur Komi",
      },
      {
        "type": "text",
        "hintText": "Prénom",
        "controller": prenom,
      },
      {"type": "text", "hintText": "Nom", "controller": nom},
      {
        "type": "color",
      },
      {
        "type": "photo",
      },
      {
        "type": "code",
      },
      {"type": "article"}
    ];
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  List<Map> info = [];
  int page = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Theme.of(context).primaryColor,
        child: Scaffold(
            backgroundColor: Colors.blueGrey.withOpacity(0.05),
            body: SafeArea(
                child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.only(
                          top: 100, right: 20, left: 20, bottom: 20),
                      children: [
                        const Center(
                          child: Text("Bienvenue sur Entr'EMA !",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Nexa")),
                        ),
                        Center(
                          child: Text(
                              widget.inscription
                                  ? "Avant de continuer, nous avons besoin de quelques informations !"
                                  : "Pour pouvoir continuer, nous avons besoin de quelques informations !",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                              )),
                        ),
                        const SizedBox(height: 30),
                        widget.inscription
                            ? FieldText(
                                keyboardType: TextInputType.name,
                                controllerFR: prenom,
                                onChanged: (v) {},
                                validator: (p) {
                                  if (p != null &&
                                      (p.length < 3 ||
                                          p.contains("@") ||
                                          p.contains("'") ||
                                          p.contains('"') ||
                                          p.contains("&"))) {
                                    if (p.length < 2) {
                                      return "Le prénom n'est pas assez long";
                                    }
                                    return "Le format du prénom est invalide";
                                  } else {
                                    return null;
                                  }
                                },
                                onFieldSubmitted: (p0) {
                                  _formKey.currentState!.validate();
                                  return p0;
                                },
                                hintText: "Prénom",
                              )
                            : Container(),
                        widget.inscription
                            ? const SizedBox(height: 20)
                            : Container(),
                        widget.inscription
                            ? FieldText(
                                keyboardType: TextInputType.name,
                                controllerFR: nom,
                                validator: (p) {
                                  if (p != null &&
                                      (p.length < 2 && p.isNotEmpty ||
                                          p.contains("@") ||
                                          p.contains("'") ||
                                          p.contains('"') ||
                                          p.contains("&"))) {
                                    if (p.length < 2 && p.isNotEmpty) {
                                      return "Le nom n'est pas assez long";
                                    }
                                    return "Le format du nom est invalide";
                                  } else {
                                    return null;
                                  }
                                },
                                onFieldSubmitted: (v) {
                                  _formKey.currentState!.validate();
                                  return v;
                                },
                                onChanged: (v) {},
                                hintText: "Nom",
                              )
                            : Container(),
                        widget.inscription
                            ? const SizedBox(height: 20)
                            : Container(),
                        FieldText(
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          controllerFR: email,
                          validator: (p) {
                            if (p != null && (p.contains("@") || p.isEmpty)) {
                              return null;
                            } else {
                              return "L'adresse e-mail est incorrecte.";
                            }
                          },
                          onChanged: (v) {},
                          onFieldSubmitted: (v) {
                            _formKey.currentState!.validate();
                          },
                          hintText: "Adresse e-mail",
                        ),
                        SizedBox(height: 20),
                        FieldText(
                          eye: eye,
                          eyeClick: () {
                            setState(() {
                              eye = !eye;
                            });
                          },
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.none,
                          controllerFR: password,
                          obscureText: !eye,
                          validator: (p) {
                            if (p != null &&
                                (p.length < 5 && p.isNotEmpty ||
                                    p.contains("'") ||
                                    p.contains('"'))) {
                              if (p.length < 5 && p.isNotEmpty) {
                                return "Le mot de passe n'est pas assez long.";
                              }
                              return "Le format du mot de passe est incorrecte.";
                            } else {
                              return null;
                            }
                          },
                          onFieldSubmitted: (v) {
                            _formKey.currentState!.validate();
                            return v;
                          },
                          onChanged: (v) {},
                          hintText: "Mot de passe",
                        ),
                        SizedBox(height: 20),
                        widget.inscription
                            ? Center(
                                child: Text(
                                "Je reconnais avoir lu et accepté les CGU et les mentions légales.",
                                textAlign: TextAlign.center,
                              ))
                            : Container(),
                        widget.inscription
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CustomButton(
                                        padding: EdgeInsets.zero,
                                        shape: StadiumBorder(),
                                        onPressed: () {
                                          setState(() {
                                            cgu = !cgu;
                                          });
                                        },
                                        child: Button(
                                          height: 20,
                                          active: cgu,
                                          multipleChoice: true,
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: CustomButton(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      color: blue.withOpacity(.1),
                                      child: Text(
                                          "Lire les CGU et les mentions légales",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: blue,
                                            fontSize: 12,
                                          )),
                                      onPressed: () async {
                                        launchUrl(
                                            Uri.parse('https://alanretailleau.wixsite.com/sapply/copie-de-r%C3%A8gles-de-confidentialit%C3%A9'));
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: SizedBox(
                            height: 60,
                            child: CustomButton(
                              color: blue.withOpacity(.1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              onPressed: widget.inscription
                                  ? () async {
                                      if (_formKey.currentState!.validate() &&
                                          cgu) {
                                        if (email.text.isNotEmpty &&
                                            nom.text.isNotEmpty &&
                                            prenom.text.isNotEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                backgroundColor:
                                                    Colors.transparent,
                                                elevation: 0,
                                                content: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    margin:
                                                        const EdgeInsets.all(
                                                            20),
                                                    decoration: BoxDecoration(
                                                        color: blue
                                                            .withOpacity(.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Text(
                                                        'Création de votre compte en cours...',
                                                        style: TextStyle(
                                                            color: blue,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)))),
                                          );
                                          auth.UserCredential userCred =
                                              await auth.FirebaseAuth.instance
                                                  .createUserWithEmailAndPassword(
                                                      email: email.text,
                                                      password: password.text);
                                          if (userCred.user != null) {
                                            DocumentReference userRef =
                                                FirebaseFirestore.instance
                                                    .collection("user")
                                                    .doc(userCred.user!.uid);
                                            User user = User(
                                                admin: false,
                                                id: userCred.user!.uid,
                                                couleur: Colors.blue,
                                                dateCreation: DateTime.now(),
                                                cguVersion: 1.0,
                                                commerce:
                                                    "faFrceUSXGufmVsAnguy",
                                                fav: ["faFrceUSXGufmVsAnguy"],
                                                langue: "FR",
                                                prenom: prenom.text
                                                        .substring(0, 1)
                                                        .toUpperCase() +
                                                    prenom.text
                                                        .substring(1)
                                                        .toLowerCase(),
                                                bloque: false,
                                                nom: nom.text
                                                        .substring(0, 1)
                                                        .toUpperCase() +
                                                    nom.text
                                                        .substring(1)
                                                        .toLowerCase(),
                                                searchTerm: searchTerm([
                                                  "${prenom.text} ${nom.text}",
                                                  prenom.text,
                                                  nom.text,
                                                  email.text
                                                ]),
                                                email: email.text);
                                            if (await user.create()) {
                                              pushPage(
                                                  context, Home(user: user));
                                            }

                                            Picture user2;
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                backgroundColor:
                                                    Colors.transparent,
                                                elevation: 0,
                                                content: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    margin: const EdgeInsets.all(
                                                        20),
                                                    decoration: BoxDecoration(
                                                        color: Colors.red
                                                            .withOpacity(.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10)),
                                                    child: Text(
                                                        'Une erreur est survenue...',
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontWeight: FontWeight.bold)))));
                                          }
                                        }
                                      } else if (!cgu) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              content: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  margin:
                                                      const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                      color: Colors.red
                                                          .withOpacity(.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: const Text(
                                                      "Merci d'accepter les CGU et les mentions légales.",
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                        );
                                      }
                                    }
                                  : () async {
                                      auth.UserCredential userCredential =
                                          await auth.FirebaseAuth.instance
                                              .signInWithEmailAndPassword(
                                                  email: email.text,
                                                  password: password.text);
                                      if (userCredential.user != null) {
                                        // ignore: use_build_context_synchronously

                                        pushPage(
                                            context,
                                            Home(
                                                user: (await User.read(
                                                    userCredential
                                                        .user!.uid))!));
                                      }
                                    },
                              child: Text(
                                  widget.inscription
                                      ? 'Créer mon compte'
                                      : "Se connecter",
                                  style: TextStyle(
                                      color: blue,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    )))));
  }

  bool isLoading = false;
  void publishImage(String id) async {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  child: Material(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xfffafdff)
                          : const Color(0xff00151f),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 160,
                              child: CustomButton(
                                  color: blue.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  onPressed: () async {
                                    final pickedFile = await ImagePicker()
                                        .pickImage(source: ImageSource.camera);
                                    if (pickedFile != null) {
                                      uploadFile(pickedFile, id);
                                      Navigator.pop(context);
                                      setState(() {});
                                    }
                                  },
                                  child: const Text("Prendre une photo",
                                      style: TextStyle(color: Colors.white))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 160,
                              child: CustomButton(
                                  color: blue.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  onPressed: () async {
                                    final pickedFile = await ImagePicker()
                                        .pickImage(source: ImageSource.gallery);
                                    if (pickedFile != null) {
                                      isLoading = true;
                                      uploadFile(pickedFile, id);
                                      Navigator.pop(context);
                                      setState(() {});
                                    }
                                  },
                                  child: const Text("Galerie photo",
                                      style: TextStyle(color: Colors.white))),
                            ),
                          ),
                        ],
                      ))));
        });
  }

  List<String> getColors(palette) {
    late Color lightColor = Colors.white;
    late Color darkColor = Colors.black;

    if (palette.lightMutedColor != null) {
      lightColor = palette.lightMutedColor!.color;
    } else if (palette.mutedColor != null) {
      lightColor = palette.mutedColor!.color;
    } else if (palette.paletteColors.isNotEmpty) {
      lightColor =
          palette.paletteColors[palette.paletteColors.length > 1 ? 2 : 0].color;
    }
    if (palette.darkVibrantColor != null) {
      darkColor = palette.darkVibrantColor!.color;
    } else if (palette.mutedColor != null) {
      darkColor = palette.mutedColor!.color;
    } else if (palette.paletteColors.isNotEmpty) {
      darkColor =
          palette.paletteColors[palette.paletteColors.length > 1 ? 2 : 0].color;
    }
    return [
      lightColor.value.toRadixString(16),
      darkColor.value.toRadixString(16)
    ];
  }

  void uploadFile(XFile? image, String id) async {
    firebase_storage.UploadTask uploadTask;
    firebase_storage.Reference firebaseStorageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('pdp/${id}/${DateTime.now()}');
    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': image!.path});
    uploadTask = firebaseStorageRef.putFile(File(image.path), metadata);
    await uploadTask.whenComplete(() {
      isLoading = false;
      firebaseStorageRef.getDownloadURL().then((value) async {
        setState(() {
          url = value;
        });
      });
    });
  }
}

class MentionsLegale extends StatefulWidget {
  const MentionsLegale({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MentionsLegaleState createState() => _MentionsLegaleState();
}

class _MentionsLegaleState extends State<MentionsLegale> {
  List<String> pave = [
    "Bienvenue sur l'application Ema. Cette page vous présente nos conditions pour que vous puissiez profiter de cette application en connaissance de cause.",
    "Ema (Ecole Mines Alès) est une application mobile dévelopé par Alan RETAILLEAU qui peut être contacté par mail à l'adresse suivante : alan.retailleau@gmail.com",
    "Il est conseillé de se créer un profil pour profiter pleinement des avantages que vous apporte Ema. Lors de l'ouverture de votre compte, vous nous fournissez un numéro de téléphone qui va vous permettre de sécuriser votre compte. En plus de cela, un code à 4 chiffres est sauvegardé et crypté. Nous collectons par ailleurs votre prénom et votre nom pour rendre plus facile la gestion de votre profil.",
    "Ema vous permet en tant qu'ancien élève ou élève de : \ntrouver toutes les informations nécessaires sur la vie étudiante de l'école, \nS'inscrire à des évènements, réserver des terrains...",
    "Pour accéder à l'application, vous devez posséder une connexion internet ainsi qu'un portable ou une tablette.",
    "L'ensemble du contenu de l’application relève de la législation française, communautaire et internationale sur le droit d'auteur et la propriété intellectuelle. Tous les droits de reproduction et de représentation afférents à l’Application sont réservés par Ema, y compris toutes représentations graphiques, iconographiques et photographiques, ce quel que soit le territoire de protection et que ces droits aient fait l'objet d'un dépôt ou non. La reproduction et/ou représentation de tout ou partie de l’Application, quel que soit le support, en ce compris tous noms commerciaux, marques, logos, noms de domaine et autres signes distinctifs, est formellement interdite et constituerait une contrefaçon sanctionnée par le code de la propriété intellectuelle."
  ];
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            backgroundColor: blue.withOpacity(0.03),
            body: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("info")
                    .doc("SuS965wL710kFzStlBiN")
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SafeArea(
                        child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Mentions légales et CGU",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 22)),
                          const SizedBox(height: 10),
                          const SizedBox(height: 20),
                          CustomButton(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            shape: const StadiumBorder(),
                            color: blue.withOpacity(.1),
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: Text(
                                "J'accepte les mentions légales et les CGU",
                                style: TextStyle(
                                    color: blue, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ));
                  } else {
                    return Container();
                  }
                })));
  }
}
