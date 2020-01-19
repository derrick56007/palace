part of state;

class Login extends State {
  final Element loginCard = querySelector('#login-card');

  final InputElement loginUsernameEl = querySelector('#login_user_name');
  final InputElement loginPassword = document.querySelector('#login_password');

  StreamSubscription submitSub;

  Login(ClientWebSocket client) : super(client) {
    client.onClose.listen((_) => _logoutSuccessful());

    client
      ..on(SocketMessage_Type.LOGIN_SUCCESSFUL, _loginSuccessful)
      ..on(SocketMessage_Type.LOGOUT_SUCCESSFUL, _logoutSuccessful);

    querySelector('#login-btn').onClick.listen((_) => submitLogin());

    querySelector('#sign-up-btn')
        .onClick
        .listen((_) => StateManager.shared.pushState('register'));
  }

  @override
  void show() {
    loginCard.style.display = '';

    loginUsernameEl
      ..autofocus = true
      ..select();

    submitSub = window.onKeyPress.listen((KeyboardEvent e) {
      if (e.keyCode == KeyCode.ENTER) {
        submitLogin();
      }
    });
  }

  @override
  void hide() {
    loginCard.style.display = 'none';
    submitSub?.cancel();
  }

  void submitLogin() {
    if (!client.isConnected()) {
      toast('Not connected');
      return;
    }

    final loginInfo = LoginCredentials()
      ..userID = loginUsernameEl.value.trim()
      ..passCode = loginPassword.value.trim();

    if (loginInfo.userID.isEmpty || loginInfo.passCode.isEmpty) {
      toast('Not a valid username');
      return;
    }

    client.send(SocketMessage_Type.LOGIN, loginInfo);
  }

  void _loginSuccessful() {
    StateManager.shared.pushState('play');
  }

  void _logoutSuccessful() {
    StateManager.shared.pushState('login');

    querySelector('#friends-list').children.clear();
  }
}
