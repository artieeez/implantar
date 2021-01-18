import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:implantar_mobile/services/settings.dart' as settings;
import 'dart:io';

/* Data Storage */
import 'dart:async';
import 'package:sqflite/sqflite.dart';

class User {
  BuildContext context;
  int id;
  /* <vCount>
  Número sequencial relacionado com o número de visitas. Usado no
  gerador de id de Visita */
  int vCount;
  String nome;
  String token;
  bool isAuthenticated = false;
  final bool hasConnection;
  final Database db;

  User(this.context, this.hasConnection, this.db);

  Future<void> init() async {
    /* Pega referência do banco */
    /* Verifica se possuí token válido */
    bool _credentialSaved = await userExistCheck();
    if (_credentialSaved) {
      Map userMap = await getUser();
      await populateWithMap(userMap);
    }
    if (hasConnection && _credentialSaved) {
      isAuthenticated = await tokenValidation(token);
    }
    if (hasConnection && !isAuthenticated) {
      /* Novo token */
      final dynamic result = await Navigator.pushNamed(context, '/login');
      id = result['id'];
      nome = result['nome'];
      token = result['token'];
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
    id = map['id'];
    token = map['token'];
  }

  Future<bool> userExistCheck() async {
    try {
      final List<Map<String, dynamic>> maps =
          await db.query(settings.USER_TABLE);
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
    final List<Map<String, dynamic>> maps = await db.query(settings.USER_TABLE);
    return maps[0];
  }

  Future<bool> tokenValidation(String tokenToBeValidated) async {
    int count = 0; // tentativas de conexão
    /* Testa token acessando a raiz da api */
    while (count < settings.CONN_LIMIT) {
      try {
        http.Response response = await http.get(
          settings.API['base'] + settings.API['hasConnection'],
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
      'id': id,
      'nome': nome,
      'token': token,
    };
  }

  int vCountGetter() {
    vCount++;
    db.transaction((txn) async {
      await txn.rawInsert(
          """UPDATE user SET vCount = ? WHERE id = ?""", [vCount, id]);
    });
    return vCount;
  }
}
