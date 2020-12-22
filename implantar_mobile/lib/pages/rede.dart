import 'package:flutter/material.dart';
import 'package:implantar_mobile/utilities/constantes.dart';
import 'package:implantar_mobile/pages/pontos.dart';
import 'package:implantar_mobile/pages/drawer.dart';
import 'package:implantar_mobile/api/models.dart';
import 'dart:io';

/* Services */
import 'package:implantar_mobile/services/session.dart';

/* Screen Orientation */
import 'package:flutter/services.dart';

class RedeList extends StatefulWidget {
  final Session session;
  RedeList({Key key, @required this.session}) : super(key: key);

  @override
  _RedeListState createState() => _RedeListState(session);
}

class _RedeListState extends State<RedeList> {
  Session session;
  _RedeListState(this.session);

  List<Rede> results;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    results = session.dataSync.redes;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        drawer: buildDrawer(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: kAccentColor),
          title: Text(
            'Redes',
            style: kFont1,
          ),
        ),
        body: _buildSuggestions(),
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: results?.length * 2 ?? 0,
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(); /*2*/

          final index = i ~/ 2; /*3*/
          if (index >= results.length) {
            /*4*/
          }
          return _buildRow(context, results[index]);
        });
  }

  Widget _buildRow(BuildContext context, Rede rede) {
    return ListTile(
      title: Text(
        rede.nome,
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PontoList(session: session, rede: rede),
        ),
      ),
      leading: CircleAvatar(
        backgroundImage: rede.photo != null
            ? AssetImage(rede.photo)
            : NetworkImage('https://via.placeholder.com/150'),
      ),
    );
  }
}
