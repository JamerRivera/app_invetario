class Venta {
  final int? idVenta;
  final int idCliente;
  final String fecha;
  final String? nombreCliente; // para mostrar en UI

  Venta({
    this.idVenta,
    required this.idCliente,
    required this.fecha,
    this.nombreCliente,
  });

  Map<String, dynamic> toMap() => {
    'id_venta': idVenta,
    'id_cliente': idCliente,
    'fecha': fecha,
  };

  factory Venta.fromMap(Map<String, dynamic> map) => Venta(
    idVenta: map['id_venta'],
    idCliente: map['id_cliente'],
    fecha: map['fecha'],
    nombreCliente: map['nombre_cliente'],
  );
}
