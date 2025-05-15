import 'gasto_app.dart'; // Importa tu DBProvider

class NuevoGastoDBHelper {
  static Future<int> nuevoGasto(
      int idCategoria, String? descripcion, double monto, DateTime fecha) async {
    final db = await DBProvider.database;
    final res = await db.insert('Gastos', {
      'id_categoria': idCategoria,
      'desc_gasto': descripcion,
      'monto_gasto': monto,
      'fecha_gasto': fecha.toIso8601String().split('T').first,
    });
    return res;
  }

  static Future<List<Map<String, dynamic>>> obtenerTodosLosGastos() async {
    final db = await DBProvider.database;
    return await db.query('Gastos');
  }

  static Future<List<Map<String, dynamic>>> obtenerCategoriasDeGasto() async {
    final db = await DBProvider.database;
    return await db.query(
      'Categoria',
      where: 'id_tipo = ?',
      whereArgs: [2], // 2 es el ID para 'Gastos' en Tipo_categoria
    );
  }
}