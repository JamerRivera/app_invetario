import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/venta.dart';
import '../../models/detalle_venta.dart';

class VentaDetalleScreen extends StatefulWidget {
  final Venta venta;
  const VentaDetalleScreen({super.key, required this.venta});

  @override
  State<VentaDetalleScreen> createState() => _VentaDetalleScreenState();
}

class _VentaDetalleScreenState extends State<VentaDetalleScreen> {
  final DBHelper _db = DBHelper();
  List<DetalleVenta> _detalle = [];

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    final data = await _db.getDetalleVenta(widget.venta.idVenta!);
    setState(() {
      _detalle = data.map((e) => DetalleVenta.fromMap(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle Venta #${widget.venta.idVenta}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cliente: ${widget.venta.nombreCliente ?? ''}'),
                Text('Fecha: ${widget.venta.fecha}'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _detalle.length,
              itemBuilder: (_, i) {
                final item = _detalle[i];
                return ListTile(
                  title: Text(item.nombreProducto ?? ''),
                  subtitle: Text('Cantidad: ${item.cantidad}'),
                  trailing: Text('\$${item.precioUnitario.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
