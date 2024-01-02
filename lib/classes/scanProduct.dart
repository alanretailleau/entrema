import 'package:cloud_firestore/cloud_firestore.dart';

class ScanProduct {
  final String nom;
  final List<String> keywords;
  final List<String> categories;
  final String url;
  final String id;
  final bool exist;

  ScanProduct({
    required this.nom,
    this.keywords = const [],
    required this.categories,
    required this.id,
    required this.url,
    required this.exist,
  });

  factory ScanProduct.fromJson(Map<String, dynamic> doc) {
    return ScanProduct(
        exist: false,
        nom: doc['product_name'] ?? "",
        id: doc['_id'] ?? "",
        categories: List<String>.from(doc["categories"].split(", ") ?? []),
        keywords: List<String>.from(doc["_keywords"] ?? []),
        url: doc["image_front_url"] ?? "");
  }
  factory ScanProduct.fromDocument(DocumentSnapshot data) {
    Map<String, dynamic> doc = data.data() as Map<String, dynamic>;
    return ScanProduct(
        exist: true,
        nom: doc['nom'] ?? "",
        id: data.id,
        categories: List<String>.from(doc["categories"].split(", ") ?? []),
        keywords: List<String>.from(doc["keyword"] ?? []),
        url: doc["url"] ?? "");
  }
}
