class DetalleCompra {
  final int idCompra;
  final int idProducto;
  final int cantidad;
  final double precioUnitario;
  final String? nombreProducto; // para mostrar en UI

  DetalleCompra({
    required this.idCompra,
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
    this.nombreProducto,
  });

  Map<String, dynamic> toMap() => {
    'id_compra': idCompra,
    'id_producto': idProducto,
    'cantidad': cantidad,
    'precio_unitario': precioUnitario,
  };

  factory DetalleCompra.fromMap(Map<String, dynamic> map) => DetalleCompra(
    idCompra: map['id_compra'],
    idProducto: map['id_producto'],
    cantidad: map['cantidad'],
    precioUnitario: (map['precio_unitario'] as num).toDouble(),
    nombreProducto: map['nombre'],
  );
}
