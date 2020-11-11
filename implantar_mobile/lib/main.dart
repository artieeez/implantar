import 'package:flutter/material.dart';
import 'package:implantar_mobile/pages/loading.dart';
import 'package:implantar_mobile/pages/login.dart';

void main() => runApp(MaterialApp(
      title: 'Implantar',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        accentColor: const Color(0xFFacc99b),
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => Loading(),
        '/login': (context) => Login(),
      },
    ));
