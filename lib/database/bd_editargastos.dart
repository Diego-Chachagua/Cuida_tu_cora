import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class EditarGastoDBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<String> get fullPath async {
    const String databaseName = 'gasto_app.db';
    final String path = await getDatabasesPath();
    return join(path, databaseName);
  }

  static Future<Database> _initDatabase() async {
    final String path = await fullPath;
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS Categoria (
        id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
        nom_categoria TEXT UNIQUE
      )
    """);
    await db.execute("""
      CREATE TABLE IF NOT EXISTS Gastos (
        id_gasto INTEGER PRIMARY KEY AUTOINCREMENT,
        id_categoria INTEGER,
        desc_gasto TEXT,
        monto_gasto REAL NOT NULL,
        fecha_gasto TEXT NOT NULL,
        FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)
      )
    """);
    await _insertInitialCategories(db);
  }

  static Future<void> _insertInitialCategories(Database db) async {
    List<Map<String, dynamic>> initialCategories = [
      {'nom_categoria': 'Comida'},
      {'nom_categoria': 'Educación'},
      {'nom_categoria': 'Transporte'},
      {'nom_categoria': 'Servicios'},
      {'nom_categoria': 'Ocio'},
      {'nom_categoria': 'Salud'},
      {'nom_categoria': 'Otros'},
    ];
    for (var category in initialCategories) {
      try {
        await db.insert('Categoria', category, conflictAlgorithm: ConflictAlgorithm.ignore);
      } catch (e) {
        print('Error inserting category ${category['nom_categoria']}: $e');
      }
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerCategoriasDeGasto() async {
    final db = await database;
    return await db.query('Categoria');
  }

  static Future<int> actualizarGasto(int idGasto, int idCategoria, String? descGasto, double montoGasto, DateTime fechaGasto) async {
    final db = await database;
    final String sql = '''
      UPDATE Gastos
      SET id_categoria = ?,
          desc_gasto = ?,
          monto_gasto = ?,
          fecha_gasto = ?
      WHERE id_gasto = ?
    ''';
    final String formattedDate = "${fechaGasto.year}-${fechaGasto.month.toString().padLeft(2, '0')}-${fechaGasto.day.toString().padLeft(2, '0')}";
    final List<dynamic> arguments = [
      idCategoria,
      descGasto,
      montoGasto,
      formattedDate,
      idGasto,
    ];
    print('SQL: $sql, Arguments: $arguments');
    try {
      return await db.rawUpdate(sql, arguments);
    } catch (e) {
      print('Error en rawUpdate: $e');
      return 0;
    }
  }

  static Future<int> eliminarGasto(int idGasto) async {
    final db = await database;
    return await db.delete(
      'Gastos',
      where: 'id_gasto = ?',
      whereArgs: [idGasto],
    );
  }
}