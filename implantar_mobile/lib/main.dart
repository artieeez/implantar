import 'package:flutter/material.dart';
import 'package:implantar_mobile/pages/loading.dart';
import 'package:implantar_mobile/pages/login.dart';
import 'package:implantar_mobile/pages/rede.dart';
import 'package:implantar_mobile/utilities/constantes.dart';

void main() => runApp(MaterialApp(
      title: 'Implantar',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: kPrimaryColor,
        accentColor: kAccentColor,
      ),
      initialRoute: '/list',
      routes: {
        '/list': (context) => RedeList(),
      },
    ));
