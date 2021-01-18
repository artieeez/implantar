import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:implantar_mobile/services/settings.dart' as settings;
import 'dart:io';
import 'dart:convert';
import 'package:implantar_mobile/services/session.dart';
import 'package:path_provider/path_provider.dart';

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
  bool concluded = false;
  bool sent = false;
  DateTime inicio;
  DateTime termino;
  static String _signature;
  static int _signatureVersion;
  Uint8List signatureBytes;
  List<Item> itens = [];
  String plantao;
  Ponto ponto;
  static bool _itensReady;
  Visita();

  void setSignature(Session session, Uint8List imageBytes) async {
    _signatureVersion += 1;
    final directory = await getApplicationDocumentsDirectory();
    String finalPath =
        """${directory.path}/visita_$clientId/${signatureFileName()}""";
    if (_signature != null) {
      File file = File(_signature);
      file.delete();
    }
    session.db.rawInsert(
      """UPDATE visita SET signature = ? WHERE clientId = ?""",
      [finalPath, clientId],
    );
    _signature = finalPath;

    File(finalPath).writeAsBytes(imageBytes);
  }

  String get signature => _signature;

  String signatureFileName() {
    return 'signature_${_signatureVersion.toString()}.png';
  }

  Visita.fromDb(Session session, {Map<String, dynamic> data}) {
    /* Inicializa visita a partir do banco */
    id = data['id'];
    clientId = data['clientId'];
    concluded = data['concluded'] == 1 ? true : false;
    sent = data['sent'] == 1 ? true : false;
    inicio = DateTime.parse(data['inicio']);
    termino = data['termino'] != null ? DateTime.parse(data['termino']) : null;
    _signature = data['signature'];
    plantao = data['plantao'];
    ponto = session.dataSync.getPonto(id: data['ponto_id']);
    _itensReady = false;
  }

  Future<void> initItens(Session session, {bool novo: false}) async {
    _itensReady = true;
    if (novo) {
      /* Inicializa novos itens */
      int itemClientId = await _getItemClientId(session.db);
      for (int i = 0; i < session.dataSync.itemBases.length; i++) {
        Item item = Item(
          clientId: itemClientId,
          itemBase: session.dataSync.itemBases[i],
          ponto: ponto,
          visita: this,
        );
        itens.add(item);
        itemClientId++;
      }
    } else {
      /* Inicializa com dados do DB */
      List<ItemBase> itemBasesList = session.dataSync.itemBases;
      List<dynamic> itensMaps = await session.db
          .rawQuery("""SELECT * FROM item WHERE visita_id = ?""", [clientId]);
      for (int i = 0; i < itensMaps.length; i++) {
        Map row = itensMaps[i];
        ItemBase itemBase;
        for (int j = 0; j < itemBasesList.length; j++) {
          if (itemBasesList[j].id == row['itemBase_id']) {
            itemBase = itemBasesList[j];
          }
        }
        bool _rowSent = row['sent'] == 1 ? true : false;
        Item item = Item(
          clientId: row['clientId'],
          sent: _rowSent,
          conformidade: row['conformidade'],
          comment: row['comment'],
          photoVersion: row['photoVersion'],
          itemBase: itemBase,
          photo: row['photo'],
          ponto: ponto,
          visita: this,
        );
        itens.add(item);
      }
    }
  }

  Future<Visita> init(
    Session session, {
    Rede rede,
    Ponto ponto,
    List<ItemBase> itemBases,
  }) async {
    /* Inicializa nova visita */
    this.ponto = ponto;
    clientId = await _getClientId(session.db);
    this.inicio = new DateTime.now();
    this.concluded = false;
    await initItens(session, novo: true);
    _toDb(session.db);
    return this;
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

  void _toDb(Database db) async {
    db.transaction((txn) async {
      await txn.rawInsert(
          """INSERT INTO visita(clientId, ponto_id, inicio, concluded)
          VALUES(?, ?, ?, ?)""",
          [clientId, ponto.id, inicio.toIso8601String(), concluded]);
    });
    db.transaction((txn) async {
      for (int i = 0; i < itens.length; i++) {
        Item row = itens[i];
        await txn.rawInsert(
            """INSERT INTO item(clientId, visita_id, itemBase_id) VALUES(?, ?, ?)""",
            [row.clientId, clientId, row.itemBase.id]);
      }
    });
  }

  Future<void> save(Session session) async {
    this.concluded = true;
    this.termino = new DateTime.now();
    session.db.transaction((txn) async {
      await txn.rawInsert(
          """UPDATE visita SET concluded = ?, termino = ? WHERE clientId = ?""",
          [1, termino.toIso8601String(), clientId]);
    });
    try {
      await _enviar(session);
      await _uploadSignature(session);
      await _uploadPhotos(session);
      this.sent = true;
      session.db.transaction((txn) async {
        await txn.rawInsert(
            """UPDATE visita SET sent = ? WHERE clientId = ?""", [1, clientId]);
      });
      _cleanData(session);
    } catch (e) {
      print(e);
    }
  }

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
            'ponto_id': ponto.id.toString(),
            'item_set': item_set,
            'inicio': inicio.toIso8601String(),
            'termino': termino.toIso8601String(),
            'plantao': 'FIXME',
          }),
        );
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

  Future<void> _cleanData(Session session) async {
    File signatureFile = File(signature);
    await signatureFile.delete();
    session.db.transaction((txn) async {
      for (int i = 0; i < itens.length; i++) {
        File f = File(itens[i].photo);
        await f.delete();
        txn.rawDelete(
            'DELETE FROM item WHERE clientId = ?', [itens[i].clientId]);
      }
    });
    session.db.rawDelete('DELETE FROM visita WHERE clientId = ?', [clientId]);
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
  final int clientId;
  final ItemBase itemBase;
  bool sent;
  String _photo;
  String _conformidade;
  String comment;
  int photoVersion;

  Ponto ponto;
  Visita visita;

  Item({
    this.clientId,
    this.sent: false,
    this.comment,
    this.photoVersion: 0,
    this.itemBase,
    this.ponto,
    this.visita,
    String conformidade,
    String photo,
  }) {
    if (photo != null) {
      _photo = photo;
    }
    conformidade == null ? _conformidade = 'NO' : _conformidade = conformidade;
  }

  void setConformidade(Session session, String confValue) async {
    List<String> conformidadeList = ['NO', 'C', 'NC'];
    if (conformidadeList.contains(confValue)) {
      _conformidade = confValue;
      /* Salvar path no banco */
      session.db.transaction((txn) async {
        await txn.rawInsert(
            """UPDATE item SET conformidade = ? WHERE clientId = ?""",
            [confValue, clientId]);
      });
    } else {
      throw ('Conformidade inválida.');
    }
  }

  void setFoto(Session session, Uint8List imageBytes) async {
    photoVersion += 1;
    final directory = await getApplicationDocumentsDirectory();
    String finalPath =
        """${directory.path}/visita_${visita.clientId}/${photoFileName()}""";
    if (_photo != null) {
      File file = File(_photo);
      file.delete();
    }
    session.db.rawInsert(
      """UPDATE item SET photo = ?, photoVersion = ? WHERE clientId = ?""",
      [finalPath, photoVersion, clientId],
    );
    _photo = finalPath;

    File(finalPath).writeAsBytes(imageBytes);
  }

  String get conformidade => _conformidade;
  String get photo => _photo;

  String photoFileName() {
    return '${clientId.toString()}_${photoVersion.toString()}.png';
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
      http.MultipartFile('photo', File(_photo).readAsBytes().asStream(),
          File(_photo).lengthSync(),
          filename: _photo.split("/").last),
    );
    request.headers['Authorization'] = 'token ' + session.user.token;
    var res = await request.send();
    return res;
  }
}
