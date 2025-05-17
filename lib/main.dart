// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:cuida_tu_cora/database/p_inicio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'screens/gastos_screens.dart';
import 'screens/ingreso_screens.dart';
import 'screens/nuevo_gasto_screen.dart';
import 'screens/nuevo_ingreso_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
      ),
      home: const MyHomePage(title: 'ORGANIZAS TUS GASTOS'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<double> _gastosMesActual;
  late Future<double> _ingresoMesActual;
  bool _mostrarBotonesFlotantes = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _gastosMesActual = PInicialQueries.getTotalGastosMesActual();
      _ingresoMesActual = PInicialQueries.getTotalIngresosMesActual();
    });
  }

  String _obtenerMesAnioActual() {
    final now = DateTime.now();
    final formatoMesAnio = "${_obtenerNombreMes(now.month)} - ${now.year}";
    return formatoMesAnio;
  }

  String _obtenerNombreMes(int mes) {
    switch (mes) {
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF04B86D),
        toolbarHeight: isTablet ? 140 : 120,
        title: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.04),
                child: Image.asset(
                  "assets/logo.png",
                  height: isTablet ? 80 : 70,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Organiza",
                    style: TextStyle(
                      fontSize: isTablet ? 36 : 30,
                      fontFamily: "Roboto",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "Tus Gastos",
                    style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: isTablet ? 36 : 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gastos Totales",
                        style: TextStyle(fontSize: isTablet ? 18 : 16, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      FutureBuilder<double>(
                        future: _gastosMesActual,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text("Error al cargar");
                          } else {
                            final totalGastos = snapshot.data ?? 0.00;
                            return Text(
                              "\$ ${totalGastos.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: isTablet ? 24 : 20, fontWeight: FontWeight.bold),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Activos",
                        style: TextStyle(fontSize: isTablet ? 18 : 16, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      FutureBuilder<double>(
                        future: _ingresoMesActual,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text('Error al cargar');
                          } else {
                            final totalActivos = snapshot.data ?? 0.00;
                            return Text(
                              '\$ ${totalActivos.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: isTablet ? 24 : 20, fontWeight: FontWeight.bold),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Divider(
            color: Colors.grey,
            thickness: 2,
            indent: screenWidth * 0.1,
            endIndent: screenWidth * 0.1,
          ),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Gastos",
                      style: TextStyle(fontSize: isTablet ? 30 : 25, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(width: screenWidth * 0.01),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GastosScreen()),
                        ).then((_) {
                          _cargarDatos();
                        });
                      },
                      child: Text(
                        "Ver todos",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 22 : 20,
                          decoration: TextDecoration.underline,
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Row(
              children: [
                Text(
                  _obtenerMesAnioActual(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: isTablet ? 18 : 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: PInicialQueries.getListaGastosDelMesActual(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar los gastos: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay gastos registrados este mes.'));
                } else {
                  final listaGastos = snapshot.data!;
                  return ListView.builder(
                    itemCount: listaGastos.length,
                    itemBuilder: (context, index) {
                      final gasto = listaGastos[index];
                      String iconoNombre = "";
                      switch (gasto['nom_categoria']?.toLowerCase()) {
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
                        case 'medicina':
                          iconoNombre = "assets/medicina.svg";
                          break;
                        case 'trabajo':
                          iconoNombre = "assets/trabajo.svg";
                          break;
                        case 'viaje':
                          iconoNombre = "assets/viaje.svg";
                          break;
                        case 'vacaciones':
                          iconoNombre = "assets/vacaciones.svg";
                         case 'citas médicas':
                          iconoNombre = "assets/salud.svg";
                        default:
                          iconoNombre = 'assets/otro.svg';
                          break;
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: screenWidth * 0.04),
                              child: SizedBox(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                child: iconoNombre.endsWith('.svg')
                                    ? SvgPicture.asset(
                                        iconoNombre,
                                      )
                                    : (iconoNombre.isNotEmpty
                                        ? Image.asset(
                                            iconoNombre,
                                          )
                                        : const Icon(Icons.category, color: Colors.grey)),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gasto['nom_categoria'] ?? 'Gasto',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 18 : 16),
                                  ),
                                  Text(
                                    gasto['desc_gasto'] ?? 'Descripción del gasto',
                                    style: TextStyle(color: Colors.grey, fontSize: isTablet ? 14 : 12),
                                  )
                                ],
                              ),
                            ),
                            Text(
                              '\$${(gasto['monto_gasto'] as double).toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 18 : 16),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => IngresosScreen()),
                  ).then((_) {
                    _cargarDatos();
                  });
                  },
                  child: Text('Gestionar ingresos', style: TextStyle(fontSize: isTablet ? 18 : 16)),
                ),
                SizedBox(width: screenWidth * 0.05),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (_mostrarBotonesFlotantes)
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.09, right: screenWidth * 0.02),
              child: FloatingActionButton.extended(
                heroTag: 'ingresoBtn',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NuevoIngresoScreen()),
                  ).then((_) {
                    _cargarDatos();
                  });
                },
                label: Text('Ingreso', style: TextStyle(fontSize: isTablet ? 18 : 16)),
                icon: const Icon(Icons.arrow_upward),
              ),
            ),
          if (_mostrarBotonesFlotantes)
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.18, right: screenWidth * 0.02),
              child: FloatingActionButton.extended(
                heroTag: 'gastoBtn',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NuevoGastoScreen()),
                  ).then((_) {
                    _cargarDatos();
                  });
                },
                label: Text('Gastos', style: TextStyle(fontSize: isTablet ? 18 : 16)),
                icon: const Icon(Icons.arrow_downward),
              ),
            ),
          FloatingActionButton(
            heroTag: 'toggleBtn',
            onPressed: () {
              setState(() {
                _mostrarBotonesFlotantes = !_mostrarBotonesFlotantes;
              });
            },
            child: Icon(_mostrarBotonesFlotantes ? Icons.close : Icons.add, size: isTablet ? 30 : 24),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}