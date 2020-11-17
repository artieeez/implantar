import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:implantar_mobile/services/config.dart' as co;
import 'dart:io';
import 'package:implantar_mobile/services/user.dart';

class RedesObjects {
  static User _user;
  List<dynamic> results = [];
  int count;
  int next;
  int previous;

  RedesObjects(User user) {
    _user = user;
  }

  Future<void> all() async {
    int count = 0; // tentativas de conexão
    /* Testa token acessando a raiz da api */
    while (count < co.CONN_LIMIT) {
      try {
        http.Response response = await http.get(
          co.API['base'] + co.API['redes'],
          headers: {'Authorization': 'token ' + _user.token},
        );
        if (response.statusCode == 200) {
          Map data = jsonDecode(response.body);
          count = data['count'];
          next = data['next'];
          previous = data['previous'];
          results = data['results'];
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
