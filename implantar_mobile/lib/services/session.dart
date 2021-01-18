import 'package:implantar_mobile/services/user.dart';
import 'package:implantar_mobile/services/dataSync.dart';
import 'package:implantar_mobile/services/settings.dart' as settings;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/* Data Storage */
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

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
  bool visitaAberta;

  Session(this.context);

  Future<void> init() async {
    await Permission.storage.request();

    db = await _initDatabase();
    hasConnection = await _hasConnection();
    user = await _getUser();
    dataSync = await _getDataSync();
    visitaAberta = await _getVisitaAberta();
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
    // TODO permission ? throw error
    WidgetsFlutterBinding.ensureInitialized();
    // Open the database and store the reference.
    Database _db = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'session.db'),
      onCreate: (_db, version) async {
        await _db.execute(
          """CREATE TABLE user(
            id INTEGER PRIMARY KEY,
            vCount INTEGER,
            nome TEXT,
            token TEXT)""",
        );
        await _db.execute(
          """CREATE TABLE clientDataVersion(
            id INTEGER PRIMARY KEY,
            version INTEGER NOT NULL)""",
        );
        await _db.execute(
          """CREATE TABLE rede(
            id INTEGER PRIMARY KEY,
            nome TEXT NOT NULL,
            photo TEXT)""",
        );
        await _db.execute(
          """CREATE TABLE ponto(
            id INTEGER PRIMARY KEY,
            nome TEXT NOT NULL,
            rede_id INTEGER NOT NULL,
            FOREIGN KEY(rede_id) REFERENCES rede(id))""",
        );
        await _db.execute(
          """CREATE TABLE visita(
            clientId AUTO_INCREMENT INTEGER PRIMARY KEY,
            id INTEGER UNIQUE,
            concluded INTEGER DEFAULT 0,
            sent INTEGER DEFAULT 0,
            inicio TEXT NOT NULL,
            termino TEXT,
            signature TEXT,
            ponto_id INTEGER NOT NULL,
            FOREIGN KEY(ponto_id) REFERENCES ponto(id))""",
        );
        await _db.execute(
          """CREATE TABLE item(
            clientId AUTO_INCREMENT INTEGER PRIMARY KEY,
            id INTEGER UNIQUE,
            sent INTEGER DEFAULT 0,
            photo TEXT,
            photoVersion INTEGER,
            conformidade TEXT DEFAULT 'NO',
            comment TEXT,
            visita_id INTEGER NOT NULL,
            itemBase_id INTEGER NOT NULL,
            FOREIGN KEY(visita_id) REFERENCES visita(localId),
            FOREIGN KEY(itemBase_id) REFERENCES itemBase(id))""",
        );
        await _db.execute(
          """CREATE TABLE categoria(
            id INTEGER PRIMARY KEY,
            id_arb INTEGER,
            nome TEXT NOT NULL)""",
        );
        await _db.execute(
          """CREATE TABLE itemBase(
            id INTEGER PRIMARY KEY,
            id_arb INTEGER,
            text TEXT NOT NULL,
            categoria_id INTEGER,
            active INTEGER,
            FOREIGN KEY(categoria_id) REFERENCES categoria(id))""",
        );
        await _db.rawInsert(
            'INSERT INTO clientDataVersion(id, version) VALUES(1, 0)');
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

  Future<bool> _getVisitaAberta() async {
    print("procurando visita aberta");
    if (!settings.VISITA_SAFE) {
      print("Deletando visitas em aberto");
      List<Map<String, dynamic>> query =
          await db.rawQuery("""SELECT * FROM visita""");
      for (int i = 0; i < query.length; i++) {
        if (query[i]['signature'] != null) {
          File(query[i]['signature']).delete();
        }
      }
      List<Map<String, dynamic>> queryItem =
          await db.rawQuery("""SELECT * FROM item""");
      for (int i = 0; i < queryItem.length; i++) {
        if (queryItem[i]['photo'] != null) {
          File(queryItem[i]['photo']).delete();
        }
      }
      await db.rawDelete("""DELETE FROM visita""");
      await db.rawDelete("""DELETE FROM item""");
      return false;
    } else {
      /* Verifica a existência de visita não concluída */
      List<Map<String, dynamic>> queryResult = await db.rawQuery("""
      SELECT * FROM visita WHERE (concluded = ? OR concluded IS NULL)""", [0]);
      print(queryResult);
      if (queryResult.length == 1) {
        return true;
      } else if (queryResult.length > 1) {
        throw ("Mais de uma visita em aberto.");
        // TODO handle this
      } else {
        return false;
      }
    }
  }
}
