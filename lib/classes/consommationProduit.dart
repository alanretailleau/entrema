import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/classes/categorie.dart';
import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/consommationCategorie.dart';
import 'package:entrema/classes/product.dart';
import 'package:async/async.dart';

class ConsoProd {
  String _id; // Identifiant du document
  DateTime _date; // Heure de consommation
  String _idAdherent; // Identifiant de l'adhérent
  double _quantite; // Quantité consommée
  bool _livraison;

  ConsoProd({
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

  static Future<List<ConsoProd?>> getConsoProductByList(
      List<String> conso) async {
    List<ConsoProd?> consommations = [];
    for (var i = 0; i < conso.length; i++) {
      consommations.add(await ConsoProd.read(conso[i]));
    }
    return consommations;
  }

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

  // Crée un ConsoProd dans Firestore
  Future<bool> create() async {
    try {
      await FirebaseFirestore.instance
          .collection('consoProds')
          .doc(_id)
          .set(toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Lit un ConsoProd de Firestore par son ID
  static Future<ConsoProd?> read(String id) async {
    var doc =
        await FirebaseFirestore.instance.collection('consoProds').doc(id).get();
    return doc.exists ? fromJson(doc.data() as Map<String, dynamic>) : null;
  }

  // Met à jour un ConsoProd dans Firestore
  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection('consoProds')
        .doc(_id)
        .update(toJson());
  }

  // Supprime un ConsoProd de Firestore
  Future<void> delete() async {
    await FirebaseFirestore.instance.collection('consoProds').doc(_id).delete();
  }

  // Stream les changements d'un ConsoProd
  static Stream<ConsoProd?> streamConsoProd(String id) {
    return FirebaseFirestore.instance
        .collection('consoProds')
        .doc(id)
        .snapshots()
        .map((snapshot) => snapshot.exists
            ? fromJson(snapshot.data() as Map<String, dynamic>)
            : null);
  }

  // Create from JSON from Firestore
  static ConsoProd fromJson(Map<String, dynamic> json) {
    return ConsoProd(
      livraison: json["livraison"] == true,
      id: json['id'] as String,
      date: (json['date'] as Timestamp).toDate(),
      idAdherent: json['idAdherent'] as String,
      quantite: json['quantite'] as double,
    );
  }
}

class ConsommationProduct {
  String _id; // Identifiant du document
  String _idProd; // Identifiant du produit consommé
  DateTime _date; // Date de consommation
  String? _commerce; // Identifiant du commerce
  double _quantite; // Quantité du début de la journée
  List<String> _consommation; // Liste des consommations

  ConsommationProduct({
    required String id,
    required String idProd,
    required DateTime date,
    String? commerce,
    required double quantite,
    required List<String> consommation,
  })  : _id = id,
        _idProd = idProd,
        _date = date,
        _commerce = commerce,
        _quantite = quantite,
        _consommation = consommation;

  // Getters and setters
  String get id => _id;
  set id(String value) => _id = value;

  String get idProd => _idProd;
  set idProd(String value) => _idProd = value;

  DateTime get date => _date;
  set date(DateTime value) => _date = value;

  String? get commerce => _commerce;
  set commerce(String? value) => _commerce = value;

  double get quantite => _quantite;
  set quantite(double value) => _quantite = value;

  List<String> get consommation => _consommation;
  set consommation(List<String> value) => _consommation = value;

  // Crée un ConsommationProduct dans Firestore
  Future<bool> create() async {
    try {
      await FirebaseFirestore.instance
          .collection('consommationProducts')
          .doc(_id)
          .set(toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<ConsommationProduct>> getConsoProductByCommerce(
      String commerceId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('consommationProducts')
        .where('commerce', isEqualTo: commerceId)
        .get();
    return querySnapshot.docs
        .map((doc) => ConsommationProduct.fromJson(doc.data()))
        .toList();
  }

  // Lit un ConsommationProduct de Firestore par son ID
  static Future<ConsommationProduct?> read(String id) async {
    var doc = await FirebaseFirestore.instance
        .collection('consommationProducts')
        .doc(id)
        .get();
    return doc.exists ? fromJson(doc.data() as Map<String, dynamic>) : null;
  }

  // Met à jour un ConsommationProduct dans Firestore
  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection('consommationProducts')
        .doc(_id)
        .update(toJson());
  }

  // Supprime un ConsommationProduct de Firestore
  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection('consommationProducts')
        .doc(_id)
        .delete();
  }

  // Stream les changements d'un ConsommationProduct
  static Stream<ConsommationProduct?> streamConsommationProduct(String id) {
    return FirebaseFirestore.instance
        .collection('consommationProducts')
        .doc(id)
        .snapshots()
        .map((snapshot) => snapshot.exists
            ? fromJson(snapshot.data() as Map<String, dynamic>)
            : null);
  }

  // Stream tous les ConsommationProducts
  static Stream<List<ConsommationProduct>> streamConsommationProducts(
      String idProd, DateTime start, DateTime end) {
    return FirebaseFirestore.instance
        .collection('consommationProducts')
        .where("idProd", isEqualTo: idProd)
        .where("date", isGreaterThanOrEqualTo: start)
        .where("date", isLessThanOrEqualTo: end)
        .orderBy("date", descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromJson(doc.data())).toList());
  }

  static Stream<List<List<ConsommationProduct>>>
      streamMultipleConsommationProducts(
          List<String> idsProd, DateTime start, DateTime end) {
    // Créer une liste de streams pour chaque ID produit
    var streams = idsProd.map((idProd) {
      return FirebaseFirestore.instance
          .collection('consommationProducts')
          .where("idProd", isEqualTo: idProd)
          .where("date", isGreaterThanOrEqualTo: start)
          .where("date", isLessThanOrEqualTo: end)
          .orderBy("date", descending: false)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => fromJson(doc.data())).toList());
    }).toList();

    // Fusionner tous les streams en un seul
    var mergedStream = StreamGroup.merge(streams);

    // Transformer les émissions en une liste de listes
    return StreamZip<List<ConsommationProduct>>(streams).asBroadcastStream();
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'idProd': _idProd,
      'date': Timestamp.fromDate(_date),
      'commerce': _commerce,
      'quantite': _quantite,
      'consommationIds': _consommation,
    };
  }

  // Create from JSON from Firestore
  static ConsommationProduct fromJson(Map<String, dynamic> json) {
    return ConsommationProduct(
      id: json['id'] as String,
      idProd: json['idProd'] as String,
      date: (json['date'] as Timestamp).toDate(),
      commerce: json['commerce'] as String?,
      quantite: json['quantite'].toDouble(),
      consommation: List<String>.from(json['consommationIds']),
    );
  }
}

class ConsommationProductService {
  // Recherche ou crée une consommation pour un produit et une date donnés
  static Future<void> addOrUpdateConsommationProduct(
      Commerce commerce,
      Categorie categorie,
      Product product,
      DateTime date,
      ConsoProd newConsoProd,
      {double startQuantite = 0}) async {
    // Convertir la date au début de la journée
    DateTime dateAtStartOfDay = DateTime(date.year, date.month, date.day);

    // Rechercher une consommation existante pour la date spécifiée
    var querySnapshot = await FirebaseFirestore.instance
        .collection('consommationProducts')
        .where('idProd', isEqualTo: product.id)
        .where('date', isEqualTo: dateAtStartOfDay)
        .get();
    print(querySnapshot.size);

    if (querySnapshot.docs.isNotEmpty) {
      // Consommation existante trouvée pour la date spécifiée
      List<ConsommationProduct> existingConsommations = [];
      List<String> tempConsommations = [];
      for (var i = 0; i < querySnapshot.size; i++) {
        existingConsommations
            .add(ConsommationProduct.fromJson(querySnapshot.docs[i].data()));
        tempConsommations += existingConsommations[i].consommation;
        if (i != 0) {
          existingConsommations[i].delete();
        }
      }

      // Ajouter le nouveau ConsoProd à la liste existante
      ConsommationProduct newExistingConsommation = ConsommationProduct(
          id: existingConsommations.first.id,
          idProd: product.id,
          commerce: commerce.id,
          date: dateAtStartOfDay,
          quantite: existingConsommations.first.quantite,
          consommation: tempConsommations);
      newExistingConsommation.consommation.add(newConsoProd.id);

      // Mettre à jour la consommation dans Firestore
      await newExistingConsommation.update();
      await newConsoProd.create();
    } else {
      // Rechercher la dernière consommation pour obtenir la quantité de départ
      var lastConsommationSnapshot = await FirebaseFirestore.instance
          .collection('consommationProducts')
          .where('idProd', isEqualTo: product.id)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      double startingQuantity = startQuantite;
      if (lastConsommationSnapshot.docs.isNotEmpty) {
        var lastConsommation = ConsommationProduct.fromJson(
            lastConsommationSnapshot.docs.first.data());
        List<ConsoProd?> consosProd = await ConsoProd.getConsoProductByList(
            lastConsommation.consommation);
        for (var i = 0; i < consosProd.length; i++) {
          if (consosProd[i] != null) {
            if (consosProd[i]!.livraison) {
              startingQuantity += consosProd[i]!.quantite;
            } else {
              startingQuantity -= consosProd[i]!.quantite;
            }
          }
        }
        // Ajuster la logique pour calculer startingQuantity si nécessaire
        startingQuantity += lastConsommation.quantite;
      }

      // Créer une nouvelle consommation
      ConsommationProduct newConsommation = ConsommationProduct(
        id: FirebaseFirestore.instance
            .collection('consommationProducts')
            .doc()
            .id,
        idProd: product.id,
        date: dateAtStartOfDay,
        commerce: commerce.id,
        quantite: startingQuantity,
        consommation: [newConsoProd.id],
      );

      // Enregistrer la nouvelle consommation dans Firestore
      await newConsoProd.create();
      await newConsommation.create();
    }
    await ConsommationCategorieService.addOrUpdateConsommationCategorie(
        commerce,
        categorie,
        date,
        ConsoCategorie(
          id: FirebaseFirestore.instance.collection("consoCategories").doc().id,
          livraison: newConsoProd.livraison,
          date: newConsoProd.date,
          idAdherent: newConsoProd.idAdherent,
          quantite: newConsoProd.quantite,
        ),
        startQuantite: startQuantite);
  }
}
