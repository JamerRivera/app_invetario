import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/productos.dart';
import 'producto_form_screen.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final DBHelper _db = DBHelper();
  List<Producto> _productos = [];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final data = await _db.getProductos();
    setState(() {
      _productos = data.map((e) => Producto.fromMap(e)).toList();
    });
  }

  Future<void> _eliminar(int id) async {
    await _db.deleteProducto(id);
    _cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductoFormScreen()),
          );
          _cargarProductos();
        },
      ),
      body: _productos.isEmpty
          ? const Center(child: Text('No hay productos registrados'))
          : ListView.builder(
              itemCount: _productos.length,
              itemBuilder: (_, i) {
                final p = _productos[i];
                return ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text(p.nombre),
                  subtitle: Text('Stock: ${p.stock}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductoFormScreen(producto: p),
                            ),
                          );
                          _cargarProductos();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminar(p.idProducto!),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}