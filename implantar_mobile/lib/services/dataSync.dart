import 'package:implantar_mobile/services/user.dart';
import 'package:implantar_mobile/services/settings.dart' as settings;
import 'package:implantar_mobile/api/models.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

/* Files */
import 'package:path_provider/path_provider.dart';

/* Data Storage */
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataSync {
  BuildContext context;
  final bool hasConnection;
  final Database db;
  final User user;
  static int clientDataVersion;
  static int serverDataVersion;
  bool isUpdated;
  bool isReady;

  bool unsafeData;
  List<Rede> redes;
  List<ItemBase> itemBases;

  DataSync(this.context, this.hasConnection, this.db, this.user);

  Future<void> init() async {
    clientDataVersion = await _getClientDataVersion();
    if (hasConnection) {
      try {
        serverDataVersion = await _getServerDataVersion();
      } catch (e) {
        /* Load localData into memory */
        _loadClientData();
        print(e);
        isUpdated = false;
        isReady = true;
        return;
      }
      isUpdated = (clientDataVersion == serverDataVersion);
      if (isUpdated) {
        /* Load localData into memory */
        _loadClientData();
        isUpdated = true;
        isReady = true;
        return;
      } else {
        try {
          /* Fetch data from backend */
          _fetchServerData();
        } catch (e) {
          print(e);
          /* Load localData into memory */
          _loadClientData();
          isUpdated = false;
          isReady = true;
          return;
        }
        clientDataVersion = serverDataVersion;
        isUpdated = true;
        isReady = true;
        return;
      }
    } else {
      if (clientDataVersion != 0) {
        /*  Offline Mode
          Load localData into memory */
        _loadClientData();
        isUpdated = false;
        isReady = true;
        return;
      }
      isUpdated = false;
      isReady = false;
      return;
    }
  }

  Future<int> _getClientDataVersion() async {
    List<Map<String, dynamic>> query =
        await db.rawQuery("SELECT version FROM clientDataVersion WHERE id = 1");
    return query[0]['version'];
  }

  Future<int> _getServerDataVersion() async {
    // TODO getIsUpdated backend
    int count;
    int _serverDataVersion;
    while (count < settings.CONN_LIMIT) {
      try {
        final http.Response response = await http.get(
          settings.API['base'] + settings.API['dbVersion'],
          headers: <String, String>{
            'Authorization': 'token ' + user.token,
          },
        );
        if (response.statusCode == 200) {
          _serverDataVersion = jsonDecode(response.body)['dbVersion'];
          return _serverDataVersion;
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

  Future<void> _loadClientData() async {
    /* Load Redes */
    List<Map<String, dynamic>> _redes = await db.rawQuery('SELECT * FROM rede');
    for (int i = 0; i < _redes.length; i++) {
      List<Map<String, dynamic>> _pontos = await db
          .rawQuery('SELECT * FROM ponto WHERE rede_id = ?', [_redes[i]['id']]);
      Rede _rowRede = Rede.fromJson(_redes[i]);
      for (int j = 0; j < _pontos.length; j++) {
        Ponto _rowPonto = Ponto.fromJson(_pontos[j]);
        _rowRede.pontos.add(_rowPonto);
      }
      /* Cache photo */

      redes.add(_rowRede);
    }

    /* Load itemBase */
    List<Map<String, dynamic>> _itemBases = await db
        .rawQuery('SELECT * FROM itemBase WHERE active = 1 ORDER BY id_arb');
    for (int i = 0; i < _itemBases.length; i++) {
      ItemBase _rowItem = ItemBase.fromJson(_itemBases[i]);
      itemBases.add(_rowItem);
    }
    return;
  }

  Future<void> _fetchServerData() async {
    /* Fetch Redes */
    int count = 0; // tentativas de conexão
    while (count < settings.CONN_LIMIT) {
      try {
        http.Response response = await http.get(
          settings.API['base'] + settings.API['redes'],
          headers: {'Authorization': 'token ' + user.token},
        );
        if (response.statusCode == 200) {
          Map data = jsonDecode(utf8.decode(response.bodyBytes));
          for (int i = 0; i < data['results'].length; i++) {
            Rede _rowRede = Rede.fromJson(data['results'][i]);
            for (int j = 0; j < data['results'][i]['pontos'].length; j++) {
              Ponto _rowPonto = Ponto.fromJson(data['results'][i]['pontos'][j]);
              _rowRede.pontos.add(_rowPonto);
            }

            /* Cache image */
            var url = _rowRede.photo; // <-- 1
            var response = await http.get(url); // <--2
            var documentDirectory = await getApplicationDocumentsDirectory();
            var firstPath = documentDirectory.path + "/redes/v${_rowRede.id}";
            var filePathAndName =
                documentDirectory.path + '/redes/v${_rowRede.id}/photo.png';
            await Directory(firstPath).create(recursive: true); // <-- 1
            File file2 = new File(filePathAndName); // <-- 2
            file2.writeAsBytesSync(response.bodyBytes); // <-- 3
            _rowRede.photo = filePathAndName;
            redes.add(_rowRede);
          }
          return;
        } else {
          return;
        }
      } catch (e) {
        print(e);
        count++;
        sleep(const Duration(seconds: 5));
      }
    }
  }
}
