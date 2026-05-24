class DetalleVenta {
  final int idVenta;
  final int idProducto;
  final int cantidad;
  final double precioUnitario;
  final String? nombreProducto; // para mostrar en UI

  DetalleVenta({
    required this.idVenta,
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
    this.nombreProducto,
  });

  Map<String, dynamic> toMap() => {
    'id_venta': idVenta,
    'id_producto': idProducto,
    'cantidad': cantidad,
    'precio_unitario': precioUnitario,
  };

  factory DetalleVenta.fromMap(Map<String, dynamic> map) => DetalleVenta(
    idVenta: map['id_venta'],
    idProducto: map['id_producto'],
    cantidad: map['cantidad'],
    precioUnitario: (map['precio_unitario'] as num).toDouble(),
    nombreProducto: map['nombre'],
  );
}
