/* Backend config */
const String USER_TABLE = 'user';
const int CONN_LIMIT = 3;

const Map<String, String> API = {
  'base': 'http://192.168.0.10/api/',
  'hasConnection': '',
  'dbVersion': 'get_version/',
  'auth': 'token-auth/',
  'redes': 'redes/',
  'visitas': 'visitas/',
  'item-photo': 'item-photo/',
  'signature': 'signature/',
  'itemBase': 'item_base?active=true',
};

/* Usar cache 
  Necessário para modo offline */
const bool CACHE = true;

/* Carregar visitas em aberto */
const bool VISITA_SAFE = false;
