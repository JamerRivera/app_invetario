import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/clientes.dart';
import 'cliente_form_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final DBHelper _db = DBHelper();
  List<Cliente> _clientes = [];

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    final data = await _db.getClientes();
    setState(() {
      _clientes = data.map((e) => Cliente.fromMap(e)).toList();
    });
  }

  Future<void> _eliminar(int id) async {
    await _db.deleteCliente(id);
    _cargarClientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClienteFormScreen()),
          );
          _cargarClientes();
        },
      ),
      body: _clientes.isEmpty
          ? const Center(child: Text('No hay clientes registrados'))
          : ListView.builder(
              itemCount: _clientes.length,
              itemBuilder: (_, i) {
                final c = _clientes[i];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(c.nombre),
                  subtitle: Text(c.telefono ?? 'Sin teléfono'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClienteFormScreen(cliente: c),
                            ),
                          );
                          _cargarClientes();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminar(c.idCliente!),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
