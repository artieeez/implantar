import 'package:http/http.dart';
import 'dart:convert';
import 'package:implantar_mobile/services/config.dart';

class Rede {
  String baseUrl;

  Rede() {
    ImplantarConfig config = ImplantarConfig();
    baseUrl = config.protocol + config.domain;
  }

  Future<void> getList() async {
    try {
      Response response = await get(baseUrl + 'redes');
      Map data = jsonDecode(response.body);
      print(data);
    } catch (e) {}
  }
}
