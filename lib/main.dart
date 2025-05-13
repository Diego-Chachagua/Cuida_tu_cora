import 'package:flutter/material.dart';
import 'database/gasto_app.dart';

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
  Future<double> _gastosMesActual = DBProvider.getTotalGastosMesActual();
  // ignore: prefer_final_fields
  Future<double> _ingresoMesActual = DBProvider.getTotalIngresosMesActual();
  
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
        //Lista de los gastos
        Expanded( 
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DBProvider.getListaGastosDelMesActual(),
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
                      final fechaRaw = DateTime.parse(gasto['fecha_gasto'] as String);
                      final formatoFecha = "${fechaRaw.day}/${fechaRaw.month}/${fechaRaw.year}";

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 20,
                            ),
                            const SizedBox(width: 16),
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
                                    formatoFecha,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
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
        ],
      ),
    );
  }
}
