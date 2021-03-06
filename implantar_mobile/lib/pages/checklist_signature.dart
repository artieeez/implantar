import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:implantar_mobile/services/user.dart';
import 'package:implantar_mobile/api/models.dart';

import 'dart:async';

/* Screen Orientation */
import 'package:flutter/services.dart';

/* Signature */
import 'package:signature/signature.dart';

class ChecklistSignature extends StatefulWidget {
  final User user;
  final Rede rede;
  final Ponto ponto;
  final Visita visita;
  ChecklistSignature(
      {Key key,
      @required this.user,
      @required this.rede,
      @required this.ponto,
      @required this.visita})
      : super(key: key);

  @override
  _ChecklistSignatureState createState() =>
      _ChecklistSignatureState(user, rede, ponto, visita);
}

class _ChecklistSignatureState extends State<ChecklistSignature> {
  SignatureController _controller;
  var _signatureCanvas;
  var signatureBytes;
  var signaturePath;
  bool confirm;

  User user;
  Rede rede;
  Ponto ponto;
  Visita visita;
  _ChecklistSignatureState(this.user, this.rede, this.ponto, this.visita);

  Future<void> _getSignature() async {
    if (_controller.isEmpty) {
      await showAlertDialogBranco(context);
      return;
    } else {
      await showAlertDialogConfirm(context);
      if (confirm) {
        Uint8List signatureBytes = await _controller.toPngBytes();
        /* _uploadSignature(visita, signatureBytes); */
        Navigator.pop(context, signatureBytes);
      } else {
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
    _controller = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _signatureCanvas = Signature(
      controller: _controller,
      width: 500,
      height: 300,
      backgroundColor: Colors.white,
    );
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                  },
                  child: Icon(
                    Icons.undo,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _getSignature();
                  },
                  child: Icon(
                    Icons.done,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          _signatureCanvas,
        ],
      ),
    );
  }

  Future<void> showAlertDialogBranco(BuildContext context) async {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () async {
        return Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Canvas em branco"),
      content: Text("Insira uma assinatura."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<bool> showAlertDialogConfirm(BuildContext context) async {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("Confirmar"),
      onPressed: () {
        confirm = true;
        return Navigator.of(context).pop();
      },
    );

    Widget cancelButton = FlatButton(
      child: Text("Cancelar"),
      onPressed: () {
        confirm = false;
        return Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirmação"),
      content: Text("Prosseguir com esta assinatura?"),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
