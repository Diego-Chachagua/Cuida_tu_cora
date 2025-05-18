import 'package:cuida_tu_cora/database/gasto_app.dart';


class NuevoIngresoDBHelper {
  static Future<List<Map<String, dynamic>>> obtenerCategoriasDeIngreso() async {
    final db = await DBProvider.database;
    final List<Map<String, dynamic>> categorias = await db.rawQuery('''
      SELECT c.id_categoria, c.nom_categoria
      FROM Categoria c
      INNER JOIN Tipo_categoria tc ON c.id_tipo = tc.id_tipo
      WHERE tc.nom_tipo = 'Ingreso'
    ''');
    return categorias;
  }

  static Future<int> nuevoIngreso(int idCategoria, String? descripcion, double monto, DateTime fecha) async {
    final db = await DBProvider.database;
    final int id = await db.insert('Ingresos', {
      'id_categoria': idCategoria,
      'desc_ingreso': descripcion,
      'monto_ingreso': monto,
      'fecha_ingreso': fecha.toIso8601String(),
    });
    return id; // Retorna el ID del nuevo ingreso insertado
  }
  static Future<List<Map<String, dynamic>>> obtenerTodosLosIngresos() async {
    final db = await DBProvider.database;
    final List<Map<String, dynamic>> ingresos = await db.query('Ingresos');
    return ingresos;
  }

}

