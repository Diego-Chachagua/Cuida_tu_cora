// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../database/gasto_app.dart'; 
import '../screens/editar_ingreso_screen.dart'; // Necesitarás crear esta pantalla

class IngresosScreen extends StatefulWidget {
  const IngresosScreen({super.key});

  @override
  _IngresosScreenState createState() => _IngresosScreenState();
}

class _IngresosScreenState extends State<IngresosScreen> {
  late Future<List<IngresoItem>> _ingresosFuture;

  @override
  void initState() {
    super.initState();
    _ingresosFuture = _cargarIngresos();
  }

  Future<List<IngresoItem>> _cargarIngresos() async {
    final db = await DBProvider.database;
    final List<Map<String, dynamic>> ingresosData = await db.rawQuery("""
        SELECT
        i.id_ingreso,
        i.desc_ingreso,
        i.monto_ingreso,
        i.fecha_ingreso,
        c.nom_categoria
        FROM Ingresos i
        INNER JOIN Categoria c ON i.id_categoria = c.id_categoria
        -- Aquí podríamos agregar una condición para filtrar por el tipo de categoría si sabemos el id_tipo o nom_tipo para ingresos
        ORDER BY i.fecha_ingreso DESC
    """);

    return ingresosData.map((ingreso) {
      print("Categoría de ingreso: ${ingreso['nom_categoria']}");
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
        child: FutureBuilder<List<IngresoItem>>(
          future: _ingresosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error al cargar los ingresos: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay ingresos registrados.'));
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
    );
  }

  Widget _buildIngresoItem(BuildContext context, IngresoItem ingreso) {
    return GestureDetector(
      onTap: () async {
         final result = await Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => EditarIngresoScreen(ingreso: ingreso)), // Necesitarás crear esta pantalla
         );
         if (result == true) {
           // Si la pantalla de edición devolvió true, recargamos los ingresos
           setState(() {
             _ingresosFuture = _cargarIngresos();
           });
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