import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Adherent {
  String _id;
  DateTime _dateCreation;
  String? _commerce;
  String _prenom;
  bool _bloque;
  String _nom;
  int _solde;
  List<String> _searchTerm;
  List<Map<String, dynamic>> _data;

  Adherent({
    required int solde,
    required String id,
    required DateTime dateCreation,
    String? commerce,
    required String prenom,
    required bool bloque,
    required String nom,
    required List<String> searchTerm,
    required List<Map<String, dynamic>> data,
  })  : _id = id,
        _dateCreation = dateCreation,
        _commerce = commerce,
        _prenom = prenom,
        _bloque = bloque,
        _solde = solde,
        _nom = nom,
        _searchTerm = searchTerm,
        _data = data {
    // Initialise the searchTerm with nom and prenom
    _updateSearchTerm();
  }

  // Getters and setters with validation and searchTerm update
  String get commerce => _commerce ?? '';
  set commerce(String? value) {
    if (value != null && value.isNotEmpty) {
      _commerce = value;
    }
  }

  // Getter et setter pour id
  String get id => _id;
  set id(String value) {
    if (value.isNotEmpty) {
      _id = value;
    } else {
      throw ArgumentError('L\'ID ne peut pas être vide');
    }
  }

  int get solde => _solde;
  set solde(int value) {
    if (solde > 0) {
      _solde = value;
    } else {
      _solde = value;
      throw ArgumentError('Le solde est négatif !!');
    }
  }

  // Getter et setter pour dateCreation
  DateTime get dateCreation => _dateCreation;
  set dateCreation(DateTime value) => _dateCreation = value;

  // Getter et setter pour bloque
  bool get bloque => _bloque;
  set bloque(bool value) => _bloque = value;

  // Getter et setter pour data
  List<Map<String, dynamic>> get data => _data;
  set data(List<Map<String, dynamic>> value) => _data = value;

  // Getter et setter pour prenom
  String get prenom => _prenom;
  set prenom(String value) {
    if (value.isNotEmpty) {
      _prenom = value;
      _updateSearchTerm();
    }
  }

  // Getter et setter pour nom
  String get nom => _nom;
  set nom(String value) {
    if (value.isNotEmpty) {
      _nom = value;
      _updateSearchTerm();
    }
  }

  // Méthode privée pour générer les searchTerm
  void _updateSearchTerm() {
    // On crée des listes pour le prénom et le nom avec toutes les sous-chaînes possibles.
    final prenomSubstrings = _allSubstrings(_prenom);
    final nomSubstrings = _allSubstrings(_nom);

    // On combine les sous-chaînes du prénom et du nom en les espaçant.
    final combinedSubstrings = [
      ...prenomSubstrings,
      ...nomSubstrings,
      ...prenomSubstrings.expand((prenomSub) => nomSubstrings
          .map((nomSub) => '$prenomSub $nomSub')
          .where((s) => s.trim().split(' ').length > 1)),
    ];

    // On ajoute les sous-chaînes du nom suivies d'un espace et du prénom.
    combinedSubstrings.addAll(nomSubstrings
        .map((nomSub) => '$nomSub $_prenom')
        .where((s) => s.trim().split(' ').length > 1));

    // On s'assure qu'il n'y a pas de doublons.
    _searchTerm = combinedSubstrings.toSet().toList();
  }

  // Méthode privée pour obtenir toutes les sous-chaînes d'une chaîne donnée.
  List<String> _allSubstrings(String string) {
    final List<String> substrings = [];
    for (int i = 0; i < string.length; i++) {
      for (int j = i + 1; j <= string.length; j++) {
        substrings.add(string.substring(i, j).toLowerCase());
      }
    }
    return substrings;
  }

  static Future<List<Adherent>> getAdherentsByCommerce(
      String commerceId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('adherents')
        .where('commerce', isEqualTo: commerceId)
        .get();
    return querySnapshot.docs
        .map((doc) => Adherent.fromJson(doc.data()))
        .toList();
  }

  // Valider l'email
  bool _validateEmail(String email) {
    // Simple regex for demonstration; consider a more robust implementation
    return RegExp(r'\S+@\S+\.\S+').hasMatch(email);
  }

  // Convertit un User en Map pour l'enregistrement dans Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'solde': _solde,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'commerce': _commerce,
      'prenom': _prenom,
      'bloque': bloque,
      'nom': _nom,
      'searchTerm': _searchTerm,
      'data': _data,
    };
  }

  // Crée un User à partir d'une Map, utilisée pour la lecture depuis Firestore
  static Adherent fromJson(Map<String, dynamic> json) {
    return Adherent(
        solde: json["solde"] as int,
        id: json['id'] as String,
        dateCreation: (json['dateCreation'] as Timestamp).toDate(),
        commerce: json['commerce'] as String?,
        prenom: json['prenom'] as String,
        bloque: json['bloque'] as bool,
        nom: json['nom'] as String,
        searchTerm: List<String>.from(json['searchTerm']),
        data: List<Map<String, dynamic>>.from(json["data"]));
  }

  // ... opérations CRUD

  // Crée un nouvel utilisateur dans Firestore
  Future<bool> create() async {
    try {
      await FirebaseFirestore.instance
          .collection('adherents')
          .doc(id)
          .set(toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Lit un utilisateur de Firestore par son ID
  static Future<Adherent?> read(String id) async {
    var doc =
        await FirebaseFirestore.instance.collection('adherents').doc(id).get();
    return doc.exists ? fromJson(doc.data() as Map<String, dynamic>) : null;
  }

  // Stream les changements d'un utilisateur
  static Stream<Adherent?> streamAdherent(String uid) {
    return FirebaseFirestore.instance
        .collection('adherents')
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.exists
            ? fromJson(snapshot.data() as Map<String, dynamic>)
            : null);
  }

  static Stream<List<Adherent>> streamAdherents(String commerceId) {
    return FirebaseFirestore.instance
        .collection('adherents')
        .where("commerce", isEqualTo: commerceId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Met à jour un utilisateur dans Firestore
  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection('adherents')
        .doc(id)
        .update(toJson());
  }

  // Supprime un utilisateur de Firestore
  Future<void> delete() async {
    await FirebaseFirestore.instance.collection('adherents').doc(id).delete();
  }
}
