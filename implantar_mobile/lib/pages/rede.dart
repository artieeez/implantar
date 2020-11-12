import 'package:flutter/material.dart';
import 'package:implantar_mobile/services/user.dart';
import 'package:implantar_mobile/utilities/constantes.dart';
import 'package:path/path.dart';

final kTextStyle = TextStyle(
  color: kAccentColor,
  fontSize: 24.0,
);

final kDrawerListStyle = TextStyle(
  fontSize: 16.0,
  color: Colors.black54,
);

class RedeList extends StatefulWidget {
  @override
  _RedeListState createState() => _RedeListState();
}

class _RedeListState extends State<RedeList> {
  User user;
  Map data = {};

  @override
  Widget build(BuildContext context) {
    /* data = data.isNotEmpty ? data : ModalRoute.of(context).settings.arguments;
    setState(() {
      user = data['user'];
    }); */
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 80,
                    width: 80,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Implantar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 48.0,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        'SOLUÇÕES PARA ALIMENTOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'NotoSans',
                          fontSize: 12.0,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: kPrimaryColor,
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.restaurant),
                  SizedBox(width: 15.0),
                  Text('Redes', style: kDrawerListStyle),
                ],
              ),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 15.0),
                  Text('Contatos', style: kDrawerListStyle),
                ],
              ),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 15.0),
                  Text('Sair', style: kDrawerListStyle),
                ],
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: kAccentColor),
        title: Text(
          'Redes',
          style: kFont1,
        ),
      ),
      body: Container(),
    );
  }
}

/* onPressed: () => Scaffold.of(context).openDrawer(), */
