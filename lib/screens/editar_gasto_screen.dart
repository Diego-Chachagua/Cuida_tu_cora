import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/gastos_screens.dart'; // Importa GastoItem
import '../database/bd_editargastos.dart'; // Importa el nuevo DBHelper

class EditarGastoScreen extends StatefulWidget {
  final GastoItem gasto;
  EditarGastoScreen({Key? key, required this.gasto}) : super(key: key);

  @override
  _EditarGastoScreenState createState() => _EditarGastoScreenState();
}

class _EditarGastoScreenState extends State<EditarGastoScreen> {
  String? _categoriaSeleccionada;
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  List<Map<String, dynamic>> _categoriasGasto = [];
  int? _categoriaIdSeleccionada;

  String? _categoriaError;
  String? _montoError;
  String? _fechaError;

  @override
  void initState() {
    super.initState();
    _cargarCategoriasGasto();
    _categoriaSeleccionada = widget.gasto.categoria;
    _descripcionController.text = widget.gasto.descripcion;
    _montoController.text = widget.gasto.monto.toStringAsFixed(2);
    _fechaController.text = "${widget.gasto.fecha.day}/${widget.gasto.fecha.month}/${widget.gasto.fecha.year}";
  }

  Future<void> _cargarCategoriasGasto() async {
    final categorias = await EditarGastoDBHelper.obtenerCategoriasDeGasto();
    setState(() {
      _categoriasGasto = categorias;
      // Establecer el ID de la categoría seleccionada al iniciar
      try {
        _categoriaIdSeleccionada = _categoriasGasto.firstWhere((cat) => cat['nom_categoria'] == widget.gasto.categoria)['id_categoria'] as int?;
      } catch (e) {
        print("Categoría no encontrada en la lista: ${widget.gasto.categoria}");
        _categoriaIdSeleccionada = null;
      }
    });
  }

  Future<void> _mostrarSelectorFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.gasto.fecha,
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

  Future<void> _actualizarGasto() async {
    if (_validarCampos()) {
      final categoriaData = _categoriasGasto.firstWhere((cat) => cat['nom_categoria'] == _categoriaSeleccionada);
      final int? categoriaId = categoriaData['id_categoria'] as int?;
      final double? montoActualizado = double.tryParse(_montoController.text);
      DateTime? fechaActualizada;
      if (_fechaController.text.isNotEmpty) {
        List<String> parts = _fechaController.text.split('/');
        if (parts.length == 3) {
          fechaActualizada = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      }

      if (categoriaId != null && montoActualizado != null && fechaActualizada != null) {
        print('ID Gasto: ${widget.gasto.id}');
        print('ID Categoría: $categoriaId');
        print('Descripción: ${_descripcionController.text}');
        print('Monto: $montoActualizado');
        print('Fecha: $fechaActualizada');
        int resultado = await EditarGastoDBHelper.actualizarGasto(
          widget.gasto.id!,
          categoriaId,
          _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
          montoActualizado,
          fechaActualizada,
        );

        if (resultado > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gasto actualizado correctamente')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar el gasto')),
          );
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

  Future<void> _eliminarGasto() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este gasto?'),
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
      int resultado = await EditarGastoDBHelper.eliminarGasto(widget.gasto.id!);
      if (resultado > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto eliminado correctamente')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el gasto')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Gasto'),
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
              items: _categoriasGasto.map((categoria) {
                String iconName = '';
                // Mapear el nombre de la categoría al nombre del archivo SVG
                switch (categoria['nom_categoria']?.toLowerCase()) {
                  case 'comida': iconName = 'comida.svg'; break;
                  case 'educación': iconName = 'educacion.svg'; break;
                  case 'transporte': iconName = 'transporte.svg'; break;
                  case 'servicios': iconName = 'otros.svg'; break; // Ajusta según tus iconos
                  case 'ocio': iconName = 'entretenimiento.svg'; break; // Ajusta según tus iconos
                  case 'salud': iconName = 'salud.svg'; break;
                  case 'otros': iconName = 'otros.svg'; break;
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
                    _categoriaSeleccionada = _categoriasGasto.firstWhere((cat) => cat['id_categoria'] == value)['nom_categoria'] as String?;
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
                  onPressed: _actualizarGasto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Actualizar', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _eliminarGasto,
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