import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/classes/product.dart';

class Categorie {
  String _id;
  String _nom;
  String _commerce;
  List<String> _keywords;
  int _price;
  Color _couleur;
  String _unite;
  List<Option> _options;

  Categorie({
    required String id,
    required String nom,
    required Color couleur,
    required String commerce,
    required List<String> keywords,
    required int price,
    required String unite,
    required List<Option> options,
  })  : _id = id,
        _couleur = couleur,
        _nom = nom,
        _commerce = commerce,
        _keywords = keywords,
        _price = price,
        _unite = unite,
        _options = options;

  // Getters
  String get id => _id;
  String get nom => _nom;
  String get commerce => _commerce;
  List<String> get keywords => _keywords;
  int get price => _price;
  String get unite => _unite;
  List<Option> get options => _options;

  Color get couleur => _couleur;
  set couleur(Color value) => _couleur = value;
  // Setters
  set nom(String value) => _nom = value;
  set commerce(String value) => _commerce = value;
  set keywords(List<String> value) => _keywords = value;
  set price(int value) => _price = value;
  set unite(String value) => _unite = value;
  set options(List<Option> value) => _options = value;

  // Convertir l'objet en Map pour Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'nom': _nom,
      'commerce': _commerce,
      'keywords': _keywords,
      'couleur': couleur.value, // Stocke la valeur entière de la couleur
      'price': _price,
      'unite': _unite,
      'options': _options.map((option) => option.toJson()).toList(),
    };
  }

  // Créer un objet Categorie à partir d'une Map (retour de Firestore)
  static Categorie fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: json['id'],
      nom: json['nom'],
      couleur: Color(json['couleur'] as int),
      commerce: json['commerce'],
      keywords: List<String>.from(json['keywords']),
      price: json['price'],
      unite: json['unite'],
      options: (json['options'] as List)
          .map((item) => Option.fromJson(item))
          .toList(),
    );
  }

  static Future<Categorie?> get(String id) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection("categories").doc(id).get();
    if (doc.exists) {
      return Categorie.fromJson(doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  // Méthodes CRUD pour Firestore
  Future<void> create() async {
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(_id)
        .set(toJson());
  }

  static Stream<List<Categorie>> streamCategories(String commerceId) {
    return FirebaseFirestore.instance
        .collection('categories')
        .where("commerce", isEqualTo: commerceId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> read(String id) async {
    var doc =
        await FirebaseFirestore.instance.collection('categories').doc(id).get();
    if (doc.exists) {
      Categorie.fromJson(doc.data() as Map<String, dynamic>);
    }
  }

  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(_id)
        .update(toJson());
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection('categories').doc(_id).delete();
  }

  // Méthodes supplémentaires qui pourraient être utiles
  static Future<List<Categorie>> getCategoriesByCommerce(
      String commerceId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .where('commerce', isEqualTo: commerceId)
        .get();
    return querySnapshot.docs
        .map((doc) => Categorie.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Categorie>> searchByKeyword(String keyword) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .where('keywords', arrayContains: keyword)
        .get();
    return querySnapshot.docs
        .map((doc) => Categorie.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addOption(Option option) async {
    _options.add(option);
    await update();
  }

  Future<void> removeOption(Option option) async {
    _options.remove(option);
    await update();
  }
}
