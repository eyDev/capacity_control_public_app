class Constants {
  static final Constants _instancia = new Constants._();
  factory Constants() {
    return _instancia;
  }
  Constants._();

  String get baseUrl {
    return 'DOMINIO-DEL-SERVIDOR';
  }
}
