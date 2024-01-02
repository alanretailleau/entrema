import 'package:cloud_firestore/cloud_firestore.dart';

class LivraisonElement {
  String _livraisonId;
  String _produitId;
  int _quantite;

  LivraisonElement({
    required String livraisonId,
    required String produitId,
    required int quantite,
  })  : _livraisonId = livraisonId,
        _produitId = produitId,
        _quantite = quantite;

  // Getters
  String get livraisonId => _livraisonId;
  String get produitId => _produitId;
  int get quantite => _quantite;

  // Setters
  set livraisonId(String value) => _livraisonId = value;
  set produitId(String value) => _produitId = value;
  set quantite(int value) {
    if (value < 0) throw ArgumentError('La quantité ne peut pas être négative');
    _quantite = value;
  }

  // Convertir l'objet en Map pour Firestore
  Map<String, dynamic> toJson() {
    return {
      'livraisonId': _livraisonId,
      'produitId': _produitId,
      'quantite': _quantite,
    };
  }

  // Créer un objet LivraisonElement à partir d'une Map
  static LivraisonElement fromJson(Map<String, dynamic> json) {
    return LivraisonElement(
      livraisonId: json['livraisonId'],
      produitId: json['produitId'],
      quantite: json['quantite'],
    );
  }

  // Méthodes CRUD pour Firestore
  Future<void> create() async {
    await FirebaseFirestore.instance
        .collection('livraisonElements')
        .add(toJson());
  }

  static Future<LivraisonElement> read(String id) async {
    var doc = await FirebaseFirestore.instance
        .collection('livraisonElements')
        .doc(id)
        .get();
    if (!doc.exists) {
      throw Exception('Element de livraison non trouvé');
    }
    return LivraisonElement.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<void> update(String id) async {
    await FirebaseFirestore.instance
        .collection('livraisonElements')
        .doc(id)
        .update(toJson());
  }

  Future<void> delete(String id) async {
    await FirebaseFirestore.instance
        .collection('livraisonElements')
        .doc(id)
        .delete();
  }

  // Méthodes supplémentaires pertinentes

  // Trouver tous les éléments d'une livraison spécifique
  static Future<List<LivraisonElement>> findByLivraison(
      String livraisonId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('livraisonElements')
        .where('livraisonId', isEqualTo: livraisonId)
        .get();

    return querySnapshot.docs
        .map((doc) =>
            LivraisonElement.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Mettre à jour la quantité d'un élément
  void updateQuantite(int nouvelleQuantite) {
    if (nouvelleQuantite < 0)
      throw ArgumentError('La quantité ne peut pas être négative');
    _quantite = nouvelleQuantite;
    // Mettre à jour dans Firestore
  }
}
