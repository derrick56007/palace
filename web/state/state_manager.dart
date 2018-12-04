part of state;

class StateManager {
  static final shared = new StateManager._internal();

  final _states = <String, State>{};

  StateManager._internal() {
    window.onPopState.listen((PopStateEvent e) {
      final stateName = e.state.toString();

      _showState(stateName);
    });
  }

  Iterable<String> get keys => _states.keys;

  addAll(Map<String, State> states) => _states.addAll(states);

  pushState(String stateName) {
    if (!_states.containsKey(stateName)) {
      print('No such state!');
      return;
    }

    _showState(stateName);
  }

  _showState(String stateName) {
    if (!_states.containsKey(stateName)) {
      print('No such state!');
      return;
    }

    _states.forEach((name, state) {
      if (stateName != name) {
        state.hide();
      }
    });

    _states[stateName].show();
  }
}
