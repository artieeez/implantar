import 'package:implantar_mobile/services/session.dart';
import 'package:implantar_mobile/api/models.dart';

String visitaIdGenerator(
  Session session, {
  Rede rede,
  Ponto ponto,
}) {
  String uId = session.user.id.toString();
  String vCount = session.user.vCount.toString();
  String rId = rede.id.toString();
  String pId = ponto.id.toString();

  return 'u' + uId + 'c' + vCount + 'r' + rId + 'p' + pId;
}
