import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/compra.dart';
import '../../models/detalle_compra.dart';

class CompraDetalleScreen extends StatefulWidget {
  final Compra compra;
  const CompraDetalleScreen({super.key, required this.compra});

  @override
  State<CompraDetalleScreen> createState() => _CompraDetalleScreenState();
}

class _CompraDetalleScreenState extends State<CompraDetalleScreen> {
  final DBHelper _db = DBHelper();
  List<DetalleCompra> _detalle = [];

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    final data = await _db.getDetalleCompra(widget.compra.idCompra!);
    setState(() {
      _detalle = data.map((e) => DetalleCompra.fromMap(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle Compra #${widget.compra.idCompra}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Fecha: ${widget.compra.fecha}'),
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