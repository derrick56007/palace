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
    querySelector('#register-btn').onClick.listen((_) => submitRegister());
    querySelector('#back-to-login-btn')
        .onClick
        .listen((_) => StateManager.shared.pushState('login'));
  }

  @override
  void show() {
    registerCard.style.display = '';

    registerUsernameEl
      ..autofocus = true
      ..select();

    submitSub = window.onKeyPress.listen((KeyboardEvent e) {
      if (e.keyCode == KeyCode.ENTER) {
        submitRegister();
      }
    });
  }

  @override
  void hide() {
    registerCard.style.display = 'none';
    submitSub?.cancel();
  }

  void submitRegister() {
    if (!client.isConnected()) {
      toast('Not connected');
      return;
    }

    final loginInfo = LoginCredentials()
      ..userID = registerUsernameEl.value.trim()
      ..passCode = registerPassword.value.trim();

    if (loginInfo.userID.isEmpty || loginInfo.passCode.isEmpty) {
      toast('Not a valid username');
      return;
    }

    if (loginInfo.passCode != registerPasswordRetype.value.trim()) {
      toast('Passwords don\'t match');
      return;
    }

    client.send(SocketMessage_Type.REGISTER, loginInfo);
  }
}
