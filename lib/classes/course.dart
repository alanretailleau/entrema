import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/classes/adherent.dart';
import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/product.dart';
import 'package:entrema/classes/user.dart';
import 'package:flutter/material.dart';

class LightCourse {
  DateTime _date;
  double _price;

  LightCourse({
    required DateTime date,
    required double price,
  })  : _date = date,
        _price = price;

  DateTime get date => _date;
  set date(DateTime value) => _date = value;
  double get price => _price;
  set price(double value) => _price = value;
}

class Course {
  String _id;
  DateTime _date;
  String _commerce;
  String _user;
  bool _finish;
  String _adherent;
  int _price;
  List<ProduitScan> _element;

  Course({
    required int price,
    required String id,
    required DateTime date,
    required String commerce,
    required String user,
    required bool finish,
    required String adherent,
    required List<ProduitScan> element,
  })  : _id = id,
        _date = date,
        _commerce = commerce,
        _user = user,
        _finish = finish,
        _price = price,
        _adherent = adherent,
        _element = element {}

  // Getters and setters with validation and searchTerm update
  String get commerce => _commerce;
  set commerce(String value) => _commerce = value;

  // Getter et setter pour id
  String get id => _id;
  set id(String value) {
    if (value.isNotEmpty) {
      _id = value;
    } else {
      throw ArgumentError('L\'ID ne peut pas être vide');
    }
  }

  int get price => _price;
  set solde(int value) {
    if (price > 0) {
      _price = value;
    } else {
      _price = value;
      throw ArgumentError('Le solde est négatif !!');
    }
  }

  // Getter et setter pour dateCreation
  DateTime get date => _date;
  set date(DateTime value) => _date = value;

  // Getter et setter pour bloque
  bool get finish => _finish;
  set finish(bool value) => _finish = value;

  // Getter et setter pour data
  List<ProduitScan> get element => _element;
  set element(List<ProduitScan> value) => _element = value;

  // Getter et setter pour prenom
  String get user => _user;
  set user(String value) => _user = value;

  // Getter et setter pour nom
  String get adherent => _adherent;
  set adherent(String value) => _adherent = value;

  // Convertit un User en Map pour l'enregistrement dans Firestore
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> elementbis = [];
    for (var i = 0; i < _element.length; i++) {
      elementbis.add(_element[i].toJson());
    }
    return {
      'id': id,
      'price': _price,
      'date': Timestamp.fromDate(date),
      'commerce': _commerce,
      'user': _user,
      'finish': _finish,
      'adherent': _adherent,
      'element': elementbis,
    };
  }

  // Crée un User à partir d'une Map, utilisée pour la lecture depuis Firestore
  static Course fromJson(Map<String, dynamic> json) {
    List<ProduitScan> elements = [];
    for (var i = 0; i < json["element"].length; i++) {
      elements.add(ProduitScan.fromJson(json["element"][i]));
    }

    return Course(
        price: json["price"].round() as int,
        id: json['id'] as String,
        date: (json['date'] as Timestamp).toDate(),
        commerce: json["commerce"] as String,
        user: json["user"] as String,
        finish: json['finish'] as bool,
        adherent: json["adherent"] as String,
        element: elements);
  }

  int montant() {
    int solde = 0;
    for (var i = 0; i < element.length; i++) {
      solde += element[i].price ??
          (element[i].poids /
                  element[i].produit.poids *
                  element[i].produit.price)
              .round();
    }
    return solde;
  }

  // ... opérations CRUD

  // Crée un nouvel utilisateur dans Firestore
  Future<bool> create() async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(id)
          .set(toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Lit un utilisateur de Firestore par son ID
  static Future<Course?> read(String id) async {
    var doc =
        await FirebaseFirestore.instance.collection('courses').doc(id).get();
    return doc.exists ? fromJson(doc.data() as Map<String, dynamic>) : null;
  }

  // Stream les changements d'un utilisateur
  static Stream<Course?> streamCourse(String uid) {
    return FirebaseFirestore.instance
        .collection('courses')
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.exists
            ? fromJson(snapshot.data() as Map<String, dynamic>)
            : null);
  }

  static Stream<List<Course>> streamCourses(String commerceId, String userId) {
    return FirebaseFirestore.instance
        .collection('courses')
        .where("commerce", isEqualTo: commerceId)
        .where("user", isEqualTo: userId)
        .where("finish", isEqualTo: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromJson(doc.data())).toList());
  }

  static Stream<List<Course>> streamLatestCourses(
      String commerceId, DateTime dateTime) {
    return FirebaseFirestore.instance
        .collection('courses')
        .where("commerce", isEqualTo: commerceId)
        .where("date", isGreaterThanOrEqualTo: dateTime)
        .where("finish", isEqualTo: true)
        .orderBy("date", descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromJson(doc.data())).toList());
  }

  static double panierMoyen(List<Course> courses) {
    int price = 0;
    for (var i = 0; i < courses.length; i++) {
      for (var j = 0; j < courses[i].element.length; j++) {
        price +=
            courses[i].element[j].price ?? courses[i].element[j].produit.price;
      }
    }
    return courses.isNotEmpty ? price / courses.length / 100 : 0.0;
  }

  double panier() {
    int price = 0;
    for (var j = 0; j < element.length; j++) {
      price += element[j].price ?? element[j].produit.price;
    }

    return price / 100;
  }

  // Met à jour un utilisateur dans Firestore
  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(id)
        .update(toJson());
  }

  // Supprime un utilisateur de Firestore
  Future<void> delete() async {
    await FirebaseFirestore.instance.collection('courses').doc(id).delete();
  }
}
