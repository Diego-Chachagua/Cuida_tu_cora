import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/ingreso_screens.dart'; // Importa IngresoItem
import '../database/bd_editaringresos.dart'; // Importa el DBHelper de ingresos

class EditarIngresoScreen extends StatefulWidget {
  final IngresoItem ingreso;
  const EditarIngresoScreen({super.key, required this.ingreso});

  @override
  _EditarIngresoScreenState createState() => _EditarIngresoScreenState();
}

class _EditarIngresoScreenState extends State<EditarIngresoScreen> {
  String? _categoriaSeleccionada;
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  List<Map<String, dynamic>> _categoriasIngreso = [];
  int? _categoriaIdSeleccionada;

  String? _categoriaError;
  String? _montoError;
  String? _fechaError;

  @override
  void initState() {
    super.initState();
    _cargarCategoriasIngreso().then((_) {
      print("Categoría del ingreso a editar: ${widget.ingreso.categoria}");
      print("Lista de categorías cargadas:");
      for (var cat in _categoriasIngreso) {
        print("- ${cat['nom_categoria']}");
      }
      try {
        _categoriaIdSeleccionada = _categoriasIngreso.firstWhere((cat) => cat['nom_categoria'] == widget.ingreso.categoria)['id_categoria'] as int?;
      } catch (e) {
        print("Categoría no encontrada en la lista: ${widget.ingreso.categoria}");
        _categoriaIdSeleccionada = null;
      }
    });
    _categoriaSeleccionada = widget.ingreso.categoria;
    _descripcionController.text = widget.ingreso.descripcion ?? '';
    _montoController.text = widget.ingreso.monto.toStringAsFixed(2);
    _fechaController.text = "${widget.ingreso.fecha.day}/${widget.ingreso.fecha.month}/${widget.ingreso.fecha.year}";
  }

  Future<void> _cargarCategoriasIngreso() async {
    final categorias = await EditarIngresoDBHelper.obtenerCategoriasDeIngreso();
    setState(() {
      _categoriasIngreso = categorias;
    });
    print("_categoriasIngreso después de cargar: $_categoriasIngreso");
  }

  Future<void> _mostrarSelectorFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.ingreso.fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fechaController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
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

 Future<void> _actualizarIngreso() async {
    if (_validarCampos()) {
      int? categoriaId = _categoriaIdSeleccionada; // Usamos el ID ya seleccionado
      final double? montoActualizado = double.tryParse(_montoController.text);
      DateTime? fechaActualizada;
      if (_fechaController.text.isNotEmpty) {
        List<String> parts = _fechaController.text.split('/');
        if (parts.length == 3) {
          fechaActualizada = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      }

      if (categoriaId != null && montoActualizado != null && fechaActualizada != null) {
        int resultado = await EditarIngresoDBHelper.actualizarIngreso(
          widget.ingreso.id!,
          categoriaId,
          _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
          montoActualizado,
          fechaActualizada,
        );

        if (resultado > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingreso actualizado correctamente')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar el ingreso')),
          );
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, completa todos los campos correctamente')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, corrige los errores en los campos')),
      );
    }
  }

  Future<void> _eliminarIngreso() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este ingreso?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmado == true) {
      int resultado = await EditarIngresoDBHelper.eliminarIngreso(widget.ingreso.id!);
      if (resultado > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso eliminado correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el ingreso')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Ingreso'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              value: _categoriaIdSeleccionada,
              items: _categoriasIngreso.map((categoria) {
                String iconName = '';
                switch (categoria['nom_categoria']?.toLowerCase()) {
                  case 'salario': iconName = 'salario.svg'; break;
                  case 'inversiones': iconName = 'inversion.svg'; break;
                  case 'otros ingresos': iconName = 'otros.svg'; break;
                  default: iconName = 'otros.svg'; break;
                }
                return DropdownMenuItem<int>(
                  value: categoria['id_categoria'] as int?,
                  child: Row(
                    children: <Widget>[
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
                  _categoriaIdSeleccionada = value;
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
                labelText: 'Descripción',
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
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _actualizarIngreso,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Actualizar', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _eliminarIngreso,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}