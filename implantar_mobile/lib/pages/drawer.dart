import 'package:flutter/material.dart';
import 'package:implantar_mobile/utilities/constantes.dart';

final _kDrawerListStyle = TextStyle(
  fontSize: 16.0,
  color: Colors.black54,
);

Widget buildDrawer() {
  return Drawer(
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
              Text('Redes', style: _kDrawerListStyle),
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
              Text('Contatos', style: _kDrawerListStyle),
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
              Text('Sair', style: _kDrawerListStyle),
            ],
          ),
          onTap: () {},
        ),
      ],
    ),
  );
}
