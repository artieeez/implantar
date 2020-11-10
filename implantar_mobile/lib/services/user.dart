import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:implantar_mobile/services/config.dart';
import 'dart:io';

/* Data Storage */
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class User {
  String baseUrl;
  String username;
  String password;
  String nome;
  String token;
  bool isAuthenticated;
  Database db;
  static const String TABLE_NAME = 'user';

  User() {
    ImplantarConfig config = ImplantarConfig();
    baseUrl = config.protocol + config.domain;
  }

  Future<void> init() async {
    /* Pega referência do banco */
    db = await getDatabase();
    /* Verifica se possuí token válido */
    if (await userExistCheck()) {
      Map userMap = await getUser();
      populateWithMap(userMap); // Populate
    } else {
      /* Limpa db */
      await db.delete(
        'user',
      );
      /* Novo token */
      Map userMap = await login();
      populateWithMap(userMap); // Populate
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
      final List<Map<String, dynamic>> maps = await db.query(TABLE_NAME);
      if (maps.length != 1 || maps[0]['token'] == null) {
        return false;
      } else if (await tokenValidation(maps[0]['token'])) {
        return true;
      }
    } catch (e) {
      print("Não foi possível verificar se há usuário salvo");
      print(e);
      return false;
    }
    return false;
  }

  Future<Map<String, dynamic>> getUser() async {
    final List<Map<String, dynamic>> maps = await db.query(TABLE_NAME);
    return maps[0];
  }

  Future<Map<String, dynamic>> login() async {
    final http.Response response = await http.post(
      baseUrl + 'api-token-auth/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'username': 'artur', 'password': '050483artur'}),
    );
    if (response.statusCode == 200) {
      token = jsonDecode(response.body)['token'];
      isAuthenticated = true;
      return {'token': jsonDecode(response.body)['token']};
    } else {
      isAuthenticated = false;
      throw Exception('Falha ao logar');
    }
  }

  Future<bool> tokenValidation(tokenToBeValidated) async {
    /* Testa token acessando a raiz da api */
    http.Response response = await http.get(
      baseUrl,
      headers: {'Authorization': 'token ' + tokenToBeValidated},
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
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
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          "CREATE TABLE user(id AUTO_INCREMENT INTEGER PRIMARY KEY, nome TEXT, token TEXT)",
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }
}
