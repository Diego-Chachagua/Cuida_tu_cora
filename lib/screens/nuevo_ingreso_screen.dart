import 'package:flutter/material.dart';
import 'package:cuida_tu_cora/database/bd_nuevoingreso.dart'; // Importa el helper de ingresos

class NuevoIngresoScreen extends StatefulWidget {
  @override
  _NuevoIngresoScreenState createState() => _NuevoIngresoScreenState();
}

class _NuevoIngresoScreenState extends State<NuevoIngresoScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _categoriaSeleccionada;
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  DateTime? _fechaSeleccionada;
  List<Map<String, dynamic>> _categoriasIngreso = []; // Lista para las categorías de ingreso

  Future<void> _cargarCategoriasIngreso() async {
    final categorias = await NuevoIngresoDBHelper.obtenerCategoriasDeIngreso();
    setState(() {
      _categoriasIngreso = categorias;
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarCategoriasIngreso();
  }

  void _guardarIngreso() {
    if (_formKey.currentState!.validate()) {
      // Aquí iría la lógica para guardar el ingreso
      print('Categoría: $_categoriaSeleccionada');
      print('Descripción: ${_descripcionController.text}');
      print('Monto: ${_montoController.text}');
      print('Fecha: $_fechaSeleccionada');
      // TODO: Implementar el guardado en la base de datos
    }
  }

  Future<void> _elegirFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nuevo Ingreso'),
        backgroundColor: const Color(0xFF04B86D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                decoration: _inputDecoration('Categoría'),
                value: _categoriasIngreso.firstWhere((cat) => cat['nom_categoria'] == _categoriaSeleccionada, orElse: () => {'id_categoria': null})['id_categoria'] as int?,
                items: _categoriasIngreso.map((categoria) {
                  return DropdownMenuItem<int>(
                    value: categoria['id_categoria'] as int?,
                    child: Text(categoria['nom_categoria'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = _categoriasIngreso.firstWhere((cat) => cat['id_categoria'] == value)['nom_categoria'] as String?;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                decoration: _inputDecoration('Descripción'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _montoController,
                decoration: _inputDecoration('Monto'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el monto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _fechaSeleccionada != null
                          ? 'Fecha: ${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}'
                          : 'Selecciona una fecha',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _elegirFecha,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarIngreso,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF04B86D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 40,
                  ),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}