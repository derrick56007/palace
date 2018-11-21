part of server;

class DataBaseManager {
  static final shared = DataBaseManager._internal();

  // path of user database
  static final _userDBPath = Directory.current.path + '/databases/user.db';

  // database object
  final userDB = ObjectDB(_userDBPath);

  DataBaseManager._internal() {
    userDB
      ..open()
      ..tidy();
  }
}
