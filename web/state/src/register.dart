part of state;

class Register extends State {
  final Element registerCard = querySelector('#register-card');

  final InputElement registerUsernameEl = querySelector('#register_user_name');
  final InputElement registerPassword =
  document.querySelector('#register_password');
  final InputElement registerPasswordRetype =
  document.querySelector('#register_password_retype');

  StreamSubscription submitSub;

  Register(ClientWebSocket client) : super(client) {
    querySelector('#register-btn').onClick.listen((_) {
      submitRegister();
    });
    querySelector('#back-to-login-btn').onClick.listen((_) {
      StateManager.shared.pushState('login');
    });
  }

  @override
  show() {
    registerCard.style.display = '';

    registerUsernameEl.autofocus = true;
    registerUsernameEl.select();

    submitSub = window.onKeyPress.listen((KeyboardEvent e) {
      if (e.keyCode == KeyCode.ENTER) {
        submitRegister();
      }
    });
  }

  @override
  hide() {
    registerCard.style.display = 'none';
    submitSub?.cancel();
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
}
