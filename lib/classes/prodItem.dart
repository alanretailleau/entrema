import 'package:cloud_firestore/cloud_firestore.dart';

class ProductItem {
  String _produitId;
  DateTime _creationDate;
  DateTime? _soldDate;
  DateTime? _peremption;
  String? _lot;

  ProductItem(
      {required String produitId,
      required DateTime creationDate,
      required DateTime? soldDate,
      required String? lot,
      required DateTime? peremption})
      : _produitId = produitId,
        _lot = lot,
        _creationDate = creationDate,
        _peremption = peremption,
        _soldDate = soldDate;

  // Getters
  String get produitId => _produitId;
  String? get lot => _lot;
  DateTime get creationDate => _creationDate;
  DateTime? get soldDate => _soldDate;
  DateTime? get peremption => _peremption;

  // Setters
  set produitId(String value) => _produitId = value;
  set lot(String? value) => _lot = value;
  set creationDate(DateTime value) => _creationDate = value;
  set soldDate(DateTime? value) => _soldDate = value;
  set peremption(DateTime? value) => _peremption = value;

  // Convertir l'objet en Map pour Firestore
  Map<String, dynamic> toJson() {
    return {
      'produitId': produitId,
      "lot": lot,
      'creationDate': creationDate,
      'soldDate': soldDate,
      "peremption": peremption
    };
  }

  // Créer un objet LivraisonElement à partir d'une Map
  static ProductItem fromJson(Map<String, dynamic> json) {
    return ProductItem(
        lot: json["lot"],
        produitId: json['produitId'],
        creationDate: json['creationDate'].toDate(),
        soldDate: json['soldDate'] != null ? json["soldDate"].toDate() : null,
        peremption:
            json['peremption'] != null ? json["peremption"].toDate() : null);
  }

  // Méthodes CRUD pour Firestore
  Future<void> create() async {
    await FirebaseFirestore.instance.collection('productItem').add(toJson());
  }

  static Future<ProductItem> read(String id) async {
    var doc = await FirebaseFirestore.instance
        .collection('productItem')
        .doc(id)
        .get();
    if (!doc.exists) {
      throw Exception('Item non trouvé');
    }
    return ProductItem.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<void> update(String id) async {
    await FirebaseFirestore.instance
        .collection('productItem')
        .doc(id)
        .update(toJson());
  }

  Future<void> delete(String id) async {
    await FirebaseFirestore.instance.collection('productItem').doc(id).delete();
  }
}
