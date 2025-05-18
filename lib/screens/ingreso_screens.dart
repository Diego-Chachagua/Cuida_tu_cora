// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../database/gasto_app.dart';
import '../screens/editar_ingreso_screen.dart';

class IngresosScreen extends StatefulWidget {
  const IngresosScreen({super.key});

  @override
  _IngresosScreenState createState() => _IngresosScreenState();
}

class _IngresosScreenState extends State<IngresosScreen> {
  Future<List<IngresoItem>>? _ingresosFuture;
  int? _selectedMonth;
  int? _selectedYear;
  List<int> _years = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _years = await _getAvailableYears();
    _selectedYear = DateTime.now().year;
    _selectedMonth = DateTime.now().month;
    _loadFilteredIngresos();
  }

  Future<List<int>> _getAvailableYears() async {
    final db = await DBProvider.database;
    final List<Map<String, dynamic>> yearsData = await db.rawQuery("""
      SELECT DISTINCT strftime('%Y', fecha_ingreso) as year
      FROM Ingresos
      ORDER BY year DESC
    """);
    return yearsData.map((y) => int.parse(y['year'] as String)).toList();
  }

  Future<List<IngresoItem>> _cargarIngresos({int? month, int? year}) async {
    final db = await DBProvider.database;
    String query = """
      SELECT
        i.id_ingreso,
        i.desc_ingreso,
        i.monto_ingreso,
        i.fecha_ingreso,
        c.nom_categoria
      FROM Ingresos i
      INNER JOIN Categoria c ON i.id_categoria = c.id_categoria
    """;

    List<dynamic> whereArgs = [];
    if (month != null) {
      query += " WHERE strftime('%m', i.fecha_ingreso) = ?";
      whereArgs.add(month < 10 ? '0$month' : '$month');
    }
    if (year != null) {
      query += (whereArgs.isNotEmpty ? " AND " : " WHERE ") + "strftime('%Y', i.fecha_ingreso) = ?";
      whereArgs.add('$year');
    }

    query += " ORDER BY i.fecha_ingreso DESC";

    final List<Map<String, dynamic>> ingresosData = await db.rawQuery(query, whereArgs);

    return ingresosData.map((ingreso) {
      String iconoNombre = "";
      switch (ingreso['nom_categoria']?.toLowerCase()) {
        case 'salario':
          iconoNombre = 'assets/salario.svg';
          break;
        case 'inversiones':
          iconoNombre = 'assets/inversion.svg';
          break;
        default:
          iconoNombre = 'assets/otros.svg';
          break;
      }

      return IngresoItem(
        id: ingreso['id_ingreso'] as int?,
        categoria: ingreso['nom_categoria'] ?? 'Ingreso',
        descripcion: ingreso['desc_ingreso'] ?? 'Descripción',
        monto: ingreso['monto_ingreso'] ?? 0.0,
        nombreIcono: iconoNombre,
        fecha: DateTime.parse(ingreso['fecha_ingreso'].toString()),
      );
    }).toList();
  }

  void _loadFilteredIngresos() {
    setState(() {
      _ingresosFuture = _cargarIngresos(month: _selectedMonth, year: _selectedYear);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF04B86D),
        toolbarHeight: 120,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ingresos',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Mes',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: _selectedMonth,
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem<int>(
                        value: month,
                        child: Text(_getMonthName(month)),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value;
                        _loadFilteredIngresos();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Año',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: _selectedYear,
                    items: _years.map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                        _loadFilteredIngresos();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0), // Espacio entre los filtros y la lista
            Expanded(
              child: FutureBuilder<List<IngresoItem>>(
                future: _ingresosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar los ingresos: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay ingresos registrados para el mes y año seleccionados.'));
                  } else {
                    final List<IngresoItem> ingresos = snapshot.data!;
                    return ListView.builder(
                      itemCount: ingresos.length,
                      itemBuilder: (context, index) {
                        return _buildIngresoItem(context, ingresos[index]);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Enero';
      case 2: return 'Febrero';
      case 3: return 'Marzo';
      case 4: return 'Abril';
      case 5: return 'Mayo';
      case 6: return 'Junio';
      case 7: return 'Julio';
      case 8: return 'Agosto';
      case 9: return 'Septiembre';
      case 10: return 'Octubre';
      case 11: return 'Noviembre';
      case 12: return 'Diciembre';
      default: return '';
    }
  }

  Widget _buildIngresoItem(BuildContext context, IngresoItem ingreso) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditarIngresoScreen(ingreso: ingreso)), // Necesitarás crear esta pantalla
        );
        if (result == true) {
          _loadFilteredIngresos(); // Recargar la lista filtrada después de editar
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: SizedBox(
                  width: 30.0,
                  height: 30.0,
                  child: SvgPicture.asset(ingreso.nombreIcono),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ingreso.categoria, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito', fontSize: 16)),
                    Text(ingreso.descripcion, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ),
              Text('\$${ingreso.monto.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, fontFamily: 'Nunito')),
            ],
          ),
        ),
      ),
    );
  }
}

class IngresoItem {
  final int? id;
  final String categoria;
  final String descripcion;
  final double monto;
  final String nombreIcono;
  final DateTime fecha;

  IngresoItem({this.id, required this.categoria, required this.descripcion, required this.monto, required this.nombreIcono, required this.fecha});
}