import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:implantar_mobile/pages/rede.dart';
import 'package:implantar_mobile/services/user.dart';
import 'package:permission_handler/permission_handler.dart';

/* Screen Orientation */
import 'package:flutter/services.dart';

/* Data Storage */
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  User user;

  Future<void> _createDataBases() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Open the database and store the reference.
    Database db = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'implantar.db'),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE user(id AUTO_INCREMENT INTEGER PRIMARY KEY, nome TEXT, token TEXT)",
        );
        await db.execute(
          "CREATE TABLE rede(id INTEGER PRIMARY KEY, nome TEXT, photo TEXT, pontos)",
        );
        await db.execute(
          "CREATE TABLE ponto(id INTEGER PRIMARY KEY, nome TEXT, visitas)",
        );
        await db.execute(
          "CREATE TABLE ck_item(id INTEGER PRIMARY KEY, photo TEXT, signature TEXT, conformidade TEXT)",
        );
        return;
      },
      version: 1,
    );
    db.close();
    return;
  }

  Future<void> login() async {
    User newUserInstance = User(this.context);
    await newUserInstance.init();
    user = newUserInstance;

    Navigator.of(this.context).push(MaterialPageRoute(
      builder: (context) => RedeList(user: user),
    ));
    /* Navigator.pushReplacementNamed(context, '/list', arguments: {'user': user}); */
  }

  void _syncInit() async {
    await _createDataBases();
    await login();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    Permission.storage.request();
    _syncInit();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg_a.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitFadingCircle(
                    color: const Color(0x9Fe9d6bd),
                    size: 30.0,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Carregando',
                    style: TextStyle(
                      letterSpacing: 2.0,
                      fontSize: 16.0,
                      color: const Color(0x9Fe9d6bd),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
