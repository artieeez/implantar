import 'package:flutter/material.dart';
import 'package:implantar_mobile/services/user.dart';
import 'package:implantar_mobile/utilities/constantes.dart';
import 'package:implantar_mobile/api/redesObjects.dart';
import 'package:implantar_mobile/pages/pontos.dart';
import 'package:implantar_mobile/pages/drawer.dart';

class RedeList extends StatefulWidget {
  final User user;
  RedeList({Key key, @required this.user}) : super(key: key);

  @override
  _RedeListState createState() => _RedeListState(user);
}

class _RedeListState extends State<RedeList> {
  User user;
  _RedeListState(this.user);

  Map data = {};
  RedesObjects redes;
  List<dynamic> results = [];

  void _getList() async {
    redes = RedesObjects(user);
    await redes.all();
    setState(() {
      results = redes.results;
    });
  }

  @override
  void initState() {
    super.initState();
    _getList();
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
          print(i);
          if (i.isOdd) return Divider(); /*2*/

          final index = i ~/ 2; /*3*/
          if (index >= results.length) {
            /*4*/
          }
          return _buildRow(context, results[index]);
        });
  }

  Widget _buildRow(BuildContext context, Map<String, dynamic> rede) {
    return ListTile(
      title: Text(
        rede['nome'],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PontoList(user: user, redePk: rede['id'].toString()),
      )),
      leading: CircleAvatar(
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}
