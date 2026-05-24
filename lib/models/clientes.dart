class Cliente {
  final int? idCliente;
  final String nombre;
  final String? telefono;

  Cliente({this.idCliente, required this.nombre, this.telefono});

  Map<String, dynamic> toMap() => {
    'id_cliente': idCliente,
    'nombre': nombre,
    'telefono': telefono,
  };

  factory Cliente.fromMap(Map<String, dynamic> map) => Cliente(
    idCliente: map['id_cliente'],
    nombre: map['nombre'],
    telefono: map['telefono'],
  );
}
