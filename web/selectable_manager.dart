class SelectableManager {
  static final shared = new SelectableManager._internal();

  final selectedIDs = <String>[];

  SelectableManager._internal();
}