import 'package:cloud_firestore/cloud_firestore.dart';

class Livraison {
  GeoPoint _localisation;
  String _commerceId;
  DateTime _date;
  String _description;
  String _idUser;

  Livraison({
    required GeoPoint localisation,
    required String commerceId,
    required DateTime date,
    required String description,
    required String idUser,
  })  : _localisation = localisation,
        _commerceId = commerceId,
        _date = date,
        _description = description,
        _idUser = idUser;

  // Getters
  GeoPoint get localisation => _localisation;
  String get commerceId => _commerceId;
  DateTime get date => _date;
  String get description => _description;
  String get idUser => _idUser;

  // Setters
  set localisation(GeoPoint value) => _localisation = value;
  set commerceId(String value) => _commerceId = value;
  set date(DateTime value) => _date = value;
  set description(String value) => _description = value;
  set idUser(String value) => _idUser = value;

  // Convertir l'objet en Map pour Firestore
  Map<String, dynamic> toJson() {
    return {
      'localisation': _localisation,
      'commerceId': _commerceId,
      'date': _date,
      'description': _description,
      'idUser': _idUser,
    };
  }

  // Créer un objet Livraison à partir d'une Map
  static Livraison fromJson(Map<String, dynamic> json) {
    return Livraison(
      localisation: json['localisation'],
      commerceId: json['commerceId'],
      date: (json['date'] as Timestamp).toDate(),
      description: json['description'],
      idUser: json['idUser'],
    );
  }

  static Future<List<Livraison>> findByCommerce(String commerceId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('livraisons')
        .where('commerceId', isEqualTo: commerceId)
        .get();

    return querySnapshot.docs
        .map((doc) => Livraison.fromJson(doc.data()))
        .toList();
  }

  // Méthode pour créer une livraison dans Firestore
  Future<void> create() async {
    await FirebaseFirestore.instance.collection('livraisons').add(toJson());
  }

  // Méthode pour lire les informations d'une livraison
  static Future<Livraison> read(String id) async {
    var doc =
        await FirebaseFirestore.instance.collection('livraisons').doc(id).get();
    if (!doc.exists) {
      throw Exception('Livraison non trouvée');
    }
    return Livraison.fromJson(doc.data() as Map<String, dynamic>);
  }

  // Méthode pour mettre à jour une livraison
  Future<void> update(String id) async {
    await FirebaseFirestore.instance
        .collection('livraisons')
        .doc(id)
        .update(toJson());
  }

  // Méthode pour supprimer une livraison
  Future<void> delete(String id) async {
    await FirebaseFirestore.instance.collection('livraisons').doc(id).delete();
  }

  static Future<List<Livraison>> findByUser(
      String userId, String commerceId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('livraisons')
        .where('idUser', isEqualTo: userId)
        .where("commerceId", isEqualTo: commerceId)
        .get();

    return querySnapshot.docs
        .map((doc) => Livraison.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Livraison>> findByDate(
      DateTime date, String commerceId) async {
    var startOfDay = DateTime(date.year, date.month, date.day);
    var endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    var querySnapshot = await FirebaseFirestore.instance
        .collection('livraisons')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .where("commerceId", isEqualTo: commerceId)
        .get();

    return querySnapshot.docs
        .map((doc) => Livraison.fromJson(doc.data()))
        .toList();
  }
}
