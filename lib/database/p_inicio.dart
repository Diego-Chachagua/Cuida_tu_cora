import 'package:cuida_tu_cora/database/gasto_app.dart'; // Importa tu DBProvider

class PInicialQueries {
  static Future<double> getTotalGastosMesActual() async {
    final db = await DBProvider.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(monto_gasto) AS total_gastos FROM Gastos WHERE STRFTIME('%Y-%m', fecha_gasto) = STRFTIME('%Y-%m', 'now', 'localtime')
    ''');

    return result.isNotEmpty && result[0]['total_gastos'] != null ? result[0]['total_gastos'] as double : 0.00;
  }

  static Future<double> getTotalIngresosMesActual() async {
    final db = await DBProvider.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(monto_ingreso) AS total_ingresos
      FROM Ingresos
      WHERE STRFTIME('%Y-%m', fecha_ingreso) = STRFTIME('%Y-%m', 'now', 'localtime')
    ''');

    return result.isNotEmpty && result[0]['total_ingresos'] != null ? result[0]['total_ingresos'] as double : 0.00;
  }

  static Future<List<Map<String, dynamic>>> getListaGastosDelMesActual() async {
    final db = await DBProvider.database;
    final List<Map<String, dynamic>> result = await db.rawQuery("""
      SELECT g.fecha_gasto, g.monto_gasto, g.nom_gasto, desc_gasto FROM Gastos g WHERE STRFTIME('%Y-%m', g.fecha_gasto) = STRFTIME('%Y-%m', 'now', 'localtime') ORDER BY g.fecha_gasto DESC
    """);
    return result;
  }
}