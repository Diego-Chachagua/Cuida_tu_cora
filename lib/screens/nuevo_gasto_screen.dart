// ignore_for_file: prefer_const_constructors_in_immutables, prefer_final_fields, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:cuida_tu_cora/database/bd_nuevogasto.dart'; // Importa tu nuevo helper
import 'package:flutter_svg/flutter_svg.dart'; // Importa flutter_svg

class NuevoGastoScreen extends StatefulWidget {
  NuevoGastoScreen({super.key});

  @override
  State<NuevoGastoScreen> createState() => _NuevoGastoScreenState();
}

class _NuevoGastoScreenState extends State<NuevoGastoScreen> {
  String? _categoriaSeleccionada;
  final List<String> _categorias = [];
  List<Map<String, dynamic>> _categoriasDB = [];
  TextEditingController _fechaController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();
  TextEditingController _montoController = TextEditingController();

  String? _categoriaError;
  String? _montoError;
  String? _fechaError;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    final categorias = await NuevoGastoDBHelper.obtenerCategoriasDeGasto();
    setState(() {
      _categoriasDB = categorias;
      _categorias.clear();
      for (var cat in _categoriasDB) {
        _categorias.add(cat['nom_categoria'] as String);
      }
    });
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _descripcionController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  bool _validarCampos() {
    setState(() {
      _categoriaError = _categoriaSeleccionada == null ? 'Este campo es obligatorio' : null;
      _fechaError = _fechaController.text.isEmpty ? 'Este campo es obligatorio' : null;

      if (_montoController.text.isEmpty) {
        _montoError = 'Este campo es obligatorio';
      } else {
        final monto = double.tryParse(_montoController.text);
        if (monto == null || monto <= 0) {
          _montoError = 'Ingrese un monto válido (mayor que 0)';
        } else {
          _montoError = null;
        }
      }
    });

    return _categoriaError == null && _montoError == null && _fechaError == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Gasto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Categoría',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Categoría',
                      prefixIcon: const Icon(Icons.tag),
                      errorText: _categoriaError,
                    ),
                    value: _categoriaSeleccionada,
                    items: _categorias.map((String categoria) {
                      String iconName = '';
                      if (categoria == 'Comida') {
                        iconName = 'comida.svg';
                      } else if (categoria == 'Educación') {
                        iconName = 'educacion.svg';
                      } else if (categoria == 'Medicina') {
                        iconName = 'salud.svg';
                      } else if (categoria == 'Citas médicas') {
                        iconName = 'salud.svg';
                      } else if (categoria == 'Agua') {
                        iconName = 'servicio_agua.svg';
                      } else if (categoria == 'Luz') {
                        iconName = 'servicio_luz.svg';
                      } else if (categoria == 'Internet') {
                        iconName = 'internet.svg';
                      } else if (categoria == 'Viaje') {
                        iconName = 'viaje.svg';
                      } else if (categoria == 'Vacaciones') {
                        iconName = 'viaje.svg';
                      } else if (categoria == 'Trabajo') {
                        iconName = 'trabajo.svg';
                      } else if (categoria == 'Transporte') {
                        iconName = 'transporte.svg';
                      } else if (categoria == 'Auto') {
                        iconName = 'auto.svg';
                      } else if (categoria == 'Comunicación') {
                        iconName = 'comunicacion.svg';
                      } else if (categoria == 'Deporte') {
                        iconName = 'deporte.svg';
                      } else if (categoria == 'Electrónica') {
                        iconName = 'eletronica.svg';
                      } else if (categoria == 'Entretenimiento') {
                        iconName = 'entretenimiento.svg';
                      } else if (categoria == 'Hijos') {
                        iconName = 'hijos.svg';
                      } else if (categoria == 'Mascota') {
                        iconName = 'mascota.svg';
                      } else if (categoria == 'Regalo') {
                        iconName = 'regalo.svg';
                      } else if (categoria == 'Reparaciones') {
                        iconName = 'reparaciones.svg';
                      } else if (categoria == 'Ropa') {
                        iconName = 'ropa.svg';
                      } else if (categoria == 'Salud') {
                        iconName = 'salud.svg';
                      } else {
                        iconName = 'otros.svg';
                      }

                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Row(
                          children: <Widget>[
                            SvgPicture.asset(
                              'assets/$iconName',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(categoria),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _categoriaSeleccionada = newValue;
                        _categoriaError = null; // Limpiar el error al cambiar la selección
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Descripción',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Descripción (opcional)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Monto',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _montoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Monto',
                      errorText: _montoError,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _montoError = null; // Limpiar el error al escribir
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Fecha',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _fechaController,
                          readOnly: true,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Fecha',
                            errorText: _fechaError,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {
                          _mostrarSelectorFecha(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const SizedBox(height: 30), // Espacio adicional antes del botón Guardar
            ElevatedButton(
              onPressed: () async {
                if (_validarCampos()) {
                  final confirmado = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmar Guardar'),
                        content: const Text('¿Estás seguro de que deseas guardar este gasto?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Guardar'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmado == true) {
                    Map<String, dynamic>? categoriaData = _categoriasDB.firstWhere(
                      (cat) => cat['nom_categoria'] == _categoriaSeleccionada,
                      orElse: () => <String, dynamic>{},
                    );
                    int? categoriaId = categoriaData.isNotEmpty ? categoriaData['id_categoria'] as int? : null;
                    double? monto = double.tryParse(_montoController.text);
                    DateTime? fechaGasto;
                    if (_fechaController.text.isNotEmpty) {
                      List<String> parts = _fechaController.text.split('/');
                      if (parts.length == 3) {
                        fechaGasto = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                      }
                    }

                    if (categoriaId != null && monto != null && fechaGasto != null) {
                      int resultado = await NuevoGastoDBHelper.nuevoGasto(
                        categoriaId,
                        _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
                        monto,
                        fechaGasto,
                      );
                      print('Resultado de la inserción: $resultado');
                      setState(() {
                        _categoriaSeleccionada = null;
                        _descripcionController.clear();
                        _montoController.clear();
                        _fechaController.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gasto guardado correctamente')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error interno al guardar el gasto.')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guardado cancelado.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, llena los campos obligatorios correctamente.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarSelectorFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        _fechaController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }
}