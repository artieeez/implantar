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
import 'package:sqflite/sqflite.dart';

class DataSync {
  BuildContext context;
  final bool hasConnection;
  final Database db;
  final User user;
  static int clientDataVersion;
  static int serverDataVersion;
  bool isUpdated;
  bool isReady = false;
  bool useCache = settings.CACHE;

  bool unsafeData;
  List<Rede> redes = [];
  List<ItemBase> itemBases = [];

  DataSync(this.context, this.hasConnection, this.db, this.user);

  Future<void> init() async {
    clientDataVersion = await _getClientDataVersion();
    if (hasConnection) {
      try {
        serverDataVersion = await _getServerDataVersion();
        isUpdated = useCache ? (clientDataVersion == serverDataVersion) : false;
        if (isUpdated) {
          /* Load localData into memory */
          await _loadClientData();
        } else {
          /* Fetch data from backend */
          await _fetchServerData();
          clientDataVersion = serverDataVersion;
        }
        isUpdated = true;
        isReady = true;
      } catch (e) {
        /* Load localData into memory */
        await _loadClientData();
        print(e);
        isUpdated = false;
        isReady = true;
      }
    } else {
      if (clientDataVersion != 0) {
        /*  Offline Mode
          Load localData into memory */
        await _loadClientData();
        isUpdated = false;
        isReady = true;
      }
      isUpdated = false;
      isReady = false;
    }

    await _loadImages();
    return;
  }

  Future<int> _getClientDataVersion() async {
    List<Map<String, dynamic>> query =
        await db.rawQuery("SELECT version FROM clientDataVersion WHERE id = 1");
    return query[0]['version'];
  }

  Future<int> _getServerDataVersion() async {
    // TODO getIsUpdated backend
    int count = 0;
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
          _serverDataVersion = jsonDecode(response.body)['version'];
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
    await db.rawUpdate(
        'UPDATE clientDataVersion SET version = ? WHERE id = 1', [0]);
    await db.delete(
      'rede',
    );
    await db.delete(
      'ponto',
    );
    await db.delete(
      'itemBase',
    );

    /* Fetch Redes */
    List<dynamic> redeList = await _fetchRedes();
    for (int i = 0; i < redeList.length; i++) {
      Rede _rowRede = Rede.fromJson(redeList[i]);
      for (int j = 0; j < redeList[i]['pontos'].length; j++) {
        Ponto _rowPonto = Ponto.fromJson(redeList[i]['pontos'][j]);
        _rowRede.pontos.add(_rowPonto);
        await db
            .rawInsert('INSERT INTO ponto(id, nome, rede_id) VALUES(?, ?, ?)', [
          _rowPonto.id,
          _rowPonto.nome,
          _rowRede.id,
        ]);
      }
      /* Cache image */
      if (_rowRede.photo != null) {
        String url = _rowRede.photo; // <-- 1
        http.Response response = await http.get(url); // <--2
        Directory documentDirectory = await getApplicationDocumentsDirectory();
        String firstPath = documentDirectory.path + "/redes/${_rowRede.id}";
        String filePathAndName =
            documentDirectory.path + '/redes/${_rowRede.id}/photo.png';
        await Directory(firstPath).create(recursive: true); // <-- 1
        File file2 = new File(filePathAndName); // <-- 2
        file2.writeAsBytesSync(response.bodyBytes); // <-- 3
        _rowRede.photo = filePathAndName;
      }
      redes.add(_rowRede);
      await db.rawInsert('INSERT INTO rede(id, nome, photo) VALUES(?, ?, ?)', [
        _rowRede.id,
        _rowRede.nome,
        _rowRede.photo,
      ]);
    }

    /* Fetch itemBase */
    List<dynamic> itemBaseList = await _fetchItemBase();
    for (int i = 0; i < itemBaseList.length; i++) {
      ItemBase _rowItemBase = ItemBase.fromJson(itemBaseList[i]);
      itemBases.add(_rowItemBase);
      await db
          .rawInsert('INSERT INTO itemBase(id, text, active) VALUES(?, ?, ?)', [
        _rowItemBase.id,
        _rowItemBase.text,
        _rowItemBase.active ? 1 : 0,
      ]);
    }

    await db.rawUpdate('UPDATE clientDataVersion SET version = ? WHERE id = 1',
        [serverDataVersion]);
    return;
  }

  Future<List<dynamic>> _fetchRedes() async {
    int count = 0; // tentativas de conexão
    while (count < settings.CONN_LIMIT) {
      try {
        http.Response response = await http.get(
          settings.API['base'] + settings.API['redes'],
          headers: {'Authorization': 'token ' + user.token},
        );
        if (response.statusCode == 200) {
          List<dynamic> _data =
              jsonDecode(utf8.decode(response.bodyBytes))['results'];
          return _data;
        }
      } catch (e) {
        print(e);
        count++;
        sleep(const Duration(seconds: 5));
      }
    }
    throw ('Err. Failed to fetch redes.');
  }

  Future<List<dynamic>> _fetchItemBase() async {
    int count = 0; // tentativas de conexão
    while (count < settings.CONN_LIMIT) {
      try {
        http.Response response = await http.get(
          settings.API['base'] + settings.API['itemBase'],
          headers: {'Authorization': 'token ' + user.token},
        );
        if (response.statusCode == 200) {
          List<dynamic> _data =
              jsonDecode(utf8.decode(response.bodyBytes))['results'];
          return _data;
        }
      } catch (e) {
        print(e);
        count++;
        sleep(const Duration(seconds: 5));
      }
    }
    throw ('Err. Failed to fetch itemBases.');
  }

  Future<void> _loadImages() async {
    /*  Bugfix
        commit 04977ccc3a742cbcfe3f01ee43ac6a1d7919809a não carregava as imagens
        das redes em 'rede.dart'. AssetImage foi substituído por MemoryImage,
        com a sequência de bytes sendo carregada aqui.
    */
    for (int i = 0; i < redes.length; i++) {
      if (redes[i].photo != null) {
        File imageFile = File(redes[i].photo);
        redes[i].photoBytes = await imageFile.readAsBytes();
      }
    }
  }
}
