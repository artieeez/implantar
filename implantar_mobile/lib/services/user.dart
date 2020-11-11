import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:implantar_mobile/services/config.dart';
import 'dart:io';

/* Data Storage */
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class User {
  BuildContext context;
  String nome;
  String token;
  bool isAuthenticated;
  Database db;

  User(this.context);

  Future<void> init() async {
    /* Pega referência do banco */
    db = await getDatabase();
    /* Verifica se possuí token válido */
    if (await userExistCheck()) {
      Map userMap = await getUser();
      populateWithMap(userMap); // Populate
    } else {
      /* Novo token */
      await login();
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
    }
  }

  populateWithMap(map) {
    this.token = map['token'];
  }

  Future<bool> userExistCheck() async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(USER_TABLE);
      if (maps.length != 1 || maps[0]['token'] == null) {
        return false;
      } else if (await tokenValidation(maps[0]['token'])) {
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
    return false;
  }

  Future<Map<String, dynamic>> getUser() async {
    final List<Map<String, dynamic>> maps = await db.query(USER_TABLE);
    return maps[0];
  }

  Future<void> login() async {
    dynamic result = await Navigator.pushNamed(context, '/login');
    token = result;
    return;
  }

  Future<bool> tokenValidation(tokenToBeValidated) async {
    int count = 0; // tentativas de conexão
    /* Testa token acessando a raiz da api */
    while (count < CONN_TENTATIVAS) {
      try {
        http.Response response = await http.get(
          baseUrl,
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
}
