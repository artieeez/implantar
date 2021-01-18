import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:implantar_mobile/pages/rede.dart';
import 'package:implantar_mobile/services/session.dart';
import 'package:implantar_mobile/api/models.dart';
import 'package:implantar_mobile/pages/checklist.dart';

/* Screen Orientation */
import 'package:flutter/services.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Session session;

  void _syncInit() async {
    session = Session(this.context);
    await session.init();
    await _retomarVisita(session);
    Navigator.of(this.context).push(MaterialPageRoute(
      builder: (context) => RedeList(
        session: session,
      ),
    ));
  }

  Future<void> _retomarVisita(Session session) async {
    /* Verifica se o módulo session apontou sessão aberta */
    if (!session.visitaAberta) {
      return;
    }
    List<Map<String, dynamic>> queryResult = await session.db.rawQuery("""
      SELECT * FROM visita WHERE (concluded = ? OR concluded IS NULL)""", [0]);
    Visita visita = Visita.fromDb(session, data: queryResult[0]);
    Rede rede;
    Ponto ponto;
    outerloop:
    for (int i = 0; i < session.dataSync.redes.length; i++) {
      Rede row = session.dataSync.redes[i];
      for (int j = 0; j < row.pontos.length; j++) {
        Ponto col = row.pontos[j];
        if (col.id == visita.ponto.id) {
          rede = row;
          ponto = col;
          break outerloop;
        }
      }
    }
    await visita.initItens(session, novo: false);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Checklist(
          session: session,
          rede: rede,
          ponto: ponto,
          visita: visita,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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
