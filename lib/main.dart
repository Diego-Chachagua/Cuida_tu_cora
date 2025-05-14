import 'package:flutter/material.dart';
import 'database/gasto_app.dart';
import 'package:cuida_tu_cora/database/p_inicio.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  // ignore: prefer_final_fields
  Future<double> _gastosMesActual = PInicialQueries.getTotalGastosMesActual();
  // ignore: prefer_final_fields
  Future<double> _ingresoMesActual = PInicialQueries.getTotalIngresosMesActual();
  bool _mostrarBotonesFlotantes = false;
  
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF04B86D),
        toolbarHeight: 120,
        title: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Image.asset(
                  "assets/logo.png",
                  height: 70,
                ),
              ),
            ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  const Text(
                    "Organiza",
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: "Roboto",
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Tus Gastos",
                    style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 30,
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
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text (
                      "Gastos Totales",
                      style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),

                    FutureBuilder<double>(
                      future: _gastosMesActual,
                      builder: (context, snapshot){
                        if (snapshot.connectionState == ConnectionState.waiting){
                          return const CircularProgressIndicator();
                        } else if(snapshot.hasError) {
                          return const Text("Error al cargar");
                        } else {
                          final totalGastos = snapshot.data ?? 0.00;
                          return Text(
                            "\$ ${totalGastos.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          );
                        }
                      }
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text (
                      "Activos",
                      style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                    const SizedBox(height: 4),
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
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),                            );
                        }
                      },
                    ),  
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Divider(
            color: Colors.grey,
            thickness: 2,
            indent: 40,
            endIndent: 40,
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Gastos",
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {  
                      },
                      child: const Text(
                        "Ver todos",
                        style: 
                        TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  _obtenerMesAnioActual(),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
          ),

        //Lista de los gastos
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
                        case 'comunicacion':
                          iconoNombre = "assets/comunicacion.svg";
                        case 'deporte':
                          iconoNombre = "assets/deporte.svg";
                        case 'eletronica':
                          iconoNombre = "assets/electronica.svg";
                        case 'entretenimiento':
                          iconoNombre = "assets/entretenimiento.svg";
                        case 'hijos':
                          iconoNombre = "assets/hijos.svg";
                        case 'mascota':
                          iconoNombre = "assets/mascota.svg";
                        case 'regalo':
                          iconoNombre = "assets/regalo.svg";
                        case 'reparaciones':
                          iconoNombre = "assets/reparaciones.svg";
                        case 'ropa':
                          iconoNombre = "assets/ropa.svg";
                        case 'salud':
                          iconoNombre = "assets/salud.svg";
                        case 'trabajo':
                          iconoNombre = "assets/trabajo.svg";
                        case 'viaje':
                          iconoNombre = "assets/viaje.svg";
                        default:
                          iconoNombre = 'assets/otro.svg';
                          break;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: SizedBox(
                                height: 30, // Ajusta el tamaño del contenedor del icono
                                width: 30,
                                child: iconoNombre.endsWith('.svg')
                                    ? SvgPicture.asset(
                                        iconoNombre,
                                      )
                                    : (iconoNombre.isNotEmpty
                                        ? Image.asset(
                                            iconoNombre,
                                          )
                                        : const Icon(Icons.category, color: Colors.grey)), // Icono por defecto si no hay imagen
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gasto['nom_gasto'] ?? 'Gasto',
                                    style:
                                        const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    gasto['desc_gasto'] ?? 'Descripción del gasto', // Asegúrate de que 'desc_gasto' esté disponible
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  )
                                ],
                              ),
                            ),
                            Text(
                              '\$${(gasto['monto_gasto'] as double).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
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
          const SizedBox(height: 60),
          Padding( // Nueva Row para los botones inferiores
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Lógica para actualizar la lista
                    setState(() {
                      _gastosMesActual = PInicialQueries.getTotalGastosMesActual();
                      _ingresoMesActual = PInicialQueries.getTotalIngresosMesActual();
                    });
                  },
                  child: const Text('Actualizar'),
                ),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _mostrarBotonesFlotantes = !_mostrarBotonesFlotantes;
                    });
                  },
                  child: const Icon(Icons.add), // Usamos el icono de "add" que se parece a una cruz al rotarlo
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
