class Team {
  String _userId;
  String _roleId;

  Team({
    required String userId,
    required String roleId,
  })  : _userId = userId,
        _roleId = roleId;

  // Getters
  String get userId => _userId;
  String get roleId => _roleId;

  // Setters
  set userId(String value) => _userId = value;
  set roleId(String value) => _roleId = value;

  // Méthodes supplémentaires pertinentes

  // Mettre à jour le rôle d'un membre de l'équipe
  void updateRole(String newRoleId) {
    _roleId = newRoleId;
  }
}
