import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction2 {
  // Déclaration des variables
  String _id;
  DateTime _date;
  String _userId;
  int _amount;
  String _description;
  TransactionType _type;
  String _adherent;
  String _method;
  String _commerce;

  // Constructeur
  Transaction2({
    required String id,
    required String adherent,
    required String commerce,
    required DateTime date,
    required String userId,
    required int amount,
    required String description,
    required TransactionType type,
    required String method,
  })  : _id = id,
        _date = date,
        _adherent = adherent,
        _commerce = commerce,
        _userId = userId,
        assert(amount >= 0, "Le montant doit être positif ou nul"),
        _amount = amount,
        _description = description,
        _type = type,
        _method = method;

  // Getters
  String get id => _id;
  String get adherent => _adherent;
  String get commerce => _commerce;
  DateTime get date => _date;
  String get userId => _userId;
  int get amount => _amount;
  String get description => _description;
  TransactionType get type => _type;

  String get method => _method;

  // Setters
  set date(DateTime value) => _date = value;
  set adherent(String value) => _adherent = value;
  set amount(int value) => _amount = value;
  set description(String value) => _description = value;
  set type(TransactionType value) => _type = value;
  set method(String value) => _method = value;

  // Convertir l'objet en Map
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'date': _date,
      'adherent': _adherent,
      'userId': _userId,
      'amount': _amount,
      'description': _description,
      'type': _type.toString().split('.').last,
      'method': _method,
    };
  }

  // Créer un objet Transaction à partir d'une Map
  static Transaction2 fromJson(Map<String, dynamic> json) {
    return Transaction2(
      adherent: json["adherent"],
      id: json['id'],
      date: json['date'].toDate(),
      userId: json['userId'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      type: TransactionType.values
          .firstWhere((e) => e.toString().split('.').last == json['type']),
      method: json['method'],
      commerce: json['commerce'],
    );
  }

  // Méthodes CRUD pour Firestore
  Future<void> create() async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(_id)
        .set(toJson());
  }

  Future<void> read(String id) async {
    var doc = await FirebaseFirestore.instance
        .collection('transactions')
        .doc(id)
        .get();
    if (doc.exists) {
      Transaction2.fromJson(doc.data() as Map<String, dynamic>);
    }
  }

  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(_id)
        .update(toJson());
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(_id)
        .delete();
  }

  // Méthode pour récupérer l'historique des transactions d'un utilisateur
  static Future<List<Transaction2>> getUserTransactionHistory(
      String userId, DateTime start, DateTime end) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();

    return querySnapshot.docs
        .map((doc) => Transaction2.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Méthode pour calculer le total des dépenses
  static Future<int> getTotalExpenses(
      String userId, DateTime start, DateTime end) async {
    var transactions = await getUserTransactionHistory(userId, start, end);
    // Utilisez directement un double pour garder le total, pas un FutureOr<double>.
    int total = 0;
    // Accumulez le total de manière synchrone, car les transactions sont déjà chargées.
    for (var transaction in transactions) {
      if (transaction.amount < 0) {
        total += transaction.amount;
      }
    }
    return total;
  }

  // Méthode pour calculer le solde actuel
  static Future<int> getCurrentBalance(String userId) async {
    var transactions =
        await getUserTransactionHistory(userId, DateTime(2000), DateTime.now());
    int total = 0;
    // Accumulez le total de manière synchrone, car les transactions sont déjà chargées.
    for (var transaction in transactions) {
      total += transaction.amount;
    }
    return total;
  }
}

enum TransactionType { debit, credit }
