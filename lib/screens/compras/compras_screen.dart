import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/compra.dart';
import 'compra_form_screen.dart';
import 'compra_detalle_screen.dart';

class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});

  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  final DBHelper _db = DBHelper();
  List<Compra> _compras = [];

  @override
  void initState() {
    super.initState();
    _cargarCompras();
  }

  Future<void> _cargarCompras() async {
    final data = await _db.getCompras();
    setState(() {
      _compras = data.map((e) => Compra.fromMap(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compras')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CompraFormScreen()),
          );
          _cargarCompras();
        },
      ),
      body: _compras.isEmpty
          ? const Center(child: Text('No hay compras registradas'))
          : ListView.builder(
              itemCount: _compras.length,
              itemBuilder: (_, i) {
                final c = _compras[i];
                return ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: Text('Compra #${c.idCompra}'),
                  subtitle: Text(c.fecha),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CompraDetalleScreen(compra: c),
                    ),
                  ),
                );
              },
            ),
    );
  }
}