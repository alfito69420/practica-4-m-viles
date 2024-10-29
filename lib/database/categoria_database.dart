import 'package:p4pmsn/database/database_provider.dart';
import 'package:p4pmsn/model/categoria_model.dart';

class CategoriaDatabase {
  Future<int> insertCategoria(CategoriaModel categoria) async {
    final db = await DatabaseProvider().database;
    int id = await db.insert('categoria', {
      'id_categoria': categoria.id_categoria,
      'categoria': categoria.categoria,
    });
    return id;
  }

  Future<CategoriaModel?> getCategoria(int idCat) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'categoria',
      where: 'id_categoria = ?',
      whereArgs: [idCat],
    );
    if (results.isNotEmpty) {
      return CategoriaModel.fromMap(results.first);
    } else {
      return null;
    }
  }

  Future<List<CategoriaModel>> getCategorias() async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query('categoria');
    return results.map((categoria) => CategoriaModel.fromMap(categoria)).toList();
  }

  Future<int> updateCategoria(CategoriaModel categoria) async {
    final db = await DatabaseProvider().database;
    return await db.update(
      'categoria',
      {
        'id_categoria': categoria.id_categoria,
        'categoria': categoria.categoria,
      },
      where: 'id_categoria = ?',
      whereArgs: [categoria.id_categoria],
    );
  }

  Future<int> deleteCategoria(int idCat) async {
    final db = await DatabaseProvider().database;
    return await db.delete(
      'categoria',
      where: 'id_categoria = ?',
      whereArgs: [idCat],
    );
  }
}
