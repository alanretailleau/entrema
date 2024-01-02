import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/classes/commerce.dart';

class Role {
  String _id;
  List<Autorisation> _autorisations;
  String _nom;

  Role({
    required String id,
    required List<Autorisation> autorisations,
    required String nom,
  })  : _id = id,
        _autorisations = autorisations,
        _nom = nom;

  // Getters
  String get id => _id;
  List<Autorisation> get autorisations => _autorisations;
  String get nom => _nom;

  // Setters
  set autorisations(List<Autorisation> value) => _autorisations = value;
  set nom(String value) => _nom = value;

  // Convertir l'objet en Map pour Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'autorisations': _autorisations
          .map((auth) => auth.toString().split('.').last)
          .toList(),
      'nom': _nom,
    };
  }

  // Créer un objet Role à partir d'une Map (retour de Firestore)
  static Role fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      autorisations: (json['autorisations'] as List)
          .map((auth) => Autorisation.values
              .firstWhere((e) => e.toString().split('.').last == auth))
          .toList(),
      nom: json['nom'],
    );
  }

  // Méthodes CRUD pour Firestore
  Future<void> create(Commerce commerce) async {
    await FirebaseFirestore.instance.collection('roles').doc(_id).set(toJson());
    commerce.roles.add(this);
    commerce.update();
  }

  static Future<Role> read(String id) async {
    var doc =
        await FirebaseFirestore.instance.collection('roles').doc(id).get();
    if (!doc.exists) {
      throw Exception('Role non trouvé');
    }
    return Role.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection('roles')
        .doc(_id)
        .update(toJson());
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection('roles').doc(_id).delete();
  }

  // Méthodes supplémentaires pertinentes
  void ajouterAutorisation(Autorisation autorisation) {
    if (!_autorisations.contains(autorisation)) {
      _autorisations.add(autorisation);
      update(); // Mettre à jour dans Firestore
    }
  }

  void retirerAutorisation(Autorisation autorisation) {
    _autorisations.remove(autorisation);
    update(); // Mettre à jour dans Firestore
  }
}

enum Autorisation {
  Inventaire,
  Finance,
  Caisse,
  RH,
  Stats,
  Alertes,
  Livraison,
  // Ajoutez d'autres autorisations selon vos besoins
}

extension AutorisationDesc on Autorisation {
  String get nom {
    switch (this) {
      case Autorisation.Inventaire:
        return 'Gestion des Produits et Stocks';
      case Autorisation.Finance:
        return 'Gestion Financière';
      case Autorisation.Caisse:
        return 'Opérations de Caisse';
      case Autorisation.RH:
        return 'Gestion des Ressources Humaines';
      case Autorisation.Stats:
        return 'Analyse et Statistiques';
      case Autorisation.Alertes:
        return 'Gestion des Alertes';
      case Autorisation.Livraison:
        return 'Suivi des Livraisons';
      // Ajoutez d'autres descriptions selon vos besoins
      default:
        return 'Non spécifié';
    }
  }

  String get description {
    switch (this) {
      case Autorisation.Inventaire:
        return 'Ajout, modification, suppression de produits, gestion des stocks et des catégories, création et gestion de promotions.';
      case Autorisation.Finance:
        return 'Suivi des ventes, gestion de la trésorerie, suivi des entrées et sorties financières.';
      case Autorisation.Caisse:
        return 'Gestion des transactions en caisse, application des promotions, consultation des prix';
      case Autorisation.RH:
        return 'Gestion des rôles d\'équipe, administration des adhérents';
      case Autorisation.Stats:
        return 'Accès et analyse des données statistiques, suivi des performances de l\'épicerie';
      case Autorisation.Alertes:
        return 'Configuration et gestion des alertes';
      case Autorisation.Livraison:
        return 'Suivi des livraisons entrantes et sortantes, planification des nouvelles livraisons.';
      // Ajoutez d'autres descriptions selon vos besoins
      default:
        return 'Non spécifié';
    }
  }
}
