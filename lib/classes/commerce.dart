import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/classes/role.dart';
import 'package:entrema/classes/team.dart';

class Commerce {
  String _nom;
  String _admin;
  Color _couleur;
  String _id;
  String _type;
  List<Role> _roles;
  List<Team> _team;
  List<String> _teamList;
  Monnaie _monnaie;
  List<Map<String, dynamic>> _dataAdherent;
  List<String> _ban;
  GeoPoint _localisation;

  Commerce({
    required String nom,
    required List<Map<String, dynamic>> dataAdherent,
    required String admin,
    required String id,
    required Color couleur,
    required String type,
    required List<Role> roles,
    required List<Team> team,
    required List<String> teamList,
    required Monnaie monnaie,
    required List<String> ban,
    required GeoPoint localisation,
  })  : _nom = nom,
        _admin = admin,
        _id = id,
        _type = type,
        _couleur = couleur,
        _roles = roles,
        _team = team,
        _teamList = teamList,
        _monnaie = monnaie,
        _ban = ban,
        _localisation = localisation,
        _dataAdherent = dataAdherent;
  // Getters
  String get nom => _nom;

  List<Map<String, dynamic>> get dataAdherent => _dataAdherent;
  String get admin => _admin;
  String get id => _id;
  String get type => _type;
  List<Role> get roles => _roles;
  List<Team> get team => _team;
  List<String> get teamList => _teamList;
  Monnaie get monnaie => _monnaie;
  Color get couleur => _couleur;
  set couleur(Color value) => _couleur = value;

  List<String> get ban => _ban;
  GeoPoint get localisation => _localisation;

  // Setters
  set nom(String value) => _nom = value;
  set dataAdherent(List<Map<String, dynamic>> value) => _dataAdherent = value;
  set admin(String value) => _admin = value;
  set type(String value) => _type = value;
  set roles(List<Role> value) => _roles = value;
  set team(List<Team> value) {
    _team = value;
  }

  set teamList(List<String> value) => _teamList = value;

  set monnaie(Monnaie value) => _monnaie = value;
  set ban(List<String> value) => _ban = value;
  set localisation(GeoPoint value) => _localisation = value;

  Map<String, dynamic> toJson() {
    return {
      'nom': _nom,
      'admin': _admin,
      'dataAdherent': _dataAdherent,
      'id': _id,
      'type': _type,
      'roles': _roles.map((role) => role.id).toList(),
      'team': _team
          .map((team) => {'userId': team.userId, 'roleId': team.roleId})
          .toList(),
      'teamList': _teamList,
      'couleur': couleur.value, // Stocke la valeur entière de la couleur
      'monnaie': _monnaie
          .toString()
          .split('.')
          .last, // Convertir l'énumération en String pour Firestore
      'ban': _ban,
      'localisation': _localisation,
    };
  }

  // Créer un objet Commerce à partir d'une Map (retour de Firestore)
  static Future<Commerce> fromJson(Map<String, dynamic> json, String id) async {
    List<String> roleIds = List<String>.from(json['roles']);
    List<Role> roles = [];

    for (String roleId in roleIds) {
      try {
        roles.add(await Role.read(roleId));
      } catch (e) {
        // Gérer l'erreur ou ignorer le rôle non trouvé
      }
    }
    return Commerce(
      dataAdherent: List<Map<String, dynamic>>.from(json["dataAdherent"]),
      nom: json['nom'],
      teamList: List<String>.from(json["teamList"]),
      couleur: Color(json['couleur'] as int),
      admin: json['admin'],
      id: id,
      type: json['type'],
      roles: roles,
      team: (json['team'] as List)
          .map((item) => Team(userId: item['userId'], roleId: item['roleId']))
          .toList(),
      monnaie: Monnaie.values.firstWhere((e) =>
          e.toString().split('.').last.toLowerCase() ==
          json['monnaie'].toLowerCase()),
      ban: List<String>.from(json['ban']),
      localisation: json['localisation'],
    );
  }

  // Méthode pour créer un commerce dans Firestore
  Future<void> create() async {
    await FirebaseFirestore.instance
        .collection('commerces')
        .doc(_id)
        .set(toJson());
  }

  // Méthode pour lire les informations d'un commerce
  static Future<Commerce> read(String id) async {
    var doc =
        await FirebaseFirestore.instance.collection('commerces').doc(id).get();
    if (!doc.exists) {
      print("pas de commerce");
      throw Exception('Commerce non trouvé');
    }
    return Commerce.fromJson(doc.data() as Map<String, dynamic>, id);
  }

  // Méthode pour mettre à jour un commerce
  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection('commerces')
        .doc(_id)
        .update(toJson());
  }

  // Méthode pour supprimer un commerce
  Future<void> delete() async {
    await FirebaseFirestore.instance.collection('commerces').doc(_id).delete();
  }

  void ajouterRole(Role role) {
    _roles.add(role);
  }

  void supprimerRole(String roleId) {
    _roles.removeWhere((role) => role.id == roleId);
  }

  void ajouterMembreEquipe(Team membre) {
    _team.add(membre);
    _teamList.add(membre.userId);
  }

  void retirerMembreEquipe(String userId) {
    _team.removeWhere((membre) => membre.userId == userId);
    _teamList.remove(userId);
  }

  void bannirUtilisateur(String userId) {
    _ban.add(userId);
    update(); // Mettre à jour dans Firestore
  }

  void debannirUtilisateur(String userId) {
    _ban.remove(userId);
    update(); // Mettre à jour dans Firestore
  }

  void miseAJourLocalisation(GeoPoint nouvelleLocalisation) {
    _localisation = nouvelleLocalisation;
  }
}

enum Monnaie {
  euro,
  dollar,
  yen,
  livreSterling,
  // ... Ajoutez d'autres devises selon vos besoins ...
}

enum Type { booleen, texte, entier, float }

class DataAdherent {
  String nom;
  Type type;
  bool required;
  var byDefault;

  DataAdherent(
      {required this.nom,
      required this.type,
      required this.required,
      required this.byDefault});

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'type': type.toString(),
      'required': required,
      'default': byDefault
    };
  }

  static DataAdherent fromJson(Map<String, dynamic> json) {
    return DataAdherent(
        nom: json['nom'],
        type: Type.values.firstWhere((e) =>
            e.toString().split('.').last.toLowerCase() ==
            json['type'].toLowerCase()),
        required: json["required"],
        byDefault: json["default"]);
  }
}
