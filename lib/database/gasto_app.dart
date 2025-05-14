import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gasto_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Tipo_categoria (
        id_tipo INTEGER PRIMARY KEY NOT NULL,
        nom_tipo VARCHAR(50) NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE Categoria (
        id_categoria INTEGER PRIMARY KEY NOT NULL,
        id_tipo INTEGER NOT NULL,
        nom_categoria VARCHAR(50) NOT NULL,
        FOREIGN KEY (id_tipo) REFERENCES Tipo_categoria(id_tipo)
      );
    ''');

    await db.execute('''
      CREATE TABLE Gastos (
        id_gasto INTEGER PRIMARY KEY NOT NULL,
        id_categoria INTEGER NOT NULL,
        nom_gasto VARCHAR(50) NOT NULL,
        desc_gasto VARCHAR(255),
        monto_gasto REAL NOT NULL,
        fecha_gasto DATE NOT NULL,
        FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)
      );
    ''');

    await db.execute('''
      CREATE TABLE Ingresos (
        id_ingreso INTEGER PRIMARY KEY NOT NULL,
        id_categoria INTEGER NOT NULL,
        nom_ingreso VARCHAR(50) NOT NULL,
        desc_ingreso VARCHAR(255),
        monto_ingreso REAL NOT NULL,
        fecha_ingreso DATE NOT NULL,
        FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)
      );
    ''');

    // Insertar los registros de Tipo_categoria (Ingreso, Gastos)
    await db.insert('Tipo_categoria', {'id_tipo': 1, 'nom_tipo': 'Ingreso'});
    await db.insert('Tipo_categoria', {'id_tipo': 2, 'nom_tipo': 'Gastos'});

    // Insertar categorías relacionadas con Gastos
    await db.insert('Categoria', {'id_categoria': 1, 'id_tipo': 2, 'nom_categoria': 'Comida'});
    await db.insert('Categoria', {'id_categoria': 2, 'id_tipo': 2, 'nom_categoria': 'Educación'});
    await db.insert('Categoria', {'id_categoria': 3, 'id_tipo': 2, 'nom_categoria': 'Medicina'});
    await db.insert('Categoria', {'id_categoria': 4, 'id_tipo': 2, 'nom_categoria': 'Citas médicas'});
    await db.insert('Categoria', {'id_categoria': 5, 'id_tipo': 2, 'nom_categoria': 'Servicio de Agua'});
    await db.insert('Categoria', {'id_categoria': 6, 'id_tipo': 2, 'nom_categoria': 'Servicio de Luz'});
    await db.insert('Categoria', {'id_categoria': 7, 'id_tipo': 2, 'nom_categoria': 'Internet'});
    await db.insert('Categoria', {'id_categoria': 8, 'id_tipo': 2, 'nom_categoria': 'Viajes'});
    await db.insert('Categoria', {'id_categoria': 9, 'id_tipo': 2, 'nom_categoria': 'Vacaciones'});
    await db.insert('Categoria', {'id_categoria': 10, 'id_tipo': 2, 'nom_categoria': 'Trabajo'});
    await db.insert('Categoria', {'id_categoria': 11, 'id_tipo': 2, 'nom_categoria': 'Transporte'});

    // Insertar los gastos con sus montos
    await db.insert('Gastos', {
      'id_categoria': 1, // Comida
      'nom_gasto': 'Comida',
      'monto_gasto': 60.00,
      'fecha_gasto': DateTime.now().toIso8601String().split('T').first
    });

    await db.insert('Gastos', {
      'id_categoria': 2, // Educación
      'nom_gasto': 'Educación',
      'monto_gasto': 25.00,
      'fecha_gasto': DateTime.now().toIso8601String().split('T').first
    });

    await db.insert('Gastos', {
      'id_categoria': 5, // Servicio de Agua
      'nom_gasto': 'Agua',
      'monto_gasto': 3.00,
      'fecha_gasto': DateTime.now().toIso8601String().split('T').first
    });

    await db.insert('Gastos', {
      'id_categoria': 6, // Servicio de Luz
      'nom_gasto': 'Luz',
      'monto_gasto': 8.60,
      'fecha_gasto': DateTime.now().toIso8601String().split('T').first
    });

    await db.insert('Gastos', {
      'id_categoria': 11, // Transporte
      'nom_gasto': 'Transporte',
      'monto_gasto': 25.00,
      'fecha_gasto': DateTime.now().toIso8601String().split('T').first
    });

    await db.insert('Gastos', {
      'id_categoria': 7, // Internet
      'nom_gasto': 'Internet',
      'monto_gasto': 25.00,
      'fecha_gasto': DateTime.now().toIso8601String().split('T').first
    });

    // Insertar un ingreso
    await db.insert('Ingresos', {
      'id_categoria': 1, // Ingreso
      'nom_ingreso': 'Ingreso',
      'monto_ingreso': 400.00,
      'fecha_ingreso': DateTime.now().toIso8601String().split('T').first
    });

    
       

  // Future<double> getTotalGastosMesActual() {} // Consulta de los gastos del mes actual
    // Future<double> getTotalGastosMesActual() async {
    //   final db = await database;
    //   final List<Map<String, dynamic>> result = await db.rawQuery('''
    //     SELECT SUM(monto_gasto) AS total_gastos
    //     FROM Gastos
    //     WHERE STRFTIME('%Y-%m', fecha_gasto) = STRFTIME('%Y-%m', 'now', 'localtime')
    //   ''');
    //   return result.isNotEmpty && result[0]['total_gastos'] != null ? result[0]['total_gastos'] as double : 0.00;
    // }

    // // Consulta de los ingresos del mes actual
    // static Future<double> getTotalIngresosMesActual() async {
    //   final db = await database;
    //   final List<Map<String, dynamic>> result = await db.rawQuery('''
    //     SELECT SUM(monto_ingreso) AS total_ingresos
    //     FROM Ingresos
    //     WHERE STRFTIME('%Y-%m', fecha_ingreso) = STRFTIME('%Y-%m', 'now', 'localtime')
    //   ''');
    //   return result.isNotEmpty && result[0]['total_ingresos'] != null ? result[0]['total_ingresos'] as double : 0.00;
    // }
  }

  static getTotalGastosMesActual() {}

  static getTotalIngresosMesActual() {}
}
