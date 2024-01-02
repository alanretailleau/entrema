import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

// Product model
import 'package:cloud_firestore/cloud_firestore.dart';

// Product model
class Product {
  String _id;
  List<String> _barcode;
  String _nom;
  String _categorieId;
  int _price;
  Color _couleur;
  List<String> _keywords;
  String _unite;
  List<Option> _options;
  String _url;
  double _poids;
  List<String> _item;
  int _surstock;
  int _rupture;

  Product({
    required String id,
    required Color couleur,
    required List<String> barcode,
    required String nom,
    required String categorieId,
    required int price,
    required int surstock,
    required double poids,
    required int rupture,
    required List<String> keywords,
    required String unite,
    required List<Option> options,
    required String url,
    required List<String> item,
  })  : _id = id,
        _surstock = surstock,
        _rupture = rupture,
        _couleur = couleur,
        _barcode = barcode,
        _nom = nom,
        _categorieId = categorieId,
        _price = price,
        _keywords = keywords,
        _unite = unite,
        _options = options,
        _poids = poids,
        _url = url,
        _item = item;

  // Convertit un Product en Map pour l'enregistrement dans Firestore
  Map<String, dynamic> toJson() {
    return {
      'barcode': _barcode,
      'couleur': couleur.value, // Stocke la valeur entière de la couleur
      'id': _id,
      "surstock": _surstock,
      "poids": _poids,
      "rupture": _rupture,
      'nom': _nom,
      'categorieId': _categorieId,
      'price': _price,
      'keywords': _keywords,
      'unite': _unite,
      'options': _options.map((option) => option.toJson()).toList(),
      'url': _url,
      'item': _item,
    };
  }

  // Crée un Product à partir d'une Map, utilisée pour la lecture depuis Firestore
  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      couleur: Color(json['couleur'] as int),
      rupture: json["rupture"],
      surstock: json["surstock"],
      barcode: List<String>.from(json['barcode']),
      id: json['id'],
      nom: json['nom'],
      categorieId: json['categorieId'],
      price: json['price'],
      keywords: List<String>.from(json['keywords']),
      unite: json['unite'],
      poids: json["poids"].toDouble(),
      options: (json['options'] as List)
          .map((optionJson) => Option.fromJson(optionJson))
          .toList(),
      url: json['url'],
      item: List<String>.from(json['item']),
      // Assurez-vous de gérer les types correctement
    );
  }

  // Getters
  String get id => _id;
  double get poids => _poids;
  List<String> get barcode => _barcode;
  String get nom => _nom;
  String get categorieId => _categorieId;
  int get rupture => _rupture;
  int get surstock => _surstock;
  int get price => _price;
  List<String> get keywords => _keywords;
  String get unite => _unite;
  List<Option> get options => _options;
  String get url => _url;
  List<String> get item => _item;

  Color get couleur => _couleur;
  set couleur(Color value) => _couleur = value;

  // Setters
  set poids(double value) => _poids = value;
  set barcode(List<String> value) => _barcode = value;
  set surstock(int value) => _surstock = value;
  set rupture(int value) => _rupture = value;
  set nom(String value) => _nom = value;
  set categorieId(String value) => _categorieId = value;
  set price(int value) => _price = value;
  set keywords(List<String> value) => _keywords = value;
  set unite(String value) => _unite = value;
  set options(List<Option> value) => _options = value;
  set url(String value) => _url = value;
  set item(List<String> value) => _item = value;

  // Méthode pour créer un nouveau produit dans Firestore
  Future<void> create() async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(_id)
        .set(toJson());
  }

  static Stream<List<Product>> streamProducts(String categorie) {
    return FirebaseFirestore.instance
        .collection('products')
        .where("categorieId", isEqualTo: categorie)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromJson(doc.data())).toList());
  }

  static Future<List<Product>> getProductsByCategorie(
      String categorieId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('categorieId', isEqualTo: categorieId)
        .get();
    return querySnapshot.docs
        .map((doc) => Product.fromJson(doc.data()))
        .toList();
  }

  // Méthode pour lire un produit par son ID
  static Future<Product?> read(String productId) async {
    var doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();
    return doc.exists ? fromJson(doc.data() as Map<String, dynamic>) : null;
  }

  // Méthode pour mettre à jour un produit existant dans Firestore
  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(_id)
        .update(toJson());
  }

  // Méthode pour supprimer un produit de Firestore
  Future<void> delete() async {
    await FirebaseFirestore.instance.collection('products').doc(_id).delete();
  }

  // Méthode pour récupérer un produit par son code-barres
  static Future<Product?> getByBarcode(String barcode) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('barcode', arrayContains: barcode)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return fromJson(querySnapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Méthode pour ajouter un barcode
  void addBarcode(String newBarcode) {
    if (!_barcode.contains(newBarcode)) {
      _barcode.add(newBarcode);
    }
  }

  // Méthode pour supprimer un barcode
  void removeBarcode(String oldBarcode) {
    _barcode.remove(oldBarcode);
  }

  // Méthode pour ajouter une option
  void addOption(Option option) {
    _options.add(option);
  }

  // Méthode pour supprimer une option
  void removeOption(Option option) {
    _options.removeWhere(
        (opt) => opt.name == option.name && opt.price == option.price);
  }

  // Méthode pour mettre à jour la quantité en stock
  void addItem(String newItem) {
    _item.add(newItem);
  }

  void removeItem(String oldItem) {
    _item.remove(oldItem);
  }

  // Méthodes CRUD classiques pour Firestore (create, read, update, delete)
  // ...
}

class Option {
  String name;
  int price;

  Option({required this.name, required this.price});

  Map<String, dynamic> toJson() {
    return {
      'nom': name,
      'price': price,
    };
  }

  static Option fromJson(Map<String, dynamic> json) {
    return Option(
      name: json['nom'],
      price: json['price'].round(),
    );
  }
}

class ProduitScan {
  Product produit;
  double poids;
  int? price;

  ProduitScan({required this.produit, required this.poids, this.price});

  Map<String, dynamic> toJson() {
    return {
      'produit': produit.toJson(),
      'poids': poids,
      'price': price,
    };
  }

  

  static ProduitScan fromJson(Map<String, dynamic> json) {
    return ProduitScan(
        produit: Product.fromJson(json['produit']),
        poids: json['poids'],
        price: json['price']);
  }
}
