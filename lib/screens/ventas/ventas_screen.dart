import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/venta.dart';
import 'venta_form_screen.dart';
import 'venta_detalle_screen.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final DBHelper _db = DBHelper();
  List<Venta> _ventas = [];

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    final data = await _db.getVentas();
    setState(() {
      _ventas = data.map((e) => Venta.fromMap(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventas')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VentaFormScreen()),
          );
          _cargarVentas();
        },
      ),
      body: _ventas.isEmpty
          ? const Center(child: Text('No hay ventas registradas'))
          : ListView.builder(
              itemCount: _ventas.length,
              itemBuilder: (_, i) {
                final v = _ventas[i];
                return ListTile(
                  leading: const Icon(Icons.point_of_sale),
                  title: Text('Venta #${v.idVenta}'),
                  subtitle: Text(
                    'Cliente: ${v.nombreCliente ?? ''}\n${v.fecha}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VentaDetalleScreen(venta: v),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
