import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:implantar_mobile/services/settings.dart' as settings;
import 'dart:io';
import 'dart:convert';
import 'package:implantar_mobile/services/session.dart';

import 'package:sqflite/sqflite.dart';

class Rede {
  int id;
  String nome;
  String photo;
  Uint8List photoBytes;
  List<Ponto> pontos;

  Rede.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    photo = json['photo'];
    pontos = [];
  }
}

class Ponto {
  int id;
  String nome;
  String photo;
  Uint8List photoBytes;

  Ponto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
  }
}

class Visita {
  int id;
  int clientId;
  int ponto_id;
  DateTime inicio;
  DateTime termino;
  String signature;
  Uint8List signatureBytes;
  List<Item> itens = [];
  String plantao;

  Future<Visita> init(Session session,
      {int ponto_id, List<ItemBase> itemBases}) async {
    this.ponto_id = ponto_id;
    clientId = await _getClientId(session.db);
    int itemClientId = await _getItemClientId(session.db);
    print("#1");
    for (int i = 0; i < itemBases.length; i++) {
      Item item = Item(clientId: itemClientId, itemBase: itemBases[i]);
      itens.add(item);
      itemClientId++;
    }
    print("#2");

    this.inicio = new DateTime.now();
    _toDb(session.db);
    print("#3");
    return this;
  }

  void _toDb(Database db) async {
    print("db#1");

    db.transaction((txn) async {
      await txn.rawInsert(
          """INSERT INTO visita(ponto_id, inicio) VALUES(?, ?)""",
          [ponto_id, inicio.toIso8601String()]);
    });
    db.transaction((txn) async {
      for (int i = 0; i < itens.length; i++) {
        await txn.rawInsert(
            """INSERT INTO item(visita_id, itemBase_id) VALUES(?, ?)""",
            [clientId, itens[i].itemBase.id]);
      }
    });
    print("db#2");
  }

  Future<void> terminar() async {
    this.termino = new DateTime.now();
    return;
  }

  Future<void> save(Session session) async {
    this.termino = new DateTime.now();
    try {
      await _enviar(session);
      await _uploadSignature(session);
      await _uploadPhotos(session);
      _cleanData(session);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _cleanData(Session session) async {}

  Future<bool> _enviar(Session session) async {
    int count = 0; // tentativas de conexão
    while (count < settings.CONN_LIMIT) {
      try {
        List<Map> item_set = [];
        for (int i = 0; i < itens.length; i++) {
          Map<String, dynamic> item = {
            'conformidade': itens[i].conformidade,
            'clientId': itens[i].clientId,
            'itemBase_id': itens[i].itemBase.id,
          };
          item_set.add(item);
        }
        http.Response response = await http.post(
          settings.API['base'] + settings.API['visitas'],
          headers: <String, String>{
            'Authorization': 'token ' + session.user.token,
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'ponto_id': ponto_id.toString(),
            'item_set': item_set,
            'inicio': inicio.toIso8601String(),
            'termino': termino.toIso8601String(),
            'plantao': 'FIXME',
          }),
        );
        print(utf8.decode(response.bodyBytes));
        if (response.statusCode == 201) {
          /* Atualiza o id para o id do backend 
              Importante para futuras conexoes
          */
          Map data = await jsonDecode(utf8.decode(response.bodyBytes));
          id = data['id'];
          session.db.transaction((txn) async {
            await txn.rawInsert(
                """UPDATE visita SET id = ? WHERE clientId = ?""",
                [id, clientId]);
          });
          /* atualiza id dos itens */
          // TODO optimizar
          for (int i = 0; i < itens.length; i++) {
            for (int j = 0; j < data['item_set'].length; j++) {
              if (itens[i].clientId == data['item_set'][j]['clientId']) {
                itens[i].id = data['item_set'][j]['id'];
                data['item_set'].removeAt(j);
              }
            }
          }
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

  Future<bool> _uploadSignature(Session session) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(settings.API['base'] +
            settings.API['signature'] +
            id.toString() +
            '/'));
    request.files.add(
      http.MultipartFile.fromBytes('signature', signatureBytes,
          filename: 'v_${id.toString()}_signature.png'),
    );
    request.headers['Authorization'] = 'token ' + session.user.token;
    var res = await request.send();
  }

  Future<bool> _uploadPhotos(Session session) async {
    for (int i = 0; i < itens.length; i++) {
      String path = itens[i].photo;
      if (path != null) {
        var request = http.MultipartRequest(
            'POST',
            Uri.parse(settings.API['base'] +
                settings.API['item-photo'] +
                itens[i].id.toString() +
                '/'));
        request.files.add(
          http.MultipartFile('photo', File(path).readAsBytes().asStream(),
              File(path).lengthSync(),
              filename: path.split("/").last),
        );
        request.headers['Authorization'] = 'token ' + session.user.token;
        var res = await request.send();
        if (res.statusCode == 200) {
          File photoFile = File(path);
          photoFile.delete();
        }
      }
    }
  }

  Future<int> _getClientId(Database db) async {
    List _querylist = await db
        .rawQuery('SELECT clientId FROM visita ORDER BY clientId DESC LIMIT 1');
    if (_querylist.isNotEmpty && (_querylist[0]['clientId'] != null)) {
      return _querylist[0]['clientId'] + 1;
    } else {
      return 1;
    }
  }

  Future<int> _getItemClientId(Database db) async {
    List _querylist = await db
        .rawQuery('SELECT clientId FROM item ORDER BY clientId DESC LIMIT 1');
    if (_querylist.isNotEmpty && (_querylist[0]['clientId'] != null)) {
      return _querylist[0]['clientId'] + 1;
    } else {
      return 1;
    }
  }
}

class ItemBase {
  int id;
  int id_arb;
  String text;
  bool active;

  ItemBase(this.id, this.text, this.active);

  ItemBase.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    id_arb = json['id_arb'];
    text = json['text'];
    if (json['active'] is int) {
      active = json['active'] == 1 ? true : false;
    } else {
      active = json['active'];
    }
  }
}

class Item {
  int id;
  int clientId;
  int visita_id;
  ItemBase itemBase;
  String _photo;
  String conformidade;
  int photoVersion;

  String path;

  Item({int clientId, ItemBase itemBase}) {
    this.itemBase = itemBase;
    this.conformidade = 'NO';
    photoVersion = 0;
    this.clientId = clientId;
  }

  set photo(String path) {
    _photo = path;
    photoVersion += 1;
  }

  String get photo => _photo;

  String photoFileName() {
    /* Deve ser usado apenas antes de salvar o endereço em 'photo' */
    int v = photoVersion + 1;
    return '${clientId.toString()}_${v.toString()}.png';
  }

  Future<http.StreamedResponse> uploadPhoto(Session session) async {
    /* Precisa que o item já exista no backend */
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(settings.API['base'] +
            settings.API['item-photo'] +
            id.toString() +
            '/'));
    request.files.add(
      http.MultipartFile(
          'photo', File(path).readAsBytes().asStream(), File(path).lengthSync(),
          filename: path.split("/").last),
    );
    request.headers['Authorization'] = 'token ' + session.user.token;
    var res = await request.send();
    return res;
  }
}

/* class Visita_old {
  String API_BASE;
  String API_ENDPOINT;
  User user;
  Rede rede;
  Ponto ponto;
  List<Item> itens = [];

  int id;

  Visita(rede, ponto, user) {
    this.rede = rede;
    this.ponto = ponto;
    this.user = user;
    this.API_BASE = settings.API['base'];
    this.API_ENDPOINT = settings.API['visitas'];
  }

  Future<void> create() async {
    int count = 0; // tentativas de conexão
    while (count < settings.CONN_LIMIT) {
      try {
        http.Response response = await http.post(
          API_BASE + API_ENDPOINT,
          headers: <String, String>{
            'Authorization': 'token ' + user.token,
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'ponto_id': ponto.id.toString(),
          }),
        );
        if (response.statusCode == 201) {
          Map data = jsonDecode(utf8.decode(response.bodyBytes));
          print(data);
          id = data['id'];
          for (int i = 0; i < data['item_set'].length; i++) {
            Item item = Item.fromJson(data['item_set'][i]);
            itens.add(item);
          }
          print(itens[0].itemBase.text);
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
    return;
  }

  Future<void> update() async {
    int count = 0; // tentativas de conexão
    while (count < settings.CONN_LIMIT) {
      try {
        List<Map> item_set = [];
        for (int i = 0; i < itens.length; i++) {
          Map<String, dynamic> item = {
            'conformidade': itens[i].conformidade,
            'id': itens[i].id,
          };
          item_set.add(item);
        }

        http.Response response = await http.put(
          API_BASE + API_ENDPOINT + this.id.toString() + '/',
          headers: <String, String>{
            'Authorization': 'token ' + user.token,
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'item_set': item_set,
            'plantao': 'PLACEHOLDER000',
          }),
        );
        if (response.statusCode == 201) {
          return;
        } else {
          print(response.body);
          return;
        }
      } catch (e) {
        print(e);
        count++;
        sleep(const Duration(seconds: 5));
      }
    }
    return;
  }
}

class Item_old {
  int id;
  ItemBase itemBase;
  String _photo;
  int photoVersion = 0;
  String comment;
  String conformidade;
  bool isOk;
  bool isReady;

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemBase = ItemBase.fromJson(json['itemBase']);
    photoVersion = 0;
  }
  set photo(String path) {
    _photo = path;
    photoVersion += 1;
  }

  String get photo => _photo;

  String photoFileName() {
    /* Deve ser usado apenas antes de salvar o endereço em 'photo' */
    int v = photoVersion + 1;
    return '${id.toString()}_${v.toString()}.png';
  }
}
 */
