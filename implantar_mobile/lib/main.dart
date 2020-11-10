import 'package:flutter/material.dart';
import 'package:implantar_mobile/pages/loading.dart';

void main() => runApp(MaterialApp(
      title: 'Implantar',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        accentColor: const Color(0xFFacc99b),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Loading(),
      },
    ));
