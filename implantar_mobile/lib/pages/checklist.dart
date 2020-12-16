import 'package:flutter/material.dart';
import 'package:implantar_mobile/pages/TakePictureScreen.dart';
import 'package:implantar_mobile/services/user.dart';
import 'package:implantar_mobile/utilities/constantes.dart';
import 'package:implantar_mobile/api/models.dart';
import 'package:implantar_mobile/pages/checklist_signature.dart';

/* orientation */
import 'package:flutter/services.dart';

/* Camera */
import 'dart:io';
import 'package:camera/camera.dart';

/* PhotoUpload */
import 'package:http/http.dart' as http;
import 'package:implantar_mobile/services/config.dart' as co;

/* Files */
import 'package:path_provider/path_provider.dart';
/* Data Storage */
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<File> _moveFile(File sourceFile, String newPath) async {
  try {
    // prefer using rename as it is probably faster
    return await sourceFile.rename(newPath);
  } on FileSystemException catch (e) {
    // if rename fails, copy the source file and then delete it
    final newFile = await sourceFile.copy(newPath);
    await sourceFile.delete();
    return newFile;
  }
}

class Checklist extends StatefulWidget {
  final User user;
  final Rede rede;
  final Ponto ponto;
  Checklist(
      {Key key, @required this.user, @required this.rede, @required this.ponto})
      : super(key: key);

  @override
  _ChecklistState createState() => _ChecklistState(user, rede, ponto);
}

class _ChecklistState extends State<Checklist> {
  static const double kBorderRadius = 10;
  static const double kButtonHeight = 40;
  User user;
  Rede rede;
  Ponto ponto;
  Visita visita;
  _ChecklistState(this.user, this.rede, this.ponto);

  void _newChecklist() async {
    visita = Visita(rede, ponto, user);
    await visita.create();
    setState(() {
      print(visita.itens[0].text);
    });
  }

  Future<String> _takePic(ChecklistItem item) async {
    WidgetsFlutterBinding.ensureInitialized();
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;
    String path = await Navigator.of(this.context).push(
      MaterialPageRoute(
        builder: (context) =>
            TakePictureScreen(camera: firstCamera, visita: visita, item: item),
      ),
    );
    return path;
  }

  Future<dynamic> _uploadPhoto(ChecklistItem item, String path) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            co.API['base'] + co.API['item-photo'] + item.id.toString() + '/'));
    request.files.add(
      http.MultipartFile(
          'photo', File(path).readAsBytes().asStream(), File(path).lengthSync(),
          filename: path.split("/").last),
    );
    request.headers['Authorization'] = 'token ' + user.token;
    var res = await request.send();
    return res;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _newChecklist();
  }

  Widget _buildDescription(index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(kBorderRadius),
          topRight: Radius.circular(kBorderRadius),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 40),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '1',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Text(
              visita.itens[index].text,
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBAr(index) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: visita.itens[index].conformidade == 'NC'
                  ? Colors.redAccent
                  : Colors.red[100],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(kBorderRadius),
              ),
            ),
            height: kButtonHeight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  visita.itens[index].conformidade = 'NC';
                });
              },
              child: Icon(
                Icons.cancel,
                color: visita.itens[index].conformidade == 'NC'
                    ? Colors.white
                    : Colors.white24,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
            height: kButtonHeight,
            child: TextButton(
              onPressed: () async {
                ChecklistItem item = visita.itens[index];
                /* Retorna caminho temporário da imagem. */
                final _tempPath = await _takePic(item);
                /* Tenta fazer o upload da imagem/ armazenar no smartphone */
                if (_tempPath != null) {
                  try {
                    var res =
                        await _uploadPhoto(visita.itens[index], _tempPath);
                    if (res.statusCode == 200) {
                      print(_tempPath);
                      File f;
                      f = File(_tempPath);
                      await f.delete();
                      print(item.photoVersion.toString());
                      visita.itens[index].photo = _tempPath;
                    } else {
                      /* Em caso de erro, armazena no smartphone */
                      final directory =
                          await getApplicationDocumentsDirectory();
                      String _appPath =
                          '${directory.path}/v_${visita.id.toString()}_${item.id.toString()}.png';
                      _moveFile(File(_tempPath), _appPath);
                      /* Salvar path no sql */
                      WidgetsFlutterBinding.ensureInitialized();
                      // Open the database and store the reference.
                      Database db = await openDatabase(
                        // Set the path to the database. Note: Using the `join` function from the
                        // `path` package is best practice to ensure the path is correctly
                        // constructed for each platform.
                        join(await getDatabasesPath(), 'implantar.db'),
                        version: 1,
                      );
                      try {
                        await db.update(
                            'ck_item', {'id': item.id, 'photo': _appPath},
                            where: 'id = ?', whereArgs: [item.id]);
                        print(">>>>>>>>>>>>>>>>");
                        print("UPDATEEEEEEEEEEES");
                      } catch (e) {
                        print(">>>>>>>>>>>>>>>>");
                        print(e);
                        print(">>>>>>>>>>>>>>>>");
                        await db.insert(
                          'ck_item',
                          {'id': item.id, 'photo': _appPath},
                          conflictAlgorithm: ConflictAlgorithm.replace,
                        );
                      }
                      return;
                    }
                  } catch (e) {
                    print(">>>>>>>>>>>>>>>> ERROOORRR <<<<<<<<<<<<");
                    print(e);
                  }
                }
              },
              child: Icon(
                Icons.camera_alt,
                color: Colors.white54,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: visita.itens[index].conformidade == 'C'
                  ? Colors.green[400]
                  : Colors.green[100],
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(kBorderRadius),
              ),
            ),
            height: kButtonHeight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  visita.itens[index].conformidade = 'C';
                });
              },
              child: Icon(
                Icons.check,
                color: visita.itens[index].conformidade == 'C'
                    ? Colors.white
                    : Colors.white24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: kAccentColor),
          title: Text(
            rede.nome + ' ' + ponto.nome,
            style: kFont1,
          ),
        ),
        body: Column(
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5.0),
              itemCount: visita.itens.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDescription(index),
                        _buildActionBAr(index),
                      ],
                    ),
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  onPressed: () async {
                    dynamic temp = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChecklistSignature(
                            user: user,
                            rede: rede,
                            ponto: ponto,
                            visita: visita),
                      ),
                    );
                    await visita.update();
                    Navigator.pop(context);
                  },
                  color: kPrimaryColor,
                  child: Row(
                    children: [
                      Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                      ),
                      Text(
                        'Prosseguir para a coleta de assinatura',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
