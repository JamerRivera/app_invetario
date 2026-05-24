class Compra {
  final int? idCompra;
  final String fecha;

  Compra({this.idCompra, required this.fecha});

  Map<String, dynamic> toMap() => {'id_compra': idCompra, 'fecha': fecha};

  factory Compra.fromMap(Map<String, dynamic> map) =>
      Compra(idCompra: map['id_compra'], fecha: map['fecha']);
}
