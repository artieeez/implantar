import 'package:implantar_mobile/services/user.dart';
import 'package:implantar_mobile/services/settings.dart' as settings;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

/* Data Storage */
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataSync {
  BuildContext context;
  final bool hasConnection;
  final Database db;
  final User user;
  static int dbVersion;
  static int newDbVersion;
  bool isUpdated;
  bool isReady;

  DataSync(this.context, this.hasConnection, this.db, this.user);

  Future<void> init() async {
    dbVersion = await _getDbVersion();
    if (hasConnection) {
      try {
        newDbVersion = await _getNewDbVersion();
      } catch (e) {
        /* Load localData into memory */
        print(e);
        isUpdated = false;
        isReady = true;
        return;
      }
      isUpdated = (dbVersion == newDbVersion);
      if (isUpdated) {
        /* Load localData into memory */
        isUpdated = true;
        isReady = true;
        return;
      } else {
        try {
          /* Fetch data from backend */
        } catch (e) {
          print(e);
          /* Load localData into memory */
          isUpdated = false;
          isReady = true;
          return;
        }
        dbVersion = newDbVersion;
        isUpdated = true;
        isReady = true;
        return;
      }
    } else {
      if (dbVersion != 0) {
        /*  Offline Mode
          Load localData into memory */
        isUpdated = false;
        isReady = true;
        return;
      }
      isUpdated = false;
      isReady = false;
      return;
    }
  }

  Future<int> _getDbVersion() async {
    List<Map<String, dynamic>> query =
        await db.rawQuery("SELECT version FROM dbVersion WHERE id = 1");
    return query[0]['version'];
  }

  Future<int> _getNewDbVersion() async {
    // TODO getIsUpdated backend
    int count;
    int _dbVersion;
    while (count < settings.CONN_LIMIT) {
      try {
        final http.Response response = await http.get(
          settings.API['base'] + settings.API['dbVersion'],
          headers: <String, String>{
            'Authorization': 'token ' + user.token,
          },
        );
        if (response.statusCode == 200) {
          _dbVersion = jsonDecode(response.body)['dbVersion'];
          return _dbVersion;
        } else {
          throw ("Sem sucesso em obter versão do backend");
        }
      } catch (e) {
        print(e);
        count++;
        sleep(const Duration(seconds: 5));
      }
    }
    throw ("Sem sucesso em obter versão do backend");
  }

  Future<void> _loadLocalData() async {}

  Future<void> _fetchBackendData() async {}
}
