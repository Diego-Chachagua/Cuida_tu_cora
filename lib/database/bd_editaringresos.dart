import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class EditarIngresoDBHelper {
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
      onCreate: (db, version) async {
        // La creación de las tablas ya se manejó en gasto_app.dart
      },
    );
  }

  static Future<List<Map<String, dynamic>>> obtenerCategoriasDeIngreso() async {
    final db = await database;
    print("Instancia de la base de datos en obtenerCategoriasDeIngreso: $db"); // Nuevo print
    return await db.query('Categoria', where: 'id_tipo = ?', whereArgs: [1]);
  }

  static Future<int> actualizarIngreso(int idIngreso, int idCategoria, String? descIngreso, double montoIngreso, DateTime fechaIngreso) async {
    final db = await database;
    final String sql = '''
      UPDATE Ingresos
      SET id_categoria = ?,
          desc_ingreso = ?,
          monto_ingreso = ?,
          fecha_ingreso = ?
      WHERE id_ingreso = ?
    ''';
    final String formattedDate = "${fechaIngreso.year}-${fechaIngreso.month.toString().padLeft(2, '0')}-${fechaIngreso.day.toString().padLeft(2, '0')}";
    final List<dynamic> arguments = [
      idCategoria,
      descIngreso,
      montoIngreso,
      formattedDate,
      idIngreso,
    ];
    print('SQL (Actualizar Ingreso): $sql, Arguments: $arguments');
    try {
      return await db.rawUpdate(sql, arguments);
    } catch (e) {
      print('Error en rawUpdate (Actualizar Ingreso): $e');
      return 0;
    }
  }

  static Future<int> eliminarIngreso(int idIngreso) async {
    final db = await database;
    return await db.delete(
      'Ingresos',
      where: 'id_ingreso = ?',
      whereArgs: [idIngreso],
    );
  }
}