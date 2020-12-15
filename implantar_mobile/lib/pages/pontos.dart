import 'package:flutter/material.dart';
import 'package:implantar_mobile/services/user.dart';
import 'package:implantar_mobile/utilities/constantes.dart';
import 'package:implantar_mobile/pages/drawer.dart';
import 'package:implantar_mobile/pages/checklist.dart';
import 'package:implantar_mobile/api/managers.dart';
import 'package:implantar_mobile/api/models.dart';

/* Screen Orientation */
import 'package:flutter/services.dart';

class PontoList extends StatefulWidget {
  final User user;
  final Rede rede;
  PontoList({Key key, @required this.user, @required this.rede})
      : super(key: key);

  @override
  _PontoListState createState() => _PontoListState(user, rede);
}

class _PontoListState extends State<PontoList> {
  User user;
  Rede rede;
  _PontoListState(this.user, this.rede);

  Map data = {};
  PontosObjects pontos;
  List<ApiObject> results = [];

  void getList() async {
    rede.initPontos(user);
    List<ApiObject> tempListawait = await rede.pontos.all();
    setState(() {
      results = tempListawait;
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: kAccentColor),
        title: Text(
          rede.nome,
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

  Widget _buildRow(ApiObject ponto) {
    return ListTile(
      title: Text(
        ponto.nome,
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Checklist(user: user, rede: rede, ponto: ponto),
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}
