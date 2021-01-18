import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:implantar_mobile/pages/TakePictureScreen.dart';
import 'package:implantar_mobile/utilities/constantes.dart';
import 'package:implantar_mobile/api/models.dart';
import 'package:implantar_mobile/pages/checklist_signature.dart';

/* Services */
import 'package:implantar_mobile/services/session.dart';

/* orientation */
import 'package:flutter/services.dart';

import 'package:camera/camera.dart';
import 'dart:async';

class Checklist extends StatefulWidget {
  final Session session;
  final Rede rede;
  final Ponto ponto;
  final Visita visita;
  Checklist({
    Key key,
    @required this.session,
    @required this.rede,
    @required this.ponto,
    this.visita,
  }) : super(key: key);

  @override
  _ChecklistState createState() =>
      _ChecklistState(session, rede, ponto, visita);
}

class _ChecklistState extends State<Checklist> {
  Session session;
  Rede rede;
  Ponto ponto;
  Visita visita;

  static const double kBorderRadius = 10;
  static const double kButtonHeight = 40;

  _ChecklistState(this.session, this.rede, this.ponto, this.visita);

  @override
  void initState() {
    super.initState();
    /* Cria nova visita caso necessário */
    if (visita == null) {
      visita = Visita();
      _newChecklist();
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void _newChecklist() async {
    visita = await Visita().init(
      session,
      rede: rede,
      ponto: ponto,
      itemBases: session.dataSync.itemBases,
    );
    setState(() {});
  }

  void _save() async {
    await visita.save(session);
  }

  Future<Uint8List> _takePic(Item item) async {
    WidgetsFlutterBinding.ensureInitialized();
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;
    Uint8List photoBytes = await Navigator.of(this.context).push(
      MaterialPageRoute(
        builder: (context) =>
            TakePictureScreen(camera: firstCamera, visita: visita, item: item),
      ),
    );
    return photoBytes;
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
              visita.itens[index].itemBase.text,
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
            /* Botão de Não Conformidade */
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
                  visita.itens[index].setConformidade(session, 'NC');
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
            /* Botão de Foto */
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
            height: kButtonHeight,
            child: TextButton(
              onPressed: () async {
                Item item = visita.itens[index];
                /* Retorna caminho temporário da imagem. */
                final Uint8List photoBytes = await _takePic(item);
                /* armazenar no smartphone */
                if (photoBytes != null) {
                  item.setFoto(session, photoBytes);
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
            /* Botão de Conformidade */
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
                  visita.itens[index].setConformidade(session, 'C');
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
                    final Uint8List signatureBytes =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChecklistSignature(
                            user: session.user,
                            rede: rede,
                            ponto: ponto,
                            visita: visita),
                      ),
                    );
                    /* Save  */
                    if (signatureBytes != null) {
                      visita.signatureBytes = signatureBytes;
                      _save();
                      Navigator.pop(context);
                    }
                    /* Continuar editando */
                    return;
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
