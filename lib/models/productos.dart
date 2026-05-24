class Producto {
  final int? idProducto;
  final String nombre;
  final int stock;

  Producto({this.idProducto, required this.nombre, this.stock = 0});

  Map<String, dynamic> toMap() => {
    'id_producto': idProducto,
    'nombre': nombre,
    'stock': stock,
  };

  factory Producto.fromMap(Map<String, dynamic> map) => Producto(
    idProducto: map['id_producto'],
    nombre: map['nombre'],
    stock: map['stock'] ?? 0,
  );
}
