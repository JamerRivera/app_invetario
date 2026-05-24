import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/clientes.dart';

class ClienteFormScreen extends StatefulWidget {
  final Cliente? cliente;
  const ClienteFormScreen({super.key, this.cliente});

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final DBHelper _db = DBHelper();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    if (widget.cliente != null) {
      _nombreCtrl.text = widget.cliente!.nombre;
      _telCtrl.text = widget.cliente!.telefono ?? '';
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final cliente = Cliente(
        idCliente: widget.cliente?.idCliente,
        nombre: _nombreCtrl.text.trim(),
        telefono: _telCtrl.text.trim(),
      );

      if (widget.cliente == null) {
        await _db.insertCliente(cliente.toMap());
      } else {
        await _db.updateCliente(cliente.toMap());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.cliente == null
                  ? 'Cliente guardado correctamente'
                  : 'Cliente actualizado correctamente',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el cliente: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cliente != null ? 'Editar Cliente' : 'Nuevo Cliente',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Campo requerido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final soloNumeros = RegExp(r'^\+?[\d\s\-]{7,15}$');
                    if (!soloNumeros.hasMatch(v.trim())) {
                      return 'Ingresa un teléfono válido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_guardando ? 'Guardando...' : 'Guardar'),
                  onPressed: _guardando ? null : _guardar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
