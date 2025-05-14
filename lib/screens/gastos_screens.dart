// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../database/gasto_app.dart';

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
    final db = await DBProvider.database;
    final List<Map<String, dynamic>> gastosData = await db.query('Gastos');

    return gastosData.map((gasto) {
      String iconoNombre = "";
      switch (gasto['nom_gasto']?.toLowerCase()) {
        case 'comida':
          iconoNombre = 'assets/comida.svg';
                          break;
                        case 'educación':
                          iconoNombre = 'assets/educacion.svg';
                          break;
                        case 'agua':
                          iconoNombre = 'assets/servicio_agua.svg';
                          break;
                        case 'luz':
                          iconoNombre = 'assets/servicio_luz.svg';
                          break;
                        case 'transporte':
                          iconoNombre = 'assets/transporte.svg';
                          break;
                        case 'internet':
                          iconoNombre = 'assets/internet.svg';
                          break;
                        case 'auto':
                          iconoNombre = "assets/auto.svg";
                          break;
                        case 'comunicacion':
                          iconoNombre = "assets/comunicacion.svg";
                          break;
                        case 'deporte':
                          iconoNombre = "assets/deporte.svg";
                          break;
                        case 'eletronica':
                          iconoNombre = "assets/electronica.svg";
                          break;
                        case 'entretenimiento':
                          iconoNombre = "assets/entretenimiento.svg";
                          break;
                        case 'hijos':
                          iconoNombre = "assets/hijos.svg";
                          break;
                        case 'mascota':
                          iconoNombre = "assets/mascota.svg";
                          break;
                        case 'regalo':
                          iconoNombre = "assets/regalo.svg";
                          break;
                        case 'reparaciones':
                          iconoNombre = "assets/reparaciones.svg";
                          break;
                        case 'ropa':
                          iconoNombre = "assets/ropa.svg";
                          break;
                        case 'salud':
                          iconoNombre = "assets/salud.svg";
                          break;
                        case 'trabajo':
                          iconoNombre = "assets/trabajo.svg";
                          break;
                        case 'viaje':
                          iconoNombre = "assets/viaje.svg";
                          break;
                        default:
                          iconoNombre = 'assets/otro.svg';
                          break;
                      }

      return GastoItem(
        categoria: gasto['nom_gasto'] ?? 'Gasto',
        descripcion: gasto['desc_gasto'] ?? 'Descripción',
        monto: gasto['monto_gasto'] ?? 0.0,
        nombreIcono: iconoNombre,
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
      onTap: () {
        // Navega a la pantalla de Editar Gastos
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditarGastoScreen()),
        );
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
  final String categoria;
  final String descripcion;
  final double monto;
  final String nombreIcono;

  GastoItem({required this.categoria, required this.descripcion, required this.monto, required this.nombreIcono});
}

class EditarGastoScreen extends StatelessWidget {
  const EditarGastoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Gasto'),
      ),
      body: Center(
        child: Text('Pantalla para editar el gasto'),
      ),
    );
  }
}