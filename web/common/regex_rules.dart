class RegexRules {
  static const lobbyNameMinLength = 4;
  static const lobbyNameMaxLength = 16;
  static const lobbyName =
      '^[a-zA-Z0-9_-]{$lobbyNameMinLength,$lobbyNameMaxLength}\$';

  static const usernameMinLength = 4;
  static const usernameMaxLength = 16;
  static const username =
      '^[a-zA-Z0-9_-]{$usernameMinLength,$usernameMaxLength}\$';
}
