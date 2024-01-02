import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/role.dart';
import 'package:entrema/maths/romanScript.dart';
import 'package:flutter/material.dart';

class User {
  bool _admin;
  String _id;
  Color _couleur;
  DateTime _dateCreation;
  double _cguVersion;
  List<String> _fav;
  String? _commerce;
  String _langue;
  String _prenom;
  bool _bloque;
  String _nom;
  List<String> _searchTerm;
  String _email;
  String? _url;

  User({
    required bool admin,
    required String id,
    required Color couleur,
    required DateTime dateCreation,
    required double cguVersion,
    required List<String> fav,
    String? commerce,
    required String langue,
    required String prenom,
    required bool bloque,
    required String nom,
    required List<String> searchTerm,
    required String email,
    String? url,
  })  : _admin = admin,
        _id = id,
        _couleur = couleur,
        _dateCreation = dateCreation,
        _cguVersion = cguVersion,
        _fav = fav,
        _commerce = commerce,
        _langue = langue,
        _prenom = prenom,
        _bloque = bloque,
        _nom = nom,
        _searchTerm = searchTerm,
        _email = email,
        _url = url {
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

  // Getter et setter pour admin
  bool get admin => _admin;
  set admin(bool value) => _admin = value;

  // Getter et setter pour id
  String get id => _id;
  set id(String value) {
    if (value.isNotEmpty) {
      _id = value;
    } else {
      throw ArgumentError('L\'ID ne peut pas être vide');
    }
  }

  // Getter et setter pour couleur
  Color get couleur => _couleur;
  set couleur(Color value) => _couleur = value;

  // Getter et setter pour dateCreation
  DateTime get dateCreation => _dateCreation;
  set dateCreation(DateTime value) => _dateCreation = value;

  // Getter et setter pour cguVersion
  double get cguVersion => _cguVersion;
  set cguVersion(double value) {
    if (value > 0) {
      _cguVersion = value;
    } else {
      throw ArgumentError('La version CGU doit être positive');
    }
  }

  // Getter et setter pour fav
  List<String> get fav => _fav;
  set fav(List<String> fav) => _fav = fav;

  // Getter et setter pour bloque
  bool get bloque => _bloque;
  set bloque(bool value) => _bloque = value;

  // Getter et setter pour langue
  String get langue => _langue;
  set langue(String value) {
    if (value.isNotEmpty) {
      _langue = value;
    }
  }

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

  // Getter et setter pour email
  String get email => _email;
  set email(String value) {
    if (_validateEmail(value)) {
      _email = value;
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

  // Getter et setter pour url
  String? get url => _url;
  set url(String? value) {
    if (value == null || _validateURL(value)) {
      _url = value;
    }
  }

  // Valider l'email
  bool _validateEmail(String email) {
    // Simple regex for demonstration; consider a more robust implementation
    return RegExp(r'\S+@\S+\.\S+').hasMatch(email);
  }

  // Valider l'URL
  bool _validateURL(String url) {
    // Simple regex for demonstration; consider a more robust implementation
    return RegExp(r'https?:\/\/[\w\-]+(\.[\w\-]+)+\S*').hasMatch(url);
  }

  // Convertit un User en Map pour l'enregistrement dans Firestore
  Map<String, dynamic> toJson() {
    return {
      'admin': admin,
      'id': id,
      'couleur': couleur.value, // Stocke la valeur entière de la couleur
      'dateCreation': Timestamp.fromDate(dateCreation),
      'cguVersion': cguVersion,
      'fav': fav,
      'commerce': _commerce,
      'langue': _langue,
      'prenom': _prenom,
      'bloque': bloque,
      'nom': _nom,
      'searchTerm': _searchTerm,
      'email': _email,
      'url': _url,
    };
  }

  // Crée un User à partir d'une Map, utilisée pour la lecture depuis Firestore
  static User fromJson(Map<String, dynamic> json) {
    return User(
      admin: json['admin'] as bool,
      id: json['id'] as String,
      couleur: Color(json['couleur'] as int),
      dateCreation: (json['dateCreation'] as Timestamp).toDate(),
      cguVersion: json['cguVersion'].toDouble(),
      fav: List<String>.from(json['fav']),
      commerce: json['commerce'] as String?,
      langue: json['langue'] as String,
      prenom: json['prenom'] as String,
      bloque: json['bloque'] as bool,
      nom: json['nom'] as String,
      searchTerm: List<String>.from(json['searchTerm']),
      email: json['email'] as String,
      url: json['url'] as String?,
    );
  }

  // ... opérations CRUD

  // Crée un nouvel utilisateur dans Firestore
  Future<bool> create() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .set(toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  List<Autorisation> getAuth(Commerce commerce) {
    List<Autorisation> auth = [];
    for (var i = 0; i < commerce.team.length; i++) {
      if (commerce.team[i].userId == id &&
          commerce.roles
              .where((element) => element.id == commerce.team[i].roleId)
              .isNotEmpty) {
        List<Autorisation> auto = commerce.roles
            .firstWhere((element) => element.id == commerce.team[i].roleId)
            .autorisations;
        for (var j = 0; j < auto.length; j++) {
          if (!auth.contains(auto[j])) {
            auth.add(auto[j]);
          }
        }
      }
    }
    return auth;
  }

  // Lit un utilisateur de Firestore par son ID
  static Future<User?> read(String id) async {
    var doc =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    return doc.exists ? fromJson(doc.data() as Map<String, dynamic>) : null;
  }

  // Stream les changements d'un utilisateur
  static Stream<User?> streamUser(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.exists
            ? fromJson(snapshot.data() as Map<String, dynamic>)
            : null);
  }

  static Stream<List<User>> streamUsers(String searchTerm) {
    return FirebaseFirestore.instance
        .collection('users')
        .where("searchTerm",
            arrayContains: removeDiacritics(searchTerm.toLowerCase()))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Met à jour un utilisateur dans Firestore
  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update(toJson());
  }

  // Supprime un utilisateur de Firestore
  Future<void> delete() async {
    await FirebaseFirestore.instance.collection('users').doc(id).delete();
  }
}
