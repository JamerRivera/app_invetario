import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/productos.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DBHelper _db = DBHelper();
  List<Producto> _productos = [];
  int _totalVentas = 0;
  int _totalCompras = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prods = await _db.getProductos();
    final ventas = await _db.getVentas();
    final compras = await _db.getCompras();
    setState(() {
      _productos = prods.map((e) => Producto.fromMap(e)).toList();
      _totalVentas = ventas.length;
      _totalCompras = compras.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tarjetas resumen
            Row(
              children: [
                _tarjeta(
                  'Ventas',
                  _totalVentas.toString(),
                  Icons.point_of_sale,
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _tarjeta(
                  'Compras',
                  _totalCompras.toString(),
                  Icons.shopping_cart,
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Stock de Productos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._productos.map(
              (p) => ListTile(
                leading: const Icon(Icons.inventory_2),
                title: Text(p.nombre),
                trailing: Chip(
                  label: Text('${p.stock}'),
                  backgroundColor: p.stock < 5
                      ? Colors.red[100]
                      : Colors.green[100],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(String titulo, String valor, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(titulo),
            ],
          ),
        ),
      ),
    );
  }
}
