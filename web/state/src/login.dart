part of state;

class Login extends State {
  final Element loginCard = querySelector('#login-card');

  final InputElement loginUsernameEl = querySelector('#login_user_name');
  final InputElement loginPassword = document.querySelector('#login_password');

  final InputElement registerUsernameEl = querySelector('#register_user_name');
  final InputElement registerPassword =
      document.querySelector('#register_password');
  final InputElement registerPasswordRetype =
      document.querySelector('#register_password_retype');

  StreamSubscription submitSub;

  Login(ClientWebSocket client) : super(client) {
    client.on(SocketMessage_Type.LOGIN_SUCCESSFUL, _loginSuccessful);

    querySelector('#login-btn').onClick.listen((_) {
      submitLogin();
    });

    querySelector('#register-btn').onClick.listen((_) {
      submitRegister();
    });
  }

  @override
  show() {
    loginCard.style.display = '';

    loginUsernameEl.autofocus = true;

    submitSub = window.onKeyPress.listen((KeyboardEvent e) {
      if (e.keyCode == KeyCode.ENTER) {
        submitLogin();
      }
    });
  }

  @override
  hide() {
    loginCard.style.display = 'none';
    submitSub?.cancel();
  }

  submitLogin() {
    if (!client.isConnected()) {
      print('Not connected');
      return;
    }

    final loginInfo = LoginCredentials()
      ..userID = loginUsernameEl.value.trim()
      ..passCode = loginPassword.value.trim();

    if (loginInfo.userID.isEmpty || loginInfo.passCode.isEmpty) {
      print('Not a valid username');
      return;
    }

    client.send(SocketMessage_Type.LOGIN, loginInfo);
  }

  submitRegister() {
    if (!client.isConnected()) {
      print('Not connected');
      return;
    }

    final loginInfo = LoginCredentials()
      ..userID = registerUsernameEl.value.trim()
      ..passCode = registerPassword.value.trim();

    if (loginInfo.userID.isEmpty || loginInfo.passCode.isEmpty) {
      print('Not a valid username');
      return;
    }

    if (loginInfo.passCode != registerPasswordRetype.value.trim()) {
      print('Passwords don\'t match');
      return;
    }

    client.send(SocketMessage_Type.REGISTER, loginInfo);
  }

  _loginSuccessful() {
    StateManager.shared.pushState('play');
  }
}
