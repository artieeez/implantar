import 'package:implantar_mobile/api/managers.dart';
import 'package:implantar_mobile/services/user.dart';

class ApiObject {
  String url;
  String id;
  String nome;
  String photo;
  String t_created;
  String t_modified;

  ApiManagers objects;
}

class Rede extends ApiObject {
  ApiManagers pontos;

  void initPontos(User _user) {
    pontos = PontosObjects(_user, id);
    print(pontos.user.token);
  }

  Rede(user) {
    objects = RedesObjects(user);
  }

  Rede.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    id = json['id'].toString();
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
    id = json['id'].toString();
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
