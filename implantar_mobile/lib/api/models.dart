import 'package:implantar_mobile/api/managers.dart';
import 'package:implantar_mobile/services/user.dart';
import 'package:http/http.dart' as http;
import 'package:implantar_mobile/services/config.dart' as co;
import 'dart:io';
import 'dart:convert';

class ApiObject {
  String url;
  int id;
  String nome;
  String photo;
  String t_created;
  String t_modified;

  ApiManagers objects;
}

class Rede extends ApiObject {
  ApiManagers pontos;

  void initPontos(User _user) {
    pontos = PontosObjects(_user, id.toString());
  }

  Rede(user) {
    objects = RedesObjects(user);
  }

  Rede.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    id = json['id'];
    nome = json['nome'];
    photo = json['photo'];
    t_created = json['t_created'];
    t_modified = json['t_modified'];
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'id': id,
        'nome': nome,
        'photo': photo,
        't_created': t_created,
        't_modified': t_modified,
      };
}

class Ponto extends ApiObject {
  Ponto(User user, String redePk) {
    objects = PontosObjects(user, redePk);
  }

  Ponto.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    id = json['id'];
    nome = json['nome'];
    t_created = json['t_created'];
    t_modified = json['t_modified'];
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'id': id,
        'nome': nome,
        't_created': t_created,
        't_modified': t_modified,
      };
}

class Visita {
  String API_BASE;
  String API_ENDPOINT;
  User user;
  Rede rede;
  Ponto ponto;
  List<ChecklistItem> itens = [];

  int id;

  Visita(rede, ponto, user) {
    this.rede = rede;
    this.ponto = ponto;
    this.user = user;
    this.API_BASE = co.API['base'];
    this.API_ENDPOINT = co.API['visitas'];
  }

  Future<void> create() async {
    int count = 0; // tentativas de conexão
    while (count < co.CONN_LIMIT) {
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
        if (response.statusCode == 200) {
          Map data = jsonDecode(response.body);
          id = data['id'];
          for (int i; i < data['item_set'].length; i++) {
            ChecklistItem item = ChecklistItem.fromJson(data['item_set'][i]);
            itens.add(item);
          }
          print(itens[0].text);
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
}

class ChecklistItem {
  int id;
  int item;
  String text;
  dynamic photo;
  String comment;
  String conformidade;
  bool isOk;
  bool isReady;

  ChecklistItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    text = json['text'];
  }
}
