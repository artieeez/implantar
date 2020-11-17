import 'package:flutter/material.dart';
import 'package:implantar_mobile/services/user.dart';
import 'package:implantar_mobile/utilities/constantes.dart';
import 'package:implantar_mobile/api/pontosObjects.dart';
import 'package:implantar_mobile/pages/drawer.dart';

class PontoList extends StatefulWidget {
  final User user;
  final String redePk;
  PontoList({Key key, @required this.user, @required this.redePk})
      : super(key: key);

  @override
  _PontoListState createState() => _PontoListState(user, redePk);
}

class _PontoListState extends State<PontoList> {
  User user;
  String redePk;
  _PontoListState(this.user, this.redePk);

  Map data = {};
  PontosObjects pontos;
  List<dynamic> results = [];

  void getList() async {
    pontos = PontosObjects(user, redePk);
    await pontos.all();
    setState(() {
      results = pontos.results;
    });
  }

  @override
  void initState() {
    super.initState();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: kAccentColor),
        title: Text(
          'Redes',
          style: kFont1,
        ),
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: results?.length ?? 0,
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(); /*2*/

          final index = i ~/ 2; /*3*/
          if (index >= results.length) {
            /*4*/
          }
          return _buildRow(results[index]);
        });
  }

  Widget _buildRow(Map<String, dynamic> rede) {
    return ListTile(
      title: Text(
        rede['nome'],
      ),
      onTap: () => {},
      leading: CircleAvatar(
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}
