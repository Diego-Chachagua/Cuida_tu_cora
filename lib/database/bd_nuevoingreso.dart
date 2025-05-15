import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cuida_tu_cora/database/gasto_app.dart'; // Importamos para acceder a la base de datos

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
}