import 'package:flutter/material.dart';
import 'package:cuida_tu_cora/database/gasto_app.dart';
import 'package:cuida_tu_cora/database/bd_nuevogasto.dart'; // Importa tu nuevo helper

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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.tag),
                    ),
                    value: _categoriaSeleccionada,
                    items: _categorias.map((String categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _categoriaSeleccionada = newValue;
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
                      labelText: 'Descripción',
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
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Monto',
                    ),
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
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Fecha',
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print('Guardar presionado');
                if (_categoriaSeleccionada != null) {
                  Map<String, dynamic>? categoriaData = _categoriasDB.firstWhere(
                    (cat) => cat['nom_categoria'] == _categoriaSeleccionada,
                    orElse: () => <String, dynamic>{}, // Devuelve un mapa vacío si no se encuentra
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
                      _categoriaSeleccionada!,
                      _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
                      monto,
                      fechaGasto,
                    );
                    print('Resultado de la inserción: $resultado');
                    // Opcional: Mostrar mensaje de éxito y limpiar campos
                  } else {
                    print('Error: Categoría no válida, monto no válido o fecha no válida.');
                    // Opcional: Mostrar mensaje de error
                  }
                } else {
                  print('Error: No se ha seleccionado una categoría.');
                  // Opcional: Mostrar mensaje de error
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                List<Map<String, dynamic>> gastos = await NuevoGastoDBHelper.obtenerTodosLosGastos();
                print('----- TODOS LOS GASTOS -----');
                for (var gasto in gastos) {
                  print(gasto);
                }
                print('----------------------------');
              },
              child: const Text('Mostrar Gastos', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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