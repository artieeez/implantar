import 'dart:ffi';
import 'dart:typed_data';

import 'package:implantar_mobile/services/user.dart';
import 'package:http/http.dart' as http;
import 'package:implantar_mobile/services/settings.dart' as settings;
import 'dart:io';
import 'dart:convert';

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

  Ponto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
  }
}

class Visita {
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
