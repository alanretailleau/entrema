import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

class Galerie {
  final String id;
  final String badUrl;
  final String highUrl;
  final Color lightColor;
  final Color darkColor;
  final String idStructure;
  final String nom;
  final String typeStructure;
  final DateTime date;
  final List<dynamic> ecole;
  final bool visible;
  final bool key;
  final String type;

  Galerie(
      {required this.id,
      required this.badUrl,
      required this.highUrl,
      required this.darkColor,
      required this.nom,
      required this.key,
      required this.lightColor,
      required this.idStructure,
      required this.typeStructure,
      required this.date,
      required this.ecole,
      required this.visible,
      required this.type});

  factory Galerie.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Galerie(
        nom: data["nom"] ?? "",
        id: doc.id,
        lightColor: Color(int.parse("0xff${data["colors"][0]}")),
        darkColor: Color(int.parse("0xff${data["colors"][1]}")),
        highUrl: data['highUrl'] ?? data["key"] != null
            ? data["key"]["high"]
            : data["url"] ?? "",
        badUrl: data['badUrl'] ?? data["key"] != null
            ? data["key"]["bad"]
            : data["url"] ?? "",
        key: data["key"] != null,
        idStructure: data["idStructure"],
        typeStructure: data["typeStructure"] ?? "",
        date: (data['date'] as Timestamp).toDate(),
        ecole: data["ecole"] != null
            ? data["ecole"].runtimeType == "".runtimeType
                ? [data["ecole"]]
                : data["ecole"]
            : [],
        visible: data["visible"] ?? false,
        type: data["type"] ?? "");
  }
}
