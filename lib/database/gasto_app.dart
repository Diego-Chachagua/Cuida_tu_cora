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
        desc_ingreso VARCHAR(255),
        monto_ingreso REAL NOT NULL,
        fecha_ingreso DATE NOT NULL,
        FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)
      );
    ''');

    await db.insert('Tipo_categoria', {'id_tipo': 1, 'nom_tipo': 'Ingreso'});
    await db.insert('Tipo_categoria', {'id_tipo': 2, 'nom_tipo': 'Gastos'});

    await db.insert('Categoria', {'id_categoria': 1, 'id_tipo': 2, 'nom_categoria': 'Comida'});
    await db.insert('Categoria', {'id_categoria': 2, 'id_tipo': 2, 'nom_categoria': 'Educación'});
    await db.insert('Categoria', {'id_categoria': 3, 'id_tipo': 2, 'nom_categoria': 'Medicina'});
    await db.insert('Categoria', {'id_categoria': 4, 'id_tipo': 2, 'nom_categoria': 'Citas médicas'});
    await db.insert('Categoria', {'id_categoria': 5, 'id_tipo': 2, 'nom_categoria': 'Agua'});
    await db.insert('Categoria', {'id_categoria': 6, 'id_tipo': 2, 'nom_categoria': 'Luz'});
    await db.insert('Categoria', {'id_categoria': 7, 'id_tipo': 2, 'nom_categoria': 'Internet'});
    await db.insert('Categoria', {'id_categoria': 8, 'id_tipo': 2, 'nom_categoria': 'Viaje'});
    await db.insert('Categoria', {'id_categoria': 9, 'id_tipo': 2, 'nom_categoria': 'Vacaciones'});
    await db.insert('Categoria', {'id_categoria': 10, 'id_tipo': 2, 'nom_categoria': 'Trabajo'});
    await db.insert('Categoria', {'id_categoria': 11, 'id_tipo': 2, 'nom_categoria': 'Transporte'});
    await db.insert('Categoria', {'id_categoria': 12, 'id_tipo': 2, 'nom_categoria': 'Auto'});
    await db.insert('Categoria', {'id_categoria': 13, 'id_tipo': 2, 'nom_categoria': 'Comunicación'});
    await db.insert('Categoria', {'id_categoria': 14, 'id_tipo': 2, 'nom_categoria': 'Deporte'});
    await db.insert('Categoria', {'id_categoria': 15, 'id_tipo': 2, 'nom_categoria': 'Electrónica'});
    await db.insert('Categoria', {'id_categoria': 16, 'id_tipo': 2, 'nom_categoria': 'Entretenimiento'});
    await db.insert('Categoria', {'id_categoria': 17, 'id_tipo': 2, 'nom_categoria': 'Hijos'});
    await db.insert('Categoria', {'id_categoria': 18, 'id_tipo': 2, 'nom_categoria': 'Mascota'});
    await db.insert('Categoria', {'id_categoria': 19, 'id_tipo': 2, 'nom_categoria': 'Regalo'});
    await db.insert('Categoria', {'id_categoria': 20, 'id_tipo': 2, 'nom_categoria': 'Reparaciones'});
    await db.insert('Categoria', {'id_categoria': 21, 'id_tipo': 2, 'nom_categoria': 'Ropa'});
    

    
    await db.insert('Categoria', {'id_categoria': 22, 'id_tipo': 1, 'nom_categoria': 'Salario'});
    await db.insert('Categoria', {'id_categoria': 23, 'id_tipo': 1, 'nom_categoria': 'Inversiones'});
    await db.insert('Categoria', {'id_categoria': 24, 'id_tipo': 1, 'nom_categoria': 'Otros Ingresos'});

    await db.insert('Gastos', {
      'id_categoria': 1,
      'desc_gasto': 'Almuerzo en restaurante',
      'monto_gasto': 60.00,
      'fecha_gasto': DateTime.now().toIso8601String().split('T').first
    });

    await db.insert('Gastos', {
      'id_categoria': 2,
      'desc_gasto': 'Libro de programación',
      'monto_gasto': 25.00,
      'fecha_gasto': DateTime.now().toIso8601String().split('T').first
    });

    await db.insert('Gastos', {
      'id_categoria': 5,
      'desc_gasto': 'Recibo del mes',
      'monto_gasto': 3.00,
      'fecha_gasto': DateTime.now().toIso8601String().split('T').first
    });

    await db.insert('Gastos', {
      'id_categoria': 6,
      'desc_gasto': 'Factura eléctrica',
      'monto_gasto': 8.60,
      'fecha_gasto': DateTime.now().toIso8601String().split('T').first
    });

    await db.insert('Gastos', {
      'id_categoria': 11,
      'desc_gasto': 'Pasaje de autobús',
      'monto_gasto': 25.00,
      'fecha_gasto': DateTime.now().toIso8601String().split('T').first
    });

    await db.insert('Gastos', {
      'id_categoria': 7,
      'desc_gasto': 'Mensualidad del proveedor',
      'monto_gasto': 25.00,
      'fecha_gasto': DateTime.now().toIso8601String().split('T').first
    });

    
    await db.insert('Ingresos', {
      'id_categoria': 22,
      'desc_ingreso': 'Pago quincenal',
      'monto_ingreso': 400.00,
      'fecha_ingreso': DateTime.now().toIso8601String().split('T').first
    });
  }

  static Future<double> getTotalGastosMesActual() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(g.monto_gasto) AS total_gastos
      FROM Gastos g
      INNER JOIN Categoria c ON g.id_categoria = c.id_categoria
      INNER JOIN Tipo_categoria tc ON c.id_tipo = tc.id_tipo
      WHERE STRFTIME('%Y-%m', g.fecha_gasto) = STRFTIME('%Y-%m', 'now', 'localtime')
      AND tc.nom_tipo = 'Gastos'
    ''');
    return result.isNotEmpty && result[0]['total_gastos'] != null ? result[0]['total_gastos'] as double : 0.00;
  }

  static Future<double> getTotalIngresosMesActual() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(i.monto_ingreso) AS total_ingresos
      FROM Ingresos i
      INNER JOIN Categoria c ON i.id_categoria = c.id_categoria
      INNER JOIN Tipo_categoria tc ON c.id_tipo = tc.id_tipo
      WHERE STRFTIME('%Y-%m', i.fecha_ingreso) = STRFTIME('%Y-%m', 'now', 'localtime')
      AND tc.nom_tipo = 'Ingreso'
    ''');
    return result.isNotEmpty && result[0]['total_ingresos'] != null ? result[0]['total_ingresos'] as double : 0.00;
  }
}