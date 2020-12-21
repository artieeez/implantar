import 'package:implantar_mobile/services/user.dart';
import 'package:implantar_mobile/services/dataSync.dart';
import 'package:implantar_mobile/services/settings.dart' as settings;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/* Data Storage */
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/* Permissions */
import 'package:permission_handler/permission_handler.dart';

class Session {
  /*  Controla elementos básicos para a funcionalidade da sessão: 
        - Autenticação;
        - Sincronização;
        - Métodos de uso comum;
        - Configurações locais (TODO);
  */
  BuildContext context;
  bool hasConnection;
  Database db;
  User user;
  DataSync dataSync;

  Session(this.context);

  Future<void> init() async {
    db = await _initDatabase();
    hasConnection = await _hasConnection();
    user = await _getUser();
    /* dataSync = await _getDataSync(); */
  }

  void syncInit() async {}

  void offlineModeInit() async {}

  Future<bool> _hasConnection() async {
    /*  Return true if backend is up
        Require configuration in services/settings.dart
    */
    try {
      http.Response response = await http.get(
        settings.API['base'] + 'api/',
      );
      if (response.statusCode >= 400 && response.statusCode <= 500) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Database> _initDatabase() async {
    await Permission.storage.request();
    // TODO permission ? throw error
    WidgetsFlutterBinding.ensureInitialized();
    // Open the database and store the reference.
    Database _db = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'session.db'),
      onCreate: (db, version) async {
        await db.execute(
          """CREATE TABLE user(
            id AUTO_INCREMENT INTEGER PRIMARY KEY,
            nome TEXT,
            token TEXT)""",
        );
        await db.execute(
          """CREATE TABLE clientDataVersion(
            id INTEGER PRIMARY KEY,
            version INTEGER NOT NULL)""",
        );
        await db.execute(
          """CREATE TABLE rede(
            id INTEGER PRIMARY KEY,
            nome TEXT NOT NULL,
            photo TEXT)""",
        );
        await db.execute(
          """CREATE TABLE ponto(
            id INTEGER PRIMARY KEY,
            nome TEXT NOT NULL,
            rede_id INTEGER NOT NULL,
            FOREIGN KEY(rede_id) REFERENCES rede(id))""",
        );
        await db.execute(
          """CREATE TABLE visita(
            id INTEGER PRIMARY KEY,
            concluded INTEGER DEFAULT 0,
            sent INTEGER DEFAULT 0,
            inicio TEXT NOT NULL,
            termino TEXT,
            signature TEXT,
            ponto_id INTEGER NOT NULL,
            FOREIGN KEY(ponto_id) REFERENCES ponto(id))""",
        );
        await db.execute(
          """CREATE TABLE item(
            id INTEGER PRIMARY KEY,
            photo TEXT,
            conformidade TEXT DEFAULT 'NO',
            visita_id INTEGER NOT NULL,
            itemBase_id INTEGER NOT NULL,
            FOREIGN KEY(visita_id) REFERENCES visita(id),
            FOREIGN KEY(itemBase_id) REFERENCES itemBase(id))""",
        );
        await db.execute(
          """CREATE TABLE categoria(
            id INTEGER PRIMARY KEY,
            id_arb INTEGER,
            nome TEXT NOT NULL)""",
        );
        await db.execute(
          """CREATE TABLE itemBase(
            id INTEGER PRIMARY KEY,
            id_arb INTEGER,
            text TEXT NOT NULL,
            categoria_id INTEGER,
            FOREIGN KEY(categoria_id) REFERENCES categoria(id))""",
        );
        await db.rawInsert('INSERT INTO dbVersion(id, version) VALUES(1, 0)');
        return;
      },
      version: 1,
    );
    return _db;
  }

  Future<User> _getUser() async {
    User _newUserInstance = User(context, hasConnection, db);
    await _newUserInstance.init();
    return _newUserInstance;
  }

  Future<DataSync> _getDataSync() async {
    DataSync _newDataSyncInstance = DataSync(context, hasConnection, db, user);
    await _newDataSyncInstance.init();
    return _newDataSyncInstance;
  }
}
