import 'package:flutter/material.dart';
import 'package:implantar_mobile/utilities/constantes.dart';
import 'package:implantar_mobile/pages/drawer.dart';
import 'package:implantar_mobile/pages/checklist.dart';
import 'package:implantar_mobile/api/models.dart';

/* Services */
import 'package:implantar_mobile/services/session.dart';

/* Screen Orientation */
import 'package:flutter/services.dart';

class PontoList extends StatefulWidget {
  final Session session;
  final Rede rede;
  PontoList({Key key, @required this.session, @required this.rede})
      : super(key: key);

  @override
  _PontoListState createState() => _PontoListState(session, rede);
}

class _PontoListState extends State<PontoList> {
  Session session;
  Rede rede;
  _PontoListState(this.session, this.rede);

  List<Ponto> results = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    results = rede.pontos;
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

  Widget _buildRow(Ponto ponto) {
    return ListTile(
      title: Text(
        ponto.nome,
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              Checklist(session: session, rede: rede, ponto: ponto),
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}
