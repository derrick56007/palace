part of server;

class StringValidator {
  static final _lobbyNameRegex = RegExp(RegexRules.lobbyName);

  static final _usernameRegex = RegExp(RegexRules.username);

  static bool isValidLobbyName(String lobbyName) {
    final lobbyMatches = _lobbyNameRegex.firstMatch(lobbyName);

    return lobbyMatches != null && lobbyMatches[0] == lobbyName;
  }

  static bool isValidUsername(String username) {
    final usernameMatches = _usernameRegex.firstMatch(username);

    return usernameMatches != null && usernameMatches[0] == username;
  }
}
