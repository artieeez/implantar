class ImplantarConfig {
  /* Backend config */
  static const bool dev = true;
  String protocol = dev ? 'http://' : 'https://';
  String domain = dev ? '192.168.0.10:8080/' : '';
}
