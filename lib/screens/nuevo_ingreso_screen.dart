import 'package:flutter/material.dart';
import 'package:cuida_tu_cora/database/bd_nuevoingreso.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NuevoIngresoScreen extends StatefulWidget {
  @override
  _NuevoIngresoScreenState createState() => _NuevoIngresoScreenState();
}

class _NuevoIngresoScreenState extends State<NuevoIngresoScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _categoriaSeleccionada;
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  List<Map<String, dynamic>> _categoriasIngreso = [];

  String? _categoriaError;
  String? _montoError;
  String? _fechaError;

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

  void _guardarIngreso() async {
    if (_validarCampos()) {
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar Guardar'),
            content: const Text('¿Estás seguro de que deseas guardar este ingreso?'),
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
        Map<String, dynamic>? categoriaData;
        try {
          categoriaData = _categoriasIngreso.firstWhere((cat) => cat['nom_categoria'] == _categoriaSeleccionada);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al encontrar la categoría')),
          );
          return;
        }
        final int? categoriaId = categoriaData?['id_categoria'] as int?;
        final double? monto = double.tryParse(_montoController.text);
        DateTime? fechaIngreso;
        if (_fechaController.text.isNotEmpty) {
          List<String> parts = _fechaController.text.split('/');
          if (parts.length == 3) {
            fechaIngreso = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        }

        if (categoriaId != null && monto != null && fechaIngreso != null) {
          int resultado = await NuevoIngresoDBHelper.nuevoIngreso(
            categoriaId,
            _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
            monto,
            fechaIngreso,
          );

          if (resultado > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ingreso guardado correctamente')),
            );
            setState(() {
              _categoriaSeleccionada = null;
              _descripcionController.clear();
              _montoController.clear();
              _fechaController.clear();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al guardar el ingreso')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, completa todos los campos correctamente')),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Ingreso'),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Categoría',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Categoría',
                        prefixIcon: const Icon(Icons.tag),
                        errorText: _categoriaError,
                      ),
                      value: _categoriasIngreso.firstWhere((cat) => cat['nom_categoria'] == _categoriaSeleccionada, orElse: () => {'id_categoria': null})['id_categoria'] as int?,
                      items: _categoriasIngreso.map((categoria) {
                        String iconName = '';
                        if (categoria['nom_categoria'] == 'Salario') {
                          iconName = 'salario.svg';
                        } else if (categoria['nom_categoria'] == 'Inversiones') {
                          iconName = 'inversion.svg';
                        } else if (categoria['nom_categoria'] == 'Otros Ingresos') {
                          iconName = 'otros.svg';
                        } else {
                          iconName = 'otros.svg';
                        }

                        return DropdownMenuItem<int>(
                          value: categoria['id_categoria'] as int?,
                          child: Row(
                            children: <Widget>[
                              if (iconName.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: SvgPicture.asset(
                                    'assets/$iconName',
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                              Text(categoria['nom_categoria'] as String),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          try {
                            _categoriaSeleccionada = _categoriasIngreso.firstWhere((cat) => cat['id_categoria'] == value)['nom_categoria'] as String?;
                            _categoriaError = null;
                          } catch (e) {
                            _categoriaSeleccionada = null;
                          }
                        });
                      },
                      validator: (value) {
                        if (_categoriaSeleccionada == null) {
                          return 'Por favor, selecciona una categoría';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Descripción',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
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
                    TextFormField(
                      controller: _montoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Monto',
                        errorText: _montoError,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _montoError = null;
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
                          child: TextFormField(
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
                          onPressed: () => _mostrarSelectorFecha(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _guardarIngreso,
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fechaController.text = "${picked.day}/${picked.month}/${picked.year}";
        _fechaError = null;
      });
    }
  }
}