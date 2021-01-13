/* Backend config */
const String USER_TABLE = 'user';
const int CONN_LIMIT = 3;

const Map<String, String> API = {
  'base': 'http://192.168.0.10:8080/',
  'hasConnection': 'api/',
  'dbVersion': 'api/get_version/',
  'auth': 'api/token-auth/',
  'redes': 'api/redes/',
  'visitas': 'api/visitas/',
  'item-photo': 'api/item-photo/',
  'signature': 'api/signature/',
  'itemBase': 'api/item_base/active/',
};

const bool CACHE = true;
