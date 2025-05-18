// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../database/gasto_app.dart';
import '../screens/editar_gasto_screen.dart'; // Importa la pantalla de edición

class GastosScreen extends StatefulWidget {
  const GastosScreen({super.key});

  @override
  _GastosScreenState createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> {
  late Future<List<GastoItem>> _gastosFuture;

  @override
  void initState() {
    super.initState();
    _gastosFuture = _cargarGastos();
  }

  Future<List<GastoItem>> _cargarGastos() async {
    print("--- Cargando gastos ---"); // Aquí

    final db = await DBProvider.database;
    final List<Map<String, dynamic>> gastosData = await db.rawQuery("""
      SELECT
        g.id_gasto,
        g.desc_gasto,
        g.monto_gasto,
        g.fecha_gasto,
        c.nom_categoria
      FROM Gastos g
      INNER JOIN Categoria c ON g.id_categoria = c.id_categoria
      ORDER BY g.fecha_gasto DESC
    """);

    final List<GastoItem> gastos = gastosData.map((gasto) {
      String iconoNombre = "";
      switch (gasto['nom_categoria']?.toLowerCase()) {
        case 'comida': iconoNombre = 'assets/comida.svg'; break;
        case 'educación': iconoNombre = 'assets/educacion.svg'; break;
        case 'agua': iconoNombre = 'assets/servicio_agua.svg'; break;
        case 'luz': iconoNombre = 'assets/servicio_luz.svg'; break;
        case 'transporte': iconoNombre = 'assets/transporte.svg'; break;
        case 'internet': iconoNombre = 'assets/internet.svg'; break;
        case 'auto': iconoNombre = "assets/auto.svg"; break;
        case 'comunicacion': iconoNombre = "assets/comunicacion.svg"; break;
        case 'deporte': iconoNombre = "assets/deporte.svg"; break;
        case 'electrónica': iconoNombre = "assets/eletronica.svg"; break;
        case 'entretenimiento': iconoNombre = "assets/entretenimiento.svg"; break;
        case 'hijos': iconoNombre = "assets/hijos.svg"; break;
        case 'mascota': iconoNombre = "assets/mascota.svg"; break;
        case 'regalo': iconoNombre = "assets/regalo.svg"; break;
        case 'reparaciones': iconoNombre = "assets/reparaciones.svg"; break;
        case 'ropa': iconoNombre = "assets/ropa.svg"; break;
        case 'citas médicas': iconoNombre = "assets/salud.svg"; break;
        case 'trabajo': iconoNombre = "assets/trabajo.svg"; break;
        case 'viaje': iconoNombre = "assets/viaje.svg"; break;
        case 'vacaciones': iconoNombre = "assets/vacaciones.svg"; break;
        case 'medicina': iconoNombre = "assets/medicina.svg"; break;
        default: iconoNombre = 'assets/otros.svg'; break;
      }

      return GastoItem(
        id: gasto['id_gasto'] as int?,
        categoria: gasto['nom_categoria'] ?? 'Gasto',
        descripcion: gasto['desc_gasto'] ?? 'Descripción',
        monto: gasto['monto_gasto'] ?? 0.0,
        nombreIcono: iconoNombre,
        fecha: DateTime.parse(gasto['fecha_gasto'].toString()),
      );
    }).toList();

    print("--- Gastos cargados: ${gastos.length} ---"); // Aquí
    return gastos;
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
          'Gastos',
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
        child: FutureBuilder<List<GastoItem>>(
          future: _gastosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error al cargar los gastos: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay gastos registrados.'));
            } else {
              final List<GastoItem> gastos = snapshot.data!;
              return ListView.builder(
                itemCount: gastos.length,
                itemBuilder: (context, index) {
                  return _buildGastoItem(context, gastos[index]);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildGastoItem(BuildContext context, GastoItem gasto) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditarGastoScreen(gasto: gasto)),
        );
        if (result == true) {
          // Si la pantalla de edición devolvió true (hubo cambio), recargamos los gastos
          setState(() {
            _gastosFuture = _cargarGastos();
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
                  child: SvgPicture.asset(gasto.nombreIcono),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gasto.categoria, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito', fontSize: 16)),
                    Text(gasto.descripcion, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ),
              Text('\$${gasto.monto.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, fontFamily: 'Nunito')),
            ],
          ),
        ),
      ),
    );
  }
}

class GastoItem {
  final int? id; // Añadimos el ID
  final String categoria;
  final String descripcion;
  final double monto;
  final String nombreIcono;
  final DateTime fecha; // Añadimos la fecha

  GastoItem({this.id, required this.categoria, required this.descripcion, required this.monto, required this.nombreIcono, required this.fecha});
}