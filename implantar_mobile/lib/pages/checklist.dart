import 'package:flutter/material.dart';
import 'package:implantar_mobile/services/user.dart';
import 'package:implantar_mobile/utilities/constantes.dart';
import 'package:implantar_mobile/api/models.dart';

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

  @override
  void initState() {
    super.initState();
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
              onPressed: () {},
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
            ButtonBar(
              children: [
                RaisedButton(
                  onPressed: () async {
                    await visita.update();
                    Navigator.pop(context);
                  },
                  child: Text('Concluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
