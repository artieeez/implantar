import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:implantar_mobile/services/config.dart' as co;
import 'dart:io';
import 'package:implantar_mobile/services/user.dart';
import 'package:implantar_mobile/api/models.dart';

class ApiManagers {
  User user;
  String API_BASE;
  String API_ENDPOINT;
  List<ApiObject> results = [];
  int count;
  int next;
  int previous;

  ApiManagers() {
    API_BASE = co.API['base'];
  }

  Future<void> fetch() async {
    /* Fetch data into <this.results> */
    int count = 0; // tentativas de conexão
    while (count < co.CONN_LIMIT) {
      try {
        http.Response response = await http.get(
          API_BASE + API_ENDPOINT,
          headers: {'Authorization': 'token ' + user.token},
        );
        if (response.statusCode == 200) {
          Map data = jsonDecode(response.body);
          count = data['count'];
          next = data['next'];
          previous = data['previous'];
          serializer(data['results']);
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

  Future<List<ApiObject>> all() async {
    await fetch();
    return results;
  }

  void serializer(List<dynamic> data) {
    /* 
      Serializador deve ser implementado na classe filha.
    */
    throw ('Serializador não implementado.');
  }
}

class RedesObjects extends ApiManagers {
  RedesObjects(User _user) : super() {
    API_ENDPOINT = co.API['redes'];
    user = _user;
  }

  @override
  void serializer(List<dynamic> data) {
    for (int i = 0; i < data.length; i++) {
      results.add(Rede.fromJson(data[i]));
    }
  }
}

class PontosObjects extends ApiManagers {
  String redePk;
  PontosObjects(User _user, String redePk) : super() {
    API_ENDPOINT = co.API['redes'] + redePk + '/pontos/';
    user = _user;
  }

  @override
  void serializer(List<dynamic> data) {
    for (int i = 0; i < data.length; i++) {
      results.add(Ponto.fromJson(data[i]));
    }
  }
}
