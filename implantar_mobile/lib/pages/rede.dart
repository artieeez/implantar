import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:implantar_mobile/utilities/constantes.dart';
import 'package:implantar_mobile/pages/pontos.dart';
import 'package:implantar_mobile/pages/drawer.dart';
import 'package:implantar_mobile/api/models.dart';

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

  Widget _returnRedeIcon(String nome, Uint8List byteList) {
    Widget _avatar;
    _avatar = CircleAvatar(
      backgroundColor: Colors.blueGrey[100],
      backgroundImage: byteList != null ? MemoryImage(byteList) : null,
      child: byteList != null
          ? null
          : Text(
              nome[0],
              style: TextStyle(
                color: kPrimaryColor,
              ),
            ),
    );
    return _avatar;
  }

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
      leading: _returnRedeIcon(rede.nome, rede.photoBytes),
    );
  }
}
