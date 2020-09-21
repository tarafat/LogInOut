import 'dart:io' show Directory;

import 'package:sqflite/sqflite.dart'
    show Database, ConflictAlgorithm, openDatabase;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

import '../model/logginSession.dart';
import '../model/auth.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory dd = await getApplicationDocumentsDirectory();
    final path = join(dd.path, "aslLinout.db");

    // Open/create the database at a given path
    var notesDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
       create TABLE auth
       (
         user TEXT PRIMARY KEY,
         token TEXT,
         expiresIn TEXT
       )
       ''');
        db.execute('''
        CREATE TABLE loginSession
        (
        cus TEXT PRIMARY KEY,
        org TEXT,
        time TEXT
        )
        ''');
      },
    );
    return notesDatabase;
  }

//loginSession
  Future<LoginSession> fetchLoginSession() async {
    Database db = await this.database;
    var maps = await db.query(
      "loginSession",
      columns: null,
    );
    if (maps.length > 0) {
      return LoginSession.fromMapToDb(maps.first);
    }
    return null;
  }

  Future<int> addLoginSession(LoginSession loginSession) async {
    Database db = await this.database;
    return db.insert("loginSession", loginSession.toMapFromDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  updateLoginSession(LoginSession loginSession) async {
    Database db = await this.database;
    var result = await db.update("loginSession", loginSession.toMapFromDb(),
        where: "cus = ?", whereArgs: [loginSession.cus]);
    return result;
  }

  deleteLoginSession(String cus) async {
    print('Db delete is working');
    Database db = await this.database;
    db.delete("loginSession", where: "cus = ?", whereArgs: [cus]);
  }

  //auth
  Future<Auth> fetchAuthUser() async {
    Database db = await this.database;
    var maps = await db.query(
      "auth",
      columns: null,
    );
    if (maps.length > 0) {
      return Auth.fromMapToDb(maps.first);
    }
    return null;
  }

  Future<int> addAuthUser(Auth auth) async {
    Database db = await this.database;
    return db.insert("auth", auth.toMapFromDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  updateAuthUser(Auth auth) async {
    Database db = await this.database;
    var result = await db.update("auth", auth.toMapFromDb(),
        where: "user = ?", whereArgs: [auth.user]);
    return result;
  }

  deleteAuthUser(String user) async {
    Database db = await this.database;
    db.delete("auth", where: "user = ?", whereArgs: [user]);
  }
}
