import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/productos.dart';

class CompraFormScreen extends StatefulWidget {
  const CompraFormScreen({super.key});

  @override
  State<CompraFormScreen> createState() => _CompraFormScreenState();
}

class _CompraFormScreenState extends State<CompraFormScreen> {
  final DBHelper _db = DBHelper();
  List<Producto> _productos = [];
  final List<Map<String, dynamic>> _detalle = [];
  Producto? _productoSeleccionado;
  final _cantidadCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    final data = await _db.getProductos();
    setState(() {
      _productos = data.map((e) => Producto.fromMap(e)).toList();
    });
  }

  void _agregarItem() {
    if (_productoSeleccionado == null) {
      _showWarning('Selecciona un producto');
      return;
    }
    final cantidad = int.tryParse(_cantidadCtrl.text.trim());
    if (cantidad == null || cantidad <= 0) {
      _showWarning('Ingresa una cantidad válida (mayor a 0)');
      return;
    }
    final precio = double.tryParse(_precioCtrl.text.trim());
    if (precio == null || precio <= 0) {
      _showWarning('Ingresa un precio válido (mayor a 0)');
      return;
    }
    final existe = _detalle.any(
      (item) => item['id_producto'] == _productoSeleccionado!.idProducto,
    );
    if (existe) {
      _showWarning('Este producto ya fue agregado a la compra');
      return;
    }
    setState(() {
      _detalle.add({
        'id_producto': _productoSeleccionado!.idProducto,
        'nombre': _productoSeleccionado!.nombre,
        'cantidad': cantidad,
        'precio_unitario': precio,
      });
      _productoSeleccionado = null;
      _cantidadCtrl.clear();
      _precioCtrl.clear();
    });
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.orange,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _guardarCompra() async {
    if (_detalle.isEmpty) return;
    setState(() => _guardando = true);
    try {
      final compra = {'fecha': DateTime.now().toIso8601String()};
      await _db.insertCompra(compra, _detalle);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Compra registrada correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al guardar la compra: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  double get _total => _detalle.fold(
      0, (s, i) => s + (i['cantidad'] * i['precio_unitario']));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Compra')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Producto>(
              value: _productoSeleccionado,
              hint: const Text('Seleccionar producto'),
              items: _productos
                  .map((p) =>
                      DropdownMenuItem(value: p, child: Text(p.nombre)))
                  .toList(),
              onChanged: (p) => setState(() => _productoSeleccionado = p),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _cantidadCtrl,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _precioCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Precio unitario'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Agregar producto'),
              onPressed: _agregarItem,
            ),
            const Divider(height: 24),
            Expanded(
              child: _detalle.isEmpty
                  ? const Center(child: Text('Agrega productos a la compra'))
                  : ListView.builder(
                      itemCount: _detalle.length,
                      itemBuilder: (_, i) {
                        final item = _detalle[i];
                        final subtotal =
                            item['cantidad'] * item['precio_unitario'];
                        return ListTile(
                          title: Text(item['nombre']),
                          subtitle: Text(
                              'Cant: ${item['cantidad']}  ·  \$${(item['precio_unitario'] as double).toStringAsFixed(2)}/u'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('\$${subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 20),
                                onPressed: () =>
                                    setState(() => _detalle.removeAt(i)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (_detalle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Total: ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('\$${_total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
                label:
                    Text(_guardando ? 'Guardando...' : 'Guardar Compra'),
                onPressed:
                    (_detalle.isEmpty || _guardando) ? null : _guardarCompra,
              ),
            ),
          ],
        ),
      ),
    );
  }
}