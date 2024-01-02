import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/classes/categorie.dart';
import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/consommationProduit.dart';
import 'package:entrema/classes/product.dart';

class ConsoCategorie {
  String _id; // Identifiant du document
  DateTime _date; // Heure de consommation
  String _idAdherent; // Identifiant de l'adhérent
  double _quantite; // Quantité consommée
  bool _livraison;

  ConsoCategorie({
    required String id,
    required bool livraison,
    required DateTime date,
    required String idAdherent,
    required double quantite,
  })  : _id = id,
        _date = date,
        _livraison = livraison,
        _idAdherent = idAdherent,
        _quantite = quantite;

  // Getters and setters
  String get id => _id;
  set id(String value) => _id = value;

  bool get livraison => _livraison;
  set livraison(bool value) => _livraison = value;

  DateTime get date => _date;
  set date(DateTime value) => _date = value;

  String get idAdherent => _idAdherent;
  set idAdherent(String value) => _idAdherent = value;

  double get quantite => _quantite;
  set quantite(double value) => _quantite = value;

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'livraison': _livraison,
      'id': _id,
      'date': Timestamp.fromDate(_date),
      'idAdherent': _idAdherent,
      'quantite': _quantite,
    };
  }

  // Crée un ConsoCategorie dans Firestore
  Future<bool> create() async {
    try {
      await FirebaseFirestore.instance
          .collection('consoCategories')
          .doc(_id)
          .set(toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Lit un ConsoCategorie de Firestore par son ID
  static Future<ConsoCategorie?> read(String id) async {
    var doc = await FirebaseFirestore.instance
        .collection('consoCategories')
        .doc(id)
        .get();
    return doc.exists ? fromJson(doc.data() as Map<String, dynamic>) : null;
  }

  static Future<List<ConsoCategorie?>> getConsoCategorieByList(
      List<String> conso) async {
    List<ConsoCategorie?> consommations = [];
    for (var i = 0; i < conso.length; i++) {
      consommations.add(await ConsoCategorie.read(conso[i]));
    }
    return consommations;
  }

  // Met à jour un ConsoCategorie dans Firestore
  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection('consoCategories')
        .doc(_id)
        .update(toJson());
  }

  // Supprime un ConsoProd de Firestore
  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection('consoCategories')
        .doc(_id)
        .delete();
  }

  // Stream les changements d'un ConsoCategorie
  static Stream<ConsoCategorie?> streamConsoCategorie(String id) {
    return FirebaseFirestore.instance
        .collection('consoCategories')
        .doc(id)
        .snapshots()
        .map((snapshot) => snapshot.exists
            ? fromJson(snapshot.data() as Map<String, dynamic>)
            : null);
  }

  // Create from JSON from Firestore
  static ConsoCategorie fromJson(Map<String, dynamic> json) {
    return ConsoCategorie(
      livraison: json["livraison"] == true,
      id: json['id'] as String,
      date: (json['date'] as Timestamp).toDate(),
      idAdherent: json['idAdherent'] as String,
      quantite: json['quantite'] as double,
    );
  }
}

class ConsommationCategorie {
  String _id; // Identifiant du document
  String _idCategorie; // Identifiant du produit consommé
  DateTime _date; // Date de consommation
  String? _commerce; // Identifiant du commerce
  double _quantite; // Quantité du début de la journée
  List<String> _consommation; // Liste des consommations

  ConsommationCategorie({
    required String id,
    required String idCategorie,
    required DateTime date,
    String? commerce,
    required double quantite,
    required List<String> consommation,
  })  : _id = id,
        _idCategorie = idCategorie,
        _date = date,
        _commerce = commerce,
        _quantite = quantite,
        _consommation = consommation;

  // Getters and setters
  String get id => _id;
  set id(String value) => _id = value;

  String get idCategorie => _idCategorie;
  set idCategorie(String value) => _idCategorie = value;

  DateTime get date => _date;
  set date(DateTime value) => _date = value;

  String? get commerce => _commerce;
  set commerce(String? value) => _commerce = value;

  double get quantite => _quantite;
  set quantite(double value) => _quantite = value;

  List<String> get consommation => _consommation;
  set consommation(List<String> value) => _consommation = value;

  // Crée un ConsommationCategorie dans Firestore
  Future<bool> create() async {
    try {
      await FirebaseFirestore.instance
          .collection('consommationCategories')
          .doc(_id)
          .set(toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Lit un ConsommationCategorie de Firestore par son ID
  static Future<ConsommationCategorie?> read(String id) async {
    var doc = await FirebaseFirestore.instance
        .collection('consommationCategories')
        .doc(id)
        .get();
    return doc.exists ? fromJson(doc.data() as Map<String, dynamic>) : null;
  }

  // Met à jour un ConsommationCategorie dans Firestore
  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection('consommationCategories')
        .doc(_id)
        .update(toJson());
  }

  // Supprime un ConsommationCategorie de Firestore
  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection('consommationCategories')
        .doc(_id)
        .delete();
  }

  // Stream les changements d'un ConsommationCategorie
  static Stream<ConsommationCategorie?> streamConsommationCategorie(String id) {
    return FirebaseFirestore.instance
        .collection('consommationCategories')
        .doc(id)
        .snapshots()
        .map((snapshot) => snapshot.exists
            ? fromJson(snapshot.data() as Map<String, dynamic>)
            : null);
  }

  // Stream tous les ConsommationCategorie
  static Stream<List<ConsommationCategorie>> streamConsommationsCategories(
      String idCat, DateTime start, DateTime end) {
    return FirebaseFirestore.instance
        .collection('consommationCategories')
        .where("idCategorie", isEqualTo: idCat)
        .where("date", isGreaterThanOrEqualTo: start)
        .where("date", isLessThanOrEqualTo: end)
        .orderBy("date", descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromJson(doc.data())).toList());
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'idCategorie': _idCategorie,
      'date': Timestamp.fromDate(_date),
      'commerce': _commerce,
      'quantite': _quantite,
      'consommationIds': _consommation,
    };
  }

  // Create from JSON from Firestore
  static ConsommationCategorie fromJson(Map<String, dynamic> json) {
    return ConsommationCategorie(
      id: json['id'] as String,
      idCategorie: json['idCategorie'] as String,
      date: (json['date'] as Timestamp).toDate(),
      commerce: json['commerce'] as String?,
      quantite: json['quantite'].toDouble(),
      consommation: List<String>.from(json['consommationIds']),
    );
  }

  static Future<List<ConsommationCategorie>> getConsoCategorieByCommerce(
      String commerceId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('consommationCategories')
        .where('commerce', isEqualTo: commerceId)
        .get();
    return querySnapshot.docs
        .map((doc) => ConsommationCategorie.fromJson(doc.data()))
        .toList();
  }
}

class ConsommationCategorieService {
  // Recherche ou crée une consommation pour un produit et une date donnés
  static Future<void> addOrUpdateConsommationCategorie(Commerce commerce,
      Categorie categorie, DateTime date, ConsoCategorie newConsoCategorie,
      {double startQuantite = 0}) async {
    // Convertir la date au début de la journée
    DateTime dateAtStartOfDay = DateTime(date.year, date.month, date.day);

    // Rechercher une consommation existante pour la date spécifiée
    var querySnapshot = await FirebaseFirestore.instance
        .collection('consommationCategories')
        .where('idCategorie', isEqualTo: categorie.id)
        .where('date', isEqualTo: dateAtStartOfDay)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Consommation existante trouvée pour la date spécifiée
      List<ConsommationCategorie> existingConsommations = [];
      List<String> tempConsommations = [];
      for (var i = 0; i < querySnapshot.size; i++) {
        existingConsommations
            .add(ConsommationCategorie.fromJson(querySnapshot.docs[i].data()));
        tempConsommations += existingConsommations[i].consommation;
        if (i != 0) {
          existingConsommations[i].delete();
        }
      }

      // Ajouter le nouveau ConsoProd à la liste existante

      ConsommationCategorie newExistingConsommation = ConsommationCategorie(
          id: existingConsommations.first.id,
          idCategorie: categorie.id,
          commerce: commerce.id,
          date: dateAtStartOfDay,
          quantite: existingConsommations.first.quantite,
          consommation: tempConsommations);
      newExistingConsommation.consommation.add(newConsoCategorie.id);

      // Mettre à jour la consommation dans Firestore
      await newExistingConsommation.update();
      await newConsoCategorie.create();
    } else {
      // Rechercher la dernière consommation pour obtenir la quantité de départ
      var lastConsommationSnapshot = await FirebaseFirestore.instance
          .collection('consommationCategories')
          .where('idCategorie', isEqualTo: categorie.id)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      double startingQuantity = startQuantite;

      if (lastConsommationSnapshot.docs.isNotEmpty) {
        var lastConsommation = ConsommationCategorie.fromJson(
            lastConsommationSnapshot.docs.first.data());

        List<ConsoCategorie?> consosCategorie =
            await ConsoCategorie.getConsoCategorieByList(
                lastConsommation.consommation);
        for (var i = 0; i < consosCategorie.length; i++) {
          if (consosCategorie[i] != null) {
            if (consosCategorie[i]!.livraison) {
              startingQuantity += consosCategorie[i]!.quantite;
            } else {
              startingQuantity -= consosCategorie[i]!.quantite;
            }
          }
        }
        // Ajuster la logique pour calculer startingQuantity si nécessaire
        startingQuantity += lastConsommation.quantite;
      }

      // Créer une nouvelle consommation
      ConsommationCategorie newConsommation = ConsommationCategorie(
        id: FirebaseFirestore.instance
            .collection('consommationCategories')
            .doc()
            .id,
        idCategorie: categorie.id,
        date: dateAtStartOfDay,
        commerce: commerce.id,
        quantite: startingQuantity,
        consommation: [newConsoCategorie.id],
      );

      // Enregistrer la nouvelle consommation dans Firestore
      await newConsoCategorie.create();
      await newConsommation.create();
    }
  }
}

Future fetchResults(Duration duration) async {
  return Future.delayed(duration, () {
    return true;
  });
}
