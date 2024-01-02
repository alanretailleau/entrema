class Element {
  String _produitId;
  int _quantite;
  String _commandeId;

  Element({
    required String produitId,
    required int quantite,
    required String commandeId,
  })  : _produitId = produitId,
        _quantite = quantite,
        _commandeId = commandeId;

  // Getters
  String get produitId => _produitId;
  int get quantite => _quantite;
  String get commandeId => _commandeId;

  // Setters
  set produitId(String value) => _produitId = value;
  set quantite(int value) {
    if (value < 0) throw ArgumentError('La quantité ne peut pas être négative');
    _quantite = value;
  }

  set commandeId(String value) => _commandeId = value;

  // Méthodes supplémentaires et conversion en/à partir de JSON si nécessaire
  // ...
}
