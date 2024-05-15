import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/maths/romanScript.dart';
import 'package:entrema/widget/button.dart';
import 'package:entrema/widget/money.dart';
import 'package:flutter/material.dart';

class Adherent {
  String _id;
  DateTime _dateCreation;
  String _commerce;
  String _prenom;
  bool _updateB = false;
  bool _bloque;
  String _nom;
  String _customId;
  DateTime _lastUpdate;
  int _solde;
  List<String> _searchTerm;
  List<Map<String, dynamic>> _data;

  Adherent({
    bool updateB = false,
    required int solde,
    required String id,
    required DateTime lastUpdate,
    required String customId,
    required DateTime dateCreation,
    required String commerce,
    required String prenom,
    required bool bloque,
    required String nom,
    required List<String> searchTerm,
    required List<Map<String, dynamic>> data,
  })  : _id = id,
        _dateCreation = dateCreation,
        _lastUpdate = lastUpdate,
        _updateB = updateB,
        _commerce = commerce,
        _prenom = prenom,
        _customId = customId,
        _bloque = bloque,
        _solde = solde,
        _nom = nom,
        _searchTerm = searchTerm,
        _data = data {
    // Initialise the searchTerm with nom and prenom
    _updateSearchTerm();
  }

  // Getters and setters with validation and searchTerm update
  String get commerce => _commerce;
  set commerce(String value) {
    if (value.isNotEmpty) {
      _commerce = value;
    }
  }

  String get customId => _customId;
  set customId(String value) {
    if (value.isNotEmpty) {
      _customId = value;
      _updateSearchTerm();
    }
  }

  bool get updateB => _updateB;
  set updateB(bool value) {
    _updateB = value;
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

  DateTime get lastUpdate => _lastUpdate;
  set lastUpdate(DateTime value) => _lastUpdate = value;

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
    final idCustomSubstrings = _allSubstrings(_customId);

    // On combine les sous-chaînes du prénom et du nom en les espaçant.
    final combinedSubstrings = [
      ...idCustomSubstrings,
      ...prenomSubstrings,
      ...nomSubstrings,
      ...prenomSubstrings.expand((prenomSub) => nomSubstrings
          .map((nomSub) => '${_nom.toLowerCase()} $prenomSub')
          .where((s) => s.trim().split(' ').length > 1)),
    ];

    // On ajoute les sous-chaînes du nom suivies d'un espace et du prénom.
    combinedSubstrings.addAll(nomSubstrings
        .map((nomSub) => '${_prenom.toLowerCase()} $nomSub')
        .where((s) => s.trim().split(' ').length > 1));
    // On s'assure qu'il n'y a pas de doublons.
    _searchTerm = combinedSubstrings.toSet().toList();
  }

  // Méthode privée pour obtenir toutes les sous-chaînes d'une chaîne donnée.
  List<String> _allSubstrings(String string) {
    final List<String> substrings = [];
    for (int i = 0; i < string.length; i++) {
      substrings.add(string.substring(0, i + 1).toLowerCase());
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
      'lastUpdate': Timestamp.fromDate(lastUpdate),
      'dateCreation': Timestamp.fromDate(dateCreation),
      'commerce': _commerce,
      'customId': _customId,
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
        lastUpdate: (json["lastUpdate"] as Timestamp).toDate(),
        customId: json["customId"] as String,
        solde: json["solde"] as int,
        id: json['id'] as String,
        dateCreation: (json['dateCreation'] as Timestamp).toDate(),
        commerce: json['commerce'] as String,
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

  Widget show(BuildContext context,
      {Function()? onPressed, Color color = Colors.blue}) {
    return CustomButton(
      padding: const EdgeInsets.all(12),
      onPressed: onPressed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      child: Row(
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 1 / 3),
            child: Text(
              "$prenom $nom",
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: color.withOpacity(.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Image.asset(
                    "assets/icon/key.png",
                    color: color,
                    scale: 18,
                  ),
                  updateB
                      ? Container(
                          width: 5,
                          height: 5,
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10)),
                        )
                      : Container(),
                  const SizedBox(width: 5),
                  Text(customId,
                      style: TextStyle(
                          fontFamily: "Cocogoose",
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              )),
          Expanded(child: Container()),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: color.withOpacity(.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Money(
                  price: solde / 100,
                  style: TextStyle(
                      fontFamily: "Cocogoose",
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }

  static Stream<List<Adherent>> streamAdherents(String commerceId,
      {String? searchTerm, int limit = 100}) {
    if (searchTerm != null) {
      return FirebaseFirestore.instance
          .collection('adherents')
          .where("commerce", isEqualTo: commerceId)
          .where("searchTerm",
              arrayContains: removeDiacritics(searchTerm.toLowerCase()))
          .orderBy("lastUpdate", descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => fromJson(doc.data())).toList());
    }
    return FirebaseFirestore.instance
        .collection('adherents')
        .where("commerce", isEqualTo: commerceId)
        .orderBy("lastUpdate", descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromJson(doc.data())).toList());
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
