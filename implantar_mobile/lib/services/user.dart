import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:implantar_mobile/services/config.dart' as co;
import 'dart:io';

/* Data Storage */
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class User {
  BuildContext context;
  String nome;
  String token;
  bool isAuthenticated = false;
  bool isOnline = false;
  Database db;

  User(this.context);

  Future<void> init() async {
    isOnline = await isOnlineCheck();
    /* Pega referência do banco */
    db = await getDatabase();
    /* Verifica se possuí token válido */
    if (await userExistCheck()) {
      Map userMap = await getUser();
      await populateWithMap(userMap);
    }
    if (isOnline) {
      isAuthenticated = await tokenValidation(token);
    }
    if (isOnline && !isAuthenticated) {
      /* Novo token */
      final result = await Navigator.pushNamed(context, '/login');
      token = result;
      /* Limpa db */
      await db.delete(
        'user',
      );
      /* Salva no banco */
      await db.insert(
        'user',
        this.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return;
    }
    return;
  }

  populateWithMap(map) {
    token = map['token'];
  }

  Future<bool> userExistCheck() async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(co.USER_TABLE);
      if (maps.length != 1 || maps[0]['token'] == null) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final List<Map<String, dynamic>> maps = await db.query(co.USER_TABLE);
    return maps[0];
  }

  Future<bool> tokenValidation(tokenToBeValidated) async {
    int count = 0; // tentativas de conexão
    /* Testa token acessando a raiz da api */
    while (count < co.CONN_LIMIT) {
      try {
        http.Response response = await http.get(
          co.API['base'] + 'api/',
          headers: {'Authorization': 'token ' + tokenToBeValidated},
        );
        if (response.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        print(e);
        count++;
        sleep(const Duration(seconds: 5));
      }
    }
    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'token': token,
    };
  }

  Future<Database> getDatabase() async {
    // Avoid errors caused by flutter upgrade.
    // Importing 'package:flutter/widgets.dart' is required.
    WidgetsFlutterBinding.ensureInitialized();
    // Open the database and store the reference.
    return openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'implantar.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE user(id AUTO_INCREMENT INTEGER PRIMARY KEY, nome TEXT, token TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<bool> isOnlineCheck() async {
    try {
      http.Response response = await http.get(
        co.API['base'] + 'api/',
      );
      if (response.statusCode >= 400 && response.statusCode <= 500) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
